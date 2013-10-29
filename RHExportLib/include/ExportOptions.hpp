#ifndef EXPORTER_OPTIONS_HPP
#define EXPORTER_OPTIONS_HPP
#include <iostream>
#include <string>
#include <vector>
#include <cstdint>
#include "RHExportLib.h"
typedef std::uint32_t HashType32;

class RHEXPORTLIB_API ExportOptions{
public:
	std::string exportRoothPath;
	std::string output;
	std::vector<std::string> omitFiles;
	std::string homeFile;
	std::string error404File;
	std::string exportStatsResultFile;
	std::string server;
	std::string host;
        std::string HashGenerationBenchMarkFile;
	int URLLengthLimit;
	int URLLimitDetected;
	ExportOptions();
};

struct RHEXPORTLIB_API FilesToExportStats{
	std::string fileName;
	int compressedQ;
	int originalSize;
	int compressedSize;
	int exportedSize;
	FilesToExportStats();
};

class RHEXPORTLIB_API ExportResultStats{
public:
	int filesInRootDir;
	int filesExported;
	
	std::vector<int> originalFilesSize;
	std::vector<int> exportedFilesSize;
	//La semilla con que se generaron los HASHs
	//de los archivos exportados
	HashType32 exportSeed;
	int exportHomeFileIndex;
	int exportErrorFileIndex;
	ExportResultStats();
};

int RHEXPORTLIB_API analizeOptionsFile(std::string fileName, ExportOptions& opts );

#endif //EXPORTER_OPTIONS_HPP
