#include "ExportOptions.hpp"
#include "Exporter.hpp"
#include "MurmurHasher.hpp"
#include "ExportResult.hpp"
#include <memory>
using namespace std;



int main(int argc, char** argv){

	if(argc!=2){
		cout<<"Para usar este programa, por favor indique el archivo de descripcion"<<endl;
		return 0;
	}
	ExportOptions opts;
	int result = analizeOptionsFile(argv[1], opts);
	if(result!=0){
		cout<<"Hubo un error interpretando el archivo de construccion"<<endl;
		return result;
	}

	RHExporterInterface* exporter = new RHStandardExporter;
	HashGenerator* hashGenerator = new MurmurHashGenerator;
	exporter->SetHashGenerator(hashGenerator);

	ExportResultStats resultStats;
	ResultPackage finalResult;
	int exportResult = exporter->Export(opts, resultStats, finalResult);
	if(exportResult!=0){
		cout<<"Hubo un error interpretando el archivo de construccion"<<endl;
		delete exporter;
		return result;
	}
        
        generateHashBenchmarkTestData(finalResult, resultStats, opts);
        generateBinarySearchStats(finalResult, resultStats, opts);
        
	delete hashGenerator;
	delete exporter;

	cout<<"Resultados de la exportacion:"<<endl;
	cout<<"    Numero de archivos en la raiz: "<<resultStats.filesInRootDir<<endl;
	cout<<"    Numero de archivos exportados: "<<resultStats.filesExported<<endl;

	return 0;

}






