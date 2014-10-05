// RHPacketServer.cpp : Defines the entry point for the console application.
//

#ifdef WIN32
    #undef UNICODE
    #define WIN32_LEAN_AND_MEAN
    #include "stdafx.h"
    #include <windows.h>
    #include <winsock2.h>
    #include <ws2tcpip.h>

    #include <winsock.h>
    #pragma comment (lib, "Ws2_32.lib")
#endif //WIN32


#define DEFAULT_BUFLEN 2048
#define DEFAULT_PORT "9797"

#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <string>
#include <atomic>
#include "MurmurHasher.hpp"
#include "ExportResult.hpp"
#include <thread>
#include <functional>

using namespace std;

#ifdef __linux
typedef int SOCKET;
#include <netdb.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#define INVALID_SOCKET -1
#define SOCKET_ERROR   -1
#define closesocket(s) close(s)
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
//typedef int socklen_t;
#endif //__linux

std::atomic_bool continuar;

struct DataInfo{
	int dataSize;
	int tupplesN;
	HashType32 seed;
	int exportHomeFileIndex;
	int exportErrorFileIndex;
	DataInfo(){
		dataSize = 0;
		tupplesN = 0;
		seed = 0;
		exportHomeFileIndex = 0;
		exportErrorFileIndex = 0;
	}
	ResultPackage pack;
};

//void handleClientConn(SOCKET ClientSocket);
void handleClientConn(SOCKET ClientSocket, HashGenerator* hasher, const DataInfo* pack ){
	int requestLength = 0;	
	const int REQUEST_MAXLEN = 8191;
	char* request = new char[REQUEST_MAXLEN+1];
	const int URL_LEN = 8191;
	char* url = new char[URL_LEN+1];
	enum SockState{
		WAITING_REQUEST,
		READING_REQUEST
	};
	socklen_t  clientNameLen = 128  ;               
	struct sockaddr clientName;
	getpeername ( ClientSocket , &clientName , &clientNameLen );
	//clientName[clientNameLen]=0;
	struct sockaddr_in* addressInternet;
	addressInternet  = (struct sockaddr_in*)&clientName;
	int clientPort = ntohs ( addressInternet->sin_port );
	//cout<<"Conexion aceptada, puerto destino: "<<clientPort<<endl;
	requestLength = 0;
	bool keepReading = true;
	int iResult = 0;
        #ifdef WIN32
	unsigned int tid =  this_thread::get_id().hash();
        #else
        std::hash<thread::id> hashStruct;
	unsigned int tid =  hashStruct(this_thread::get_id());
        #endif //WIN32
	while(keepReading){			
		if(requestLength<3){
			iResult = recv(ClientSocket, &request[0]+requestLength, 3-requestLength, 0);
		}else{
			iResult = recv(ClientSocket, &request[0]+requestLength, REQUEST_MAXLEN-requestLength, 0);
		}
			
		if (iResult > 0) {
                        #ifdef DEBUG
			printf("Bytes received: %d\n", iResult);
                        #endif  //DEBUG
			requestLength+=iResult;
			if(requestLength==3){//Comando recibido
                                request[requestLength]=0;
				if( strcmp(request, "GET") == 0){//Comando Get recibido
					//sockstate = READING_REQUEST;
				}else if( strcmp(request, "DIE") == 0 ){
					keepReading = false;
					closesocket(ClientSocket);
					printf("comando DIE recibido\n");
					ClientSocket = INVALID_SOCKET;
					continuar.store(false);
				}else{//Comando no reconocido
					keepReading = false;
					closesocket(ClientSocket);
                                        #ifdef DEBUG
					cout<<"Se ha recibido un comando que no se implementa: "<<request<<endl;;
                                        #endif //DEBUG
					ClientSocket = INVALID_SOCKET;
				}
			}
			if(requestLength>4){//Esperar final de la cabecera
				if(
					(request[requestLength-4]=='\r')&&
					(request[requestLength-3]=='\n')&&
					(request[requestLength-2]=='\r')&&
					(request[requestLength-1]=='\n')
				){
					//Fin de peticion HTTP
					request[requestLength] = 0;
					//mostrarla
					//printf("THREAD %d Se ha recibido la siguiente cabecera: \r\n", tid);
					//cout<<&request[0]<<endl;
					//y... cerrar la conexion por ahora U_U
					int urlScan = sscanf(request,"GET %s HTTP", url);
					if(urlScan==1){
						int urlLen = strlen(url);
                                                HashType32 hashGenerated = hasher->GenerateHash32(url, urlLen, pack->seed);
                                                auto index = isHashInPack(hashGenerated, pack->pack);
                                                #ifdef DEBUG
						cout<<"THREAD "<<tid<<", "<<"URL adquirida: "<<url<<endl;
						cout<<"THREAD "<<tid<<", "<<"Hash Calculado: "<<hash<<endl;
                                                cout<<"THREAD "<<tid<<", "<<"Resultado de la busqueda..."<<hash<<endl;
                                                #endif //DEBUG
						if(index>=0){
							//cout<<"THREAD "<<tid<<", "<<"Se ha encontrado una coincidencia en la tabla hash: "<<index<<endl;
							const auto& tupla = pack->pack.listOfTupples[index];
							int bytesSent = 0;
							int totalBytesSent = 0;
							while(tupla.totalSize!=totalBytesSent){
								bytesSent = send( ClientSocket, pack->pack.GetData()+tupla.position+totalBytesSent, tupla.totalSize-totalBytesSent, 0 );
								if(bytesSent == SOCKET_ERROR ){
									//cout<<"THREAD "<<tid<<", "<<"Error transmitiendo los datos de: "<<hashGenerated<<endl;
									keepReading = false;
									closesocket(ClientSocket);
									ClientSocket = INVALID_SOCKET;
									break;
								}else{
                                                                        //cout<<"THREAD "<<tid<<", "<<"Bytes sent: "<<totalBytesSent<<"/"<<tupla.totalSize<<endl;
									totalBytesSent+=bytesSent;
								}
							}
							requestLength = 0;
							//cout<<"THREAD "<<tid<<", "<<"Recurso enviado: "<<endl;
						}else{
							
							keepReading = false;
							closesocket(ClientSocket);
							//cout<<"THREAD "<<tid<<", "<<("URL no encontrada!")<<endl;
							ClientSocket = INVALID_SOCKET;
						}

					}else{
						keepReading = false;
						closesocket(ClientSocket);
						//cout<<"THREAD "<<tid<<", "<<("Falta implementar GET! \n")<<endl;
						ClientSocket = INVALID_SOCKET;
					}
						
				}
			}

		}else if(iResult==0){//Conexion finalizada
			keepReading = false;
			closesocket(ClientSocket);
			//cout<<"THREAD "<<tid<<", "<<("conexion finalizada pro el cliente\n")<<endl;
			ClientSocket = INVALID_SOCKET;
		}else{//Error de lectura
			keepReading = false;
			closesocket(ClientSocket);
			//cout<<"THREAD "<<tid<<", "<<("error de lectura\n")<<endl;
			ClientSocket = INVALID_SOCKET;
		}
			
	}
	delete [] request;
	delete [] url;	
}

int readPackageInfo(const char* filename, DataInfo& data){
    
	string fn;
	fn.append(filename);
	ifstream file;
	file.open(filename, ios::binary|ios::in );
	
	file.read((char*)&data.dataSize, 4);
	file.read((char*)&data.tupplesN, 4);
	file.read((char*)&data.seed, 4);
	file.read((char*)&data.exportHomeFileIndex, 4);
	file.read((char*)&data.exportErrorFileIndex, 4);
	data.pack.listOfTupples.clear();
	data.pack.listOfTupples.resize(data.tupplesN);
	data.pack.setDataSize(data.dataSize);
	file.read(data.pack.GetData(), data.dataSize);

	for(size_t t = 0; t<data.tupplesN; t++){
		auto& tupla = data.pack.listOfTupples[t];
		const auto rawData = data.pack.GetData();
		tupla.hash		= *((HashType32*)(rawData+0+t*4));
		tupla.position	= *((int*)(rawData+data.tupplesN*4+t*4));
		tupla.headerSize= *((int*)(rawData+data.tupplesN*8+t*4));
		tupla.totalSize	= *((int*)(rawData+data.tupplesN*12+t*4));
                cout<<"tupla "<<t<<", hash: "<<tupla.hash<<endl;
                cout<<"tupla "<<t<<", position: "<<tupla.position<<endl;
                cout<<"tupla "<<t<<", headerSize: "<<tupla.headerSize<<endl;
                cout<<"tupla "<<t<<", totalSize: "<<tupla.totalSize<<endl;
	}

	file.close();
        
        cout<<"Numero de tuplas: "<<data.tupplesN<<endl;
        cout<<"Size of files: "<<data.dataSize<<endl;
        
	return 0;
}


#ifdef WIN32
int _tmain(int argc, _TCHAR* argv[])
#else
int main(int argc, char** argv)
#endif //WIN32
{


    int iResult;
    SOCKET ListenSocket = INVALID_SOCKET;
    SOCKET ClientSocket = INVALID_SOCKET;
	struct addrinfo *result = NULL;
    struct addrinfo hints;
	continuar.store(true);
	if(argc!=2){
		cout<<"Por favor indique el nombre del archivo .rhd a usar"<<endl;
		return 0;
	}
	DataInfo pack;
	#ifdef WIN32
	readPackageInfo((char*)__argv[1], pack);
	#else
	readPackageInfo((char*)argv[1], pack);
	#endif //WIN32
	MurmurHashGenerator* hasher = new MurmurHashGenerator();

    #ifdef WIN32
	// Initialize Winsock
	WSADATA wsaData;
    iResult = WSAStartup(MAKEWORD(2,2), &wsaData);
    if (iResult != 0) {
        printf("WSAStartup failed with error: %d\n", iResult);
        return 1;
    }
    #endif //WIN32
    
    #ifdef WIN32
	ZeroMemory(&hints, sizeof(hints));
    #else
    memset(&hints, 0, sizeof(hints));
    #endif //WIN32
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
    hints.ai_flags = AI_PASSIVE;
	// Resolve the server address and port
    iResult = getaddrinfo(NULL, DEFAULT_PORT, &hints, &result);
    if ( iResult != 0 ) {
        printf("getaddrinfo failed with error: %d\n", iResult);
        #ifdef WIN32
        WSACleanup();
        #endif //WIN32
        return 1;
    }
	// Create a SOCKET for connecting to server
    ListenSocket = socket(result->ai_family, result->ai_socktype, result->ai_protocol);
    if (ListenSocket == INVALID_SOCKET) {

        freeaddrinfo(result);
        cout<<"Error creando el socket"<<endl;
        #ifdef WIN32
        printf("socket failed with error: %ld\n", WSAGetLastError());
        WSACleanup();
        #endif //WIN32
        return 1;
    }
    int one = 1; 
    setsockopt(ListenSocket, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));
	// Setup the TCP listening socket
    iResult = ::bind( ListenSocket, result->ai_addr, (int)result->ai_addrlen);
    if (iResult == SOCKET_ERROR) {

        freeaddrinfo(result);
        cout<<"Error haciendo el bind:"<<iResult<<", errno: "<<errno<<endl;
        closesocket(ListenSocket);
        #ifdef WIN32
        printf("bind failed with error: %d\n", WSAGetLastError());
        WSACleanup();
        #endif //WIN32
        return 1;
    }
    freeaddrinfo(result);
	
	
	//SockState sockstate = WAITING_REQUEST;
	cout<<"Se empieza ha escuchar comunicaciones por el puerto"<<DEFAULT_PORT<<endl;
	while(continuar.load()){
		iResult = listen(ListenSocket, SOMAXCONN);
		if (iResult == SOCKET_ERROR) {
                    cout<<"Error en 'listen'"<<endl;
                    #ifdef WIN32
                                printf("listen failed with error: %d\n", WSAGetLastError());
                    #endif //WIN32
			break;
		}
		//cout<<"Intento de conexion recibido"<<endl;
		ClientSocket = accept(ListenSocket, NULL, NULL);
		if (ClientSocket == INVALID_SOCKET) {
                    cout<<"Error en 'accept'"<<endl;
            #ifdef WIN32
			printf("accept failed with error: %d\n", WSAGetLastError());				
            #endif //WIN32
			break;
		}
		//std::thread([](SOCKET c, HashGenerator* h, const DataInfo* p){handleClientConn(c, h, p);}, ClientSocket, hasher, &pack ).detach();
		std::thread(handleClientConn, ClientSocket, hasher, &pack ).detach();
	}

	
	//closesocket(ClientSocket);
	closesocket(ListenSocket);	
    #ifdef WIN32
	WSACleanup();
    #endif //WIN32
	return 0;



}


