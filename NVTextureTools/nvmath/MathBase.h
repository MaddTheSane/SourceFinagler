// This code is in the public domain -- castanyo@yahoo.es

#pragma once
#ifndef NV_MATH_BASE_H
#define NV_MATH_BASE_H

#include <NVCore/NVCore.h>
#include <NVMath/MathDefines.h>

#include <math.h>
#include <limits.h> // INT_MAX

#if NV_OS_WIN32 || NV_OS_XBOX
#include <float.h>
#endif

/*
#define SQ(r)               ((r)*(r))

#define SIGN_BITMASK        0x80000000

/// Integer representation of a floating-point value.
#define IR(x)               ((uint32 &)(x))

/// Absolute integer representation of a floating-point value
#define AIR(x)              (IR(x) & 0x7fffffff)

/// Floating-point representation of an integer value.
#define FR(x)               ((float&)(x))

/// Integer-based comparison of a floating point value.
/// Don't use it blindly, it can be faster or slower than the FPU comparison, depends on the context.
#define IS_NEGATIVE_FLOAT(x) (IR(x)&SIGN_BITMASK)
*/


inline double sqrt_assert(const double f)
{
    nvDebugCheck(f >= 0.0f);
    return sqrt(f);
}

inline float sqrtf_assert(const float f)
{
    nvDebugCheck(f >= 0.0f);
    return sqrtf(f);
}

inline double acos_assert(const double f)
{
    nvDebugCheck(f >= -1.0f && f <= 1.0f);
    return acos(f);
}

inline float acosf_assert(const float f)
{
    nvDebugCheck(f >= -1.0f && f <= 1.0f);
    return acosf(f);
}

inline double asin_assert(const double f)
{
    nvDebugCheck(f >= -1.0f && f <= 1.0f);
    return asin(f);
}

inline float asinf_assert(const float f)
{
    nvDebugCheck(f >= -1.0f && f <= 1.0f);
    return asinf(f);
}

// Replace default functions with asserting ones.
#define sqrt sqrt_assert
#define sqrtf sqrtf_assert
#define acos acos_assert
#define acosf acosf_assert
#define asin asin_assert
#define asinf asinf_assert


namespace nv
{
    inline float toRadian(float degree) { return degree * (PI / 180.0f); }
    inline float toDegree(float radian) { return radian * (180.0f / PI); }

    inline bool equal(const float f0, const float f1, const float epsilon = NV_EPSILON)
    {
        return fabs(f0-f1) <= epsilon;
    }

    inline bool isZero(const float f, const float epsilon = NV_EPSILON)
    {
        return fabs(f) <= epsilon;
    }

    inline bool isFinite(const float f)
    {
#if NV_OS_WIN32 || NV_OS_XBOX
        return _finite(f) != 0;
#elif NV_OS_DARWIN || NV_OS_FREEBSD
        return isfinite(f);
#elif NV_OS_LINUX
        return finitef(f);
#else
#   error "isFinite not supported"
#endif
        //return std::isfinite (f);
        //return finite (f);
    }

    inline bool isNan(const float f)
    {
#if NV_OS_WIN32 || NV_OS_XBOX
        return _isnan(f) != 0;
#elif NV_OS_DARWIN || NV_OS_FREEBSD
        return isnan(f);
#elif NV_OS_LINUX
        return isnanf(f);
#else
#   error "isNan not supported"
#endif
    }

    inline uint log2(uint i)
    {
        uint value = 0;
        while( i >>= 1 ) {
            value++;
        }
        return value;
    }

    inline float log2f(float x)
    {
        nvCheck(x >= 0);
        return logf(x) / logf(2.0f);
    }

    inline float lerp(float f0, float f1, float t)
    {
        const float s = 1.0f - t;
        return f0 * s + f1 * t;
    }

    inline float square(float f) { return f * f; }
    inline int square(int i) { return i * i; }

    inline float cube(float f) { return f * f * f; }
    inline int cube(int i) { return i * i * i; }

    // @@ Float to int conversions to be optimized at some point. See:
    // http://cbloomrants.blogspot.com/2009/01/01-17-09-float-to-int.html
    // http://www.stereopsis.com/sree/fpu2006.html
    // http://assemblyrequired.crashworks.org/2009/01/12/why-you-should-never-cast-floats-to-ints/
    // http://chrishecker.com/Miscellaneous_Technical_Articles#Floating_Point
    inline int iround(float f)
    {
        return int(floorf(f + 0.5f));
    }

    inline int ifloor(float f)
    {
        return int(floorf(f));
    }

    inline int iceil(float f)
    {
        return int(ceilf(f));
    }

    inline float frac(float f)
    {
        return f - floor(f);
    }

    inline float fround(float f)
    {
        // @@ Do something better.
        return float(iround(f));
    }
    // Eliminates negative zeros from a float array.
    inline void floatCleanup(float * fp, int n)
    {
        nvDebugCheck(isFinite(*fp));
        for (int i = 0; i < n; i++) {
            union { float f; uint32 i; } x = { fp[i] };
            if (x.i == 0x80000000) fp[i] = 0.0f;
        }
    }


} // nv

#endif // NV_MATH_BASE_H
