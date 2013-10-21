#ifndef EXPORTER_HPP
#define EXPORTER_HPP

#include "RHExportLib.h"
#include "ExportOptions.hpp"
#include "ExportResult.hpp"
#include <vector>
#include <string>



class RHEXPORTLIB_API HashGenerator{
public:
	virtual HashType32 GenerateHash32(void* input, int length, HashType32 seed) = 0;	
};

class RHEXPORTLIB_API RHExporterInterface{


public:
	static const int Error_RootDirDoesntExist = -2;
	static const int Error_FileNotFound = -3;
	static const int Error_ExporterNotSet = -5;
	static const int Error_TableGenerationImpossible = -6;

	virtual int Export(ExportOptions& opts, ExportResultStats& stats, ResultPackage& result) = 0;
	virtual void SetHashGenerator(HashGenerator* generator) = 0;
	

};


class RHEXPORTLIB_API RHStandardExporter: public RHExporterInterface{
private:
	struct mypair{
		std::string path;
		bool isDir;
		mypair(){
			isDir = false;
		}
	};

	
	HashGenerator* hashGenerator;
public:
	RHStandardExporter();
	
	~RHStandardExporter();


	int Export(ExportOptions& opts, ExportResultStats& stats, ResultPackage& result);
	void SetHashGenerator(HashGenerator* generator);

private:
	/**
	Se encarga de eleiminar los archivos y directorios a omitir
	de la lista obtenido a partir del directorio raiz
	*/
	void removeOmittedFromList(
		const ExportOptions& opts, 
		std::vector<std::string>& actualFilesList
	)const;

	/**
	Preparar los paths a usar para la exportacion final
	Genera tuplas para:
	- recurso1.html
	- /recurso1.html
	- recurso2.html
	- ...
	- /      ->A partir del HomeFile
	- 404 Responde -> a partir del Error404File
	*/
	int prepareExportTuples(
		const ExportOptions& opts, 
		std::vector<std::string>& list,
		std::vector<std::string>& filenames_relativesToRoot,
		std::vector<ExportTupple>& tupples, 
		ExportResultStats& stats
	)const;

	bool doesListHasDuplicatedHashesQ(const std::vector<ExportTupple>& list)const;

	void generateFinalResult(
		ExportOptions& opts, 
		std::vector<std::string>& filenames,
		std::vector<ExportTupple>& tupples, 
		ExportResultStats& stats, 
		ResultPackage& result)const;


};

#endif //EXPORTER_HPP









