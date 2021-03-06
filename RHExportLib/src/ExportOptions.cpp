#include "ExportOptions.hpp"
#include <iostream>
#include <fstream>
#include <cstdio>
#include <cstring>

using namespace std;

static const int StringReadLimit = 2048;

ExportOptions::ExportOptions(){
	URLLengthLimit = 256;
	URLLimitDetected = 0;
	homeFile = "index.html";
	error404File = "404.html";
        cache_Usar = false;
}

int analizeLine(char* line, ExportOptions& opts ){
	if(line[0]=='#'){
		//comentario, saltarlo
		return 0;
	}
	char scanResult1[StringReadLimit];
        char scanResult2[StringReadLimit];
        int scanResulti;
	//Ahora probar el resto de las reglas
	while(true){//no es un bucle ;)
		if(std::sscanf(line, "Output %s", scanResult1)==1){
			opts.output.clear(); 
			opts.output.append(scanResult1);			
			break;
		}
		if(std::sscanf(line, "Omit %s", scanResult1)==1){
			string omitRule; 
			omitRule.append(scanResult1);
			opts.omitFiles.push_back(omitRule);
			break;
		}
		if(std::sscanf(line, "ExportRootPath %s", scanResult1)==1){
			opts.exportRoothPath.clear(); 
			opts.exportRoothPath.append(scanResult1);
			break;
		}
                if(std::sscanf(line, "HashGenerationBenchMarkFile %s", scanResult1)==1){
			opts.HashGenerationBenchMarkFile.clear(); 
			opts.HashGenerationBenchMarkFile.append(scanResult1);
                        //cout<<"HashGenerationBenchMarkFile found: "<<opts.HashGenerationBenchMarkFile<<endl;
			break;
		}
                
                if(std::sscanf(line, "BenchMarkFile_VHDL %s", scanResult1)==1){
			opts.HashGenerationBenchMarkFile_VHDL_Code_Array.clear(); 
			opts.HashGenerationBenchMarkFile_VHDL_Code_Array.append(scanResult1);
                        //cout<<"HashGenerationBenchMarkFileVCA found: "<<opts.HashGenerationBenchMarkFile_VHDL_Code_Array<<endl;
			break;
		}
                
		if(std::sscanf(line, "HomeFile %s", scanResult1)==1){
			opts.homeFile.clear(); 
			opts.homeFile.append(scanResult1);
			break;
		}
		if(std::sscanf(line, "Error404File %s", scanResult1)==1){
			opts.error404File.clear(); 
			opts.error404File.append(scanResult1);
			break;
		}
		if(std::sscanf(line, "Server %s", scanResult1)==1){
			opts.server.clear(); 
			opts.server.append(scanResult1);
			break;
		}
		if(std::sscanf(line, "Host %s", scanResult1)==1){
			opts.host.clear(); 
			opts.host.append(scanResult1);
			break;
		}
                if(std::sscanf(line, "CacheControl %s", scanResult1)==1){
                    if( (strcmp(scanResult1,"No")==0) || (strcmp(scanResult1,"no")==0) ){
                        opts.cache_Usar = false;
                    }else if( (strcmp(scanResult1,"Yes")==0) || (strcmp(scanResult1,"yes")==0) ){
                        if( std::sscanf(line, "CacheControl %s %s %d", scanResult1,scanResult2,&scanResulti)==3 ){
                            opts.cache_Usar = true;
                            opts.cache_access.clear();opts.cache_access.assign(scanResult2);
                            opts.cache_duration = scanResulti;
                        }
                    }
		}
		break;
	}


	return 0;
}

int analizeOptionsFile(std::string fileName, ExportOptions& opts ){
	cout<<"Archivo a abrir: "<<fileName<<endl;
	ifstream file;
	file.open(fileName);
	if(file.bad()){
		file.close();
		cout<<"Hay un problema con el archivo"<<endl;
		return -1;
	}
	if(!file.is_open()){
		file.close();
		cout<<"No se pudo abrir el archivo"<<endl;
		return -1;
	}
	char line[StringReadLimit];
	int ret = 0;
	while(  !file.eof() && !file.bad() ){
		file.getline(line, StringReadLimit);
		ret = analizeLine(line, opts);
		//cout<<"Linea leida: "<<line<<endl;
	}
	file.close();
	return 0;
}






