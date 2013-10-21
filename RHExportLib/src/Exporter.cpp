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
using namespace std;


ExportTupple::ExportTupple(){
	listIndex = -1;
	hash = static_cast<HashType32>(0);

}

ExportResultStats::ExportResultStats(){
	filesInRootDir	= 0;
	filesExported	= 0;
	exportSeed		= 0;
	exportHomeFileIndex		=	-1;
	exportErrorFileIndex	=	-1;
}

FilesToExportStats::FilesToExportStats(){
	compressedQ = false;
	originalSize = -1;
	compressedSize = -1;
	exportedSize = -1;
}




