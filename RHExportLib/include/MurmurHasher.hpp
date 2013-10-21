#include "Exporter.hpp"
#include "RHExportLib.h"

class RHEXPORTLIB_API MurmurHashGenerator: public HashGenerator{
public:
	MurmurHashGenerator();
	~MurmurHashGenerator();

	HashType32 GenerateHash32(void* input, int length, HashType32 seed);




};





