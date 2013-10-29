#include "Exporter.hpp"
#include <vector>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <ctime> 
#include <boost/algorithm/string/predicate.hpp>

using namespace std;

void RHStandardExporter::generateFinalResult(
	ExportOptions& opts, 
	std::vector<std::string>& filenames,
	std::vector<ExportTupple>& tupples, 
	ExportResultStats& stats, 
	ResultPackage& result
)const{

	//Para guardar las estadisticas
	stats.originalFilesSize.resize(filenames.size());
	stats.exportedFilesSize.resize(filenames.size());
	result.listOfEntries.resize(filenames.size());
	result.listOfTupples.resize(tupples.size());
        result.listOfURLs = tupples;
	struct ResultPack{
		int pos;
		int size;
		char* filesContent;
		string header;
	};

	vector<ResultPack> packs;
	packs.resize(filenames.size());
	
	for(size_t i = 0; i<filenames.size(); i++){
		const auto& fileName = filenames[i];
		auto& pack = packs[i];		
		ifstream file (fileName, ios::in|ios::binary|ios::ate);
		if (file.is_open()){
			pack.size = static_cast<int>(file.tellg());
			pack.filesContent = new char[pack.size];
			file.seekg (0, ios::beg);
			file.read (pack.filesContent, pack.size);
			file.close();
			stats.originalFilesSize[i] = pack.size;
		}
		//Ya se tiene el paquete en memoria
		//agregarle la cabecera		
	}

	int tupplesTableSize = sizeof(int)*4*tupples.size();//Valor inicial
	int nextPos = tupplesTableSize;//Espacio para las entradas de las 'entries'
	nextPos+=0x03U;//Para que el primer paquete
	nextPos&=~0x03U;//Este e una posicion 4-aligned
	const int originalPos = nextPos;
	//int packageSize = 0;//No incluye el size de la tabla de tupples


	//Obtener metadatos que agregar como resultado de las consultas HTTP
	time_t rawtime;
	struct tm * timeinfo;
	char dateStringBuffer[200];
	time(&rawtime);
	timeinfo = localtime(&rawtime);
	strftime( dateStringBuffer, 200,  "%a %d %b %Y %H:%M:%S %Z", timeinfo );
	const string ResponseTypeOK = "HTTP/1.1 200 OK";
	const string ResponseTypeERROR = "HTTP/1.1 404 Not Found";
	const string Server = "Server: "+opts.server+"\r\n";
	const string LastModified =string( "Last-Modified: ")+dateStringBuffer+"\r\n";

	for(size_t i = 0; i<filenames.size(); i++){
		const auto& fileName = filenames[i];
		auto& pack = packs[i];
		string ContentType;//Se trata de inferir el tipo de contenido
		if(boost::algorithm::ends_with(fileName,".html")){
			ContentType = "Content-Type: text/html";
		}else if(boost::algorithm::ends_with(fileName,".jpg")){
			ContentType = "Content-Type: image/jpeg";
		}else if(boost::algorithm::ends_with(fileName,".png")){
			ContentType = "Content-Type: image/png";
		}else if(boost::algorithm::ends_with(fileName,".js")){
			ContentType = "Content-Type: application/javascript";
		}else if(boost::algorithm::ends_with(fileName,".css")){
			ContentType = "Content-Type: text/css";
		}else if(boost::algorithm::ends_with(fileName,".txt")){
			ContentType = "Content-Type: text/plain";
		}else if(boost::algorithm::ends_with(fileName,".mpeg")){
			ContentType = "Content-Type: video/mpeg";
		}else if(boost::algorithm::ends_with(fileName,".mp4")){
			ContentType = "Content-Type: video/mp4";
		}else if(boost::algorithm::ends_with(fileName,".mov")){
			ContentType = "Content-Type: video/quicktime";
		}else if(boost::algorithm::ends_with(fileName,".flv")){
			ContentType = "Content-Type: video/x-flv";
		}else if(boost::algorithm::ends_with(fileName,".mp3")){
			ContentType = "Content-Type: audio/mpeg";
		}else if(boost::algorithm::ends_with(fileName,".ogg")){
			ContentType = "Content-Type: audio/ogg";
		}else if(boost::algorithm::ends_with(fileName,".gif")){
			ContentType = "Content-Type: image/gif";
		}else if(boost::algorithm::ends_with(fileName,".tiff")){
			ContentType = "Content-Type: image/tiff";
		}else if(boost::algorithm::ends_with(fileName,".wav")){
			ContentType = "Content-Type: audio/wav";
		}
		string ContentLength = "Content-Length: "+std::to_string(pack.size);
		
		//Sumar todas las cabeceras
		string& Header = pack.header;
		Header = ((i==stats.exportErrorFileIndex)?ResponseTypeERROR:ResponseTypeOK)+"\r\n";
		Header+=Server;
		Header+=LastModified;
		if(ContentType.length()>0){
			Header+=(ContentType+"\r\n");
		}
		Header+=ContentLength+"\r\n";
		Header+="\r\n";//FIN de cabecera
		//cout<<"HEADER de archivo "<<fileName<<": "<<endl;
		//cout<<Header<<endl;
		//cout<<"FIN DE HEADER\r\n\r\n"<<endl;
		result.listOfEntries[i].entireSize = Header.length()+pack.size;
		result.listOfEntries[i].headerSize = Header.length();
		result.listOfEntries[i].position = nextPos;
		stats.exportedFilesSize[i] = result.listOfEntries[i].entireSize;
		pack.pos = nextPos;
		nextPos+=stats.exportedFilesSize[i];
		nextPos+=0x03U;
		nextPos&=~0x03U;
	}

	//int packageDataSize = nextPos-originalPos;
	result.setDataSize(nextPos);
	//Copiar la tabla...
	for(size_t i = 0; i<tupples.size(); i++){
		
		const auto& tupple = tupples[i];
		const auto& entry = result.listOfEntries[tupple.listIndex];
		auto& tuppleResult = result.listOfTupples[i];
		tuppleResult.hash = tupple.hash;
		tuppleResult.position = entry.position;
		tuppleResult.headerSize = entry.headerSize;
		tuppleResult.totalSize = entry.entireSize;
		result.SetData( 
			(char*)&tuppleResult.hash,
			4,
			0+i*4
		);
		result.SetData( 
			(char*)&tuppleResult.position,
			4,
			4*tupples.size()+i*4
		);
		result.SetData( 
			(char*)&tuppleResult.headerSize,
			4,
			8*tupples.size()+i*4
		);
		result.SetData( 
			(char*)&tuppleResult.totalSize,
			4,
			12*tupples.size()+i*4
		);


		const auto& fileName = filenames[tupple.listIndex];
		auto& pack = packs[tupple.listIndex];

	}
	//..y los resultados  a la tabla
	//int writePos = originalPos;
	for(size_t f = 0; f<filenames.size(); f++){
		const auto& pack = packs[f];
		result.SetData( 
			pack.header.c_str(),
			pack.header.size(),
			pack.pos
		);
		//writePos+=pack.header.size();
		result.SetData( 
			pack.filesContent,
			pack.size,
			pack.pos+pack.header.size()
		);
		//writePos+=pack.size;
	}
	
	//Abrir archivo de salida para guardar el contenido

	
}


