#include "Exporter.hpp"
#ifdef WIN32
#include <direct.h>
#else 
#include <unistd.h>
#endif //WIN32
#include <boost/filesystem.hpp>
using namespace boost::filesystem;
#include <iostream>
#include <vector>
#include <stdlib.h> 
#include <algorithm>
#include <fstream>
using namespace std;



RHStandardExporter::RHStandardExporter(){
	hashGenerator = 0;
}

RHStandardExporter::~RHStandardExporter(){

}

void RHStandardExporter::SetHashGenerator(HashGenerator* generator){
	hashGenerator = generator;
}



void appendFilesToList(const path& p, vector<string>& actualFilesList, int level){
	directory_iterator end_itr;
	directory_iterator itr(p);
	while(itr!=end_itr){
		auto fnstring = itr->path().generic_string();
		if(  is_directory(itr->status())  ){
			appendFilesToList(itr->path(), actualFilesList, level+1);
		}else{
			actualFilesList.push_back(fnstring);
		}
		itr++;
	}
}




void RHStandardExporter::removeOmittedFromList(
	const ExportOptions& opts, 
	std::vector<std::string>& list
)const{
	vector<mypair> pairs;
	vector<string> ignoredFileList;
	path rootPath(opts.exportRoothPath);
	rootPath = absolute(rootPath);
	auto exportRoothPath = rootPath.generic_string();
	if(exportRoothPath.back()!='/'){
		exportRoothPath+='/';
	}
	
	for(auto omittedFile:opts.omitFiles ){
		path omitFilePath(exportRoothPath+omittedFile);
		//path absolutePath = rootPath+omitFilePath;
		if(exists(omitFilePath)){
			mypair element;
			element.path = omitFilePath.generic_string();
			element.isDir = is_directory(omitFilePath);
			if(element.isDir){element.path+=('/');}
			pairs.push_back(element);
		}
	}
	//Ya se tiene la lista de elementos que eliminar de la lista
	//Ahora comparar la lista de archivos y quitarle los elementos a emitir
	for(auto omitFile:pairs){
		
		if(omitFile.isDir){
			bool continuar = true;
			while(continuar){
				continuar = false;
				bool deleteThisEntry = false;
				for(auto itr = list.begin();itr!=list.end();itr++){
					const auto& file = *itr;
					if(	(file.find(omitFile.path)==0) ){
						cout<<"Omitting dir: "<<file<<endl;
						list.erase(itr);
						continuar = true;
						break;
					}
				}				
			};
		}else{
			auto itr = list.end();
			auto found = find(list.begin(), list.end(), omitFile.path);
			if(found!=itr){
				cout<<"Omitting: "<<omitFile.path<<endl;
				list.erase(found);
			}
		}
	}
}

int RHStandardExporter::Export(ExportOptions& opts, ExportResultStats& stats, ResultPackage& result){
	srand(static_cast<unsigned int>(time(0)));
	if(hashGenerator==0){
		cout<<"No se ha indicado un generador de Hash"<<endl;
		return Error_ExporterNotSet;
	}

	//Primer paso, pasar el directorio de trabajo a la ruta que se indico como rootPath
	//asi sera mas sencillo trabajar

	path exportPath(opts.exportRoothPath);
	if( !(exists(exportPath)&&is_directory(exportPath)) ){
		cout<<"No existe el directorio de origen: "<<opts.exportRoothPath<<endl;
		return Error_RootDirDoesntExist;
	}

	vector<string> fileNamesList;
	


	appendFilesToList(exportPath, fileNamesList, 0);
	stats.filesInRootDir = fileNamesList.size();
	//Eliminar archivos que no se van a esportar
	removeOmittedFromList(opts, fileNamesList);
	stats.filesExported = fileNamesList.size();

	vector<string> filenames_relativesToRoot;
	std::vector<ExportTupple> tupples;

	int pETRes = prepareExportTuples(opts, fileNamesList, filenames_relativesToRoot, tupples, stats);
	if(pETRes<0){
		return pETRes;
	}

	//Generar los hashes de los nombres completos de los paths
	bool generateHashes = true;
	HashType32 seed = rand();
	const HashType32 originalSeed = seed;
	while(generateHashes){
		
		for(auto& element:tupples){
			element.hash = hashGenerator->GenerateHash32(
				(void*)element.url.c_str(),
				element.url.length(),
				seed
			);
		}
		//hashes generados, ahora segurarnos de que no hayan colisiones
		if(doesListHasDuplicatedHashesQ(tupples)){
			seed++;
			if(seed == originalSeed){
				cout<<"ERROR: no se puede generar una tabalhash sin colisiones con el algoritmo actual"<<endl;
				return Error_TableGenerationImpossible;
			}
		}else{
			generateHashes = false;
			stats.exportSeed = seed;
		}
		
	}
	//Hasta ahora ya se han generado la lista de URLs a responder
	//Hay que ordenar la lista con respecto a los hashes generados
	std::stable_sort(
		begin(tupples),
		end(tupples),
		[] (const ExportTupple& a, const ExportTupple& b) {return a.hash < b.hash;}
	);

	

	generateFinalResult(
		opts, 
		fileNamesList,
		tupples,
		stats,
		result
	);

	//Creamos el archivo donde almacenar el resultado
	bool ioerror = false;
	ofstream file;
	file.open(opts.output, ios::out|ios::binary|ios::trunc);
	bool isOpendQ = file.is_open();
	ioerror = file.good();
	//Almacenamos el size de los datos
	int resultSize = result.Size();
	file.write((char*)&resultSize, 4);
	ioerror = file.bad();
	//Almacenamos el numero de tuplas
	int tupplesN = tupples.size();
	file.write((char*)&tupplesN, 4);
	//Almacenamos la semilla usada
	HashType32 exportSeed = stats.exportSeed;
	file.write((char*)&exportSeed, 4);
	ioerror = file.bad();
	
	file.write((char*)&stats.exportHomeFileIndex, 4);
	file.write((char*)&stats.exportErrorFileIndex, 4);



	ioerror = file.bad();
	//Y almacenamso finalmente la tabla
	file.write(result.GetData(), result.Size());
	ioerror = file.bad();
	file.close();
	
	
	return 0;
}

bool RHStandardExporter::doesListHasDuplicatedHashesQ(const std::vector<ExportTupple>& list)const{
	bool ret = false;
	for(size_t e = 0; e<list.size(); e++){
		const auto& element = list[e];
		for(size_t p = 0; p<list.size(); p++){
			const auto& listEntry = list[p];
			if(p==e){
				continue;
			}
			if(listEntry.hash==element.hash){
				ret = true;
				break;
			}
		}
	}
	return ret;;
}

int RHStandardExporter::prepareExportTuples(
	const ExportOptions& opts, 
	std::vector<std::string>& list,
	std::vector<std::string>& filenames_relativesToRoot,
	std::vector<ExportTupple>& tupples, 
	ExportResultStats& stats
)const{
	path rootPath(opts.exportRoothPath);
	rootPath = absolute(rootPath);
	auto exportRoothPath = rootPath.generic_string();
	if(exportRoothPath.back()!='/'){
		exportRoothPath+='/';
	}
	//vector<string> filenames_relativesToRoot;
	filenames_relativesToRoot.clear();
	filenames_relativesToRoot.reserve(list.size());
	for(auto file:list){
		path filePath(file);
		filePath = absolute(filePath);
		auto filePathName = filePath.generic_string();
		filenames_relativesToRoot.push_back(
			filePathName.substr(exportRoothPath.length())
		);
	}

	//buscar archivos especiales en la lista de archivos
	for( size_t e = 0; e<filenames_relativesToRoot.size(); e++){
		const auto& fileName = filenames_relativesToRoot[e];
		if(fileName==opts.homeFile){
			stats.exportHomeFileIndex = e;
			break;
		}
	}
	if(stats.exportHomeFileIndex<0){
		cout<<"No se pudo encontrar el archivo HOME: "<<opts.homeFile<<endl;
		return Error_FileNotFound;
	}
	//buscar archivos especiales en la lista de archivos
	for( size_t e = 0; e<filenames_relativesToRoot.size(); e++){
		const auto& fileName = filenames_relativesToRoot[e];
		if(fileName==opts.error404File){
			stats.exportErrorFileIndex = e;
			break;
		}
	}
	if(stats.exportHomeFileIndex<0){
		cout<<"No se pudo encontrar el archivo ERROR404: "<<opts.error404File<<endl;
		return Error_FileNotFound;
	}

	//Generar las tuplas
	tupples.clear();
	tupples.reserve(filenames_relativesToRoot.size()*2+2);
	
	for( size_t e = 0; e<filenames_relativesToRoot.size(); e++){
		const auto& fileName = filenames_relativesToRoot[e];
		ExportTupple tupple1;
		ExportTupple tupple2;
		tupple1.url = fileName;
		tupple2.url = "/"+fileName;
		tupple1.listIndex = tupple2.listIndex = e;
		tupples.push_back(tupple1);
		tupples.push_back(tupple2);
	}
	//buscar archivos especiales en la lista de archivos
	for( size_t e = 0; e<filenames_relativesToRoot.size(); e++){
		const auto& fileName = filenames_relativesToRoot[e];
		if(fileName==opts.homeFile){
			stats.exportHomeFileIndex = e;
		}
	}
	
	ExportTupple homeTupple1;
	//ExportTupple homeTupple2;
	homeTupple1.url = "/";
	//homeTupple2.url = "/"+opts.homeFile;
	//homeTupple1.listIndex = homeTupple2.listIndex = stats.exportHomeFileIndex;
	homeTupple1.listIndex = stats.exportHomeFileIndex;

	/*ExportTupple errorTupple;
	errorTupple.url = opts.error404File;
	errorTupple.listIndex = stats.exportErrorFileIndex;*/

	tupples.push_back(homeTupple1);
	//tupples.push_back(errorTupple);
	










	return 0;
}










