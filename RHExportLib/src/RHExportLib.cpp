// RHExportLib.cpp : Defines the exported functions for the DLL application.
//

#ifdef WIN32
#include "stdafx.h"
#endif //WIN32
#include "RHExportLib.h"


// This is an example of an exported variable
RHEXPORTLIB_API int nRHExportLib=0;

// This is an example of an exported function.
RHEXPORTLIB_API int fnRHExportLib(void)
{
	return 42;
}

// This is the constructor of a class that has been exported.
// see RHExportLib.h for the class definition
CRHExportLib::CRHExportLib()
{
	return;
}
