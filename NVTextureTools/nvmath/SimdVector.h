// This code is in the public domain -- Ignacio Casta�o <castano@gmail.com>

//#include "Vector.h" // Vector3, Vector4
#include <NVMath/Vector.h>


// Set some reasonable defaults.
#ifndef NV_USE_ALTIVEC
#   define NV_USE_ALTIVEC NV_CPU_PPC
#endif

#ifndef NV_USE_SSE
#   if NV_CPU_X86 || NV_CPU_X86_64
#       define NV_USE_SSE 2
#   endif
#endif


#if NV_USE_ALTIVEC
#   include "SimdVector_VE.h"
#endif

#if NV_USE_SSE
#   include "SimdVector_SSE.h"
#endif
