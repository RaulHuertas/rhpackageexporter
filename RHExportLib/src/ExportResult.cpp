#include "ExportResult.hpp"
#include <string.h>

ResultTupple::ResultTupple(){
	hash = 0;
	position = 0;
	headerSize = 0;
	totalSize = 0;
}

ResultEntry::ResultEntry(){
	entireSize = 0;
	headerSize = 0;
	position = 0;
}

ResultPackage::ResultPackage(){
	result = nullptr;
	resultSize = 0;
}

ResultPackage::~ResultPackage(){
	if (result != nullptr)
	{
		delete [] result;
	}
}

void ResultPackage::setDataSize(int size){
	if (result != nullptr)
	{
		delete [] result;
	}
	result = new char[size];
	resultSize = size;
}

int& ResultPackage::Size(){
	return resultSize;
}

int ResultPackage::Size()const{
	return resultSize;
}

void ResultPackage::SetData(const char* newData, int length, int offset){
	memcpy(result+offset, newData, length);
}

void ResultPackage::SetData(const char* newData, int offset){
	memcpy(result+offset, newData, Size());
}

const char* ResultPackage::GetData()const{
	return result;
}

char* ResultPackage::GetData(){
	return result;
}

int isHashInPack(HashType32 hash, const ResultPackage& pack ){
	int ret = -1;

	for(int t = 0;t<pack.listOfTupples.size(); t++){
		const auto& e = pack.listOfTupples[t];
		if(e.hash==hash){
			ret = t;
			break;
		}
	}

	return ret;
}



