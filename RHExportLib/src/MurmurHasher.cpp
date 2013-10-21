
using namespace std;
#include "MurmurHash3.h"
#include "MurmurHasher.hpp"



MurmurHashGenerator::MurmurHashGenerator(){

}

MurmurHashGenerator::~MurmurHashGenerator(){

}

HashType32 MurmurHashGenerator::GenerateHash32(void* input, int length, HashType32 seed){
	HashType32 result;
	MurmurHash3_x86_32(input, length, seed, &result);
	return result;
}

