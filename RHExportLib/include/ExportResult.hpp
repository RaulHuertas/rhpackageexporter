#ifndef RH_PACKAGER_EXPORT_RESULT_HPP
#define RH_PACKAGER_EXPORT_RESULT_HPP

#include <string>
#include <vector>
#include <memory>
#include "ExportOptions.hpp"
#include "RHExportLib.h"


struct RHEXPORTLIB_API ExportTupple{
	int listIndex;
	std::string url;
	HashType32 hash;		
	ExportTupple();
};

class RHEXPORTLIB_API ResultTupple{
public:
	//std::string responseName;
	//bool compressedQ;
	HashType32 hash;
	int position;
	//int compressedSize;
	int headerSize;
	/**Ubicacion en el paquete final*/
	int totalSize;
	//int compressedStartLocation;
	ResultTupple();
};

class RHEXPORTLIB_API ResultEntry{
public:
	//std::string responseName;
	//bool compressedQ;
	int entireSize;
	//int compressedSize;
	int headerSize;
	/**Ubicacion en el paquete final*/
	int position;
	//int compressedStartLocation;
	ResultEntry();
};


class RHEXPORTLIB_API ResultPackage{
	public:
	/**
	Su longitud es igual al numero de URLs que se pueden responder
	*/
	std::vector<ResultEntry> listOfEntries;

	std::vector<ResultTupple> listOfTupples;
	/**
	Su longitud es igual al numero de URLs que se pueden responder
	*/
	std::vector<ExportTupple> listOfURLs;
	
	
	ResultPackage();
	~ResultPackage();
	
	void setDataSize(int size);
	int& Size();
	int Size()const;
	void SetData(const char* newData, int length, int offset = 0);
	/**La longitud es la longitud completa del buffer interno*/
	void SetData(const char* newData, int offset=0);
	const char* GetData()const;
	char* GetData();

private:
	int resultSize;
	/**
	Buffer conteniendo el resultado de lempaquetamiento, incluyendo
	listOfEntries
	*/
	char* result;
};


/** Retorna el indice de la tupla que corresponde*/
int RHEXPORTLIB_API isHashInPack(HashType32 hash, const ResultPackage& pack );

void  RHEXPORTLIB_API generateHashBenchmarkTestData(
                    const ResultPackage& pack, 
                    const ExportResultStats& stats, 
                    const ExportOptions& opts 
);


void  RHEXPORTLIB_API generateBinarySearchStats(
                    const ResultPackage& pack, 
                    const ExportResultStats& stats, 
                    const ExportOptions& opts 
);


#endif //RH_PACKAGER_EXPORT_RESULT_HPP
