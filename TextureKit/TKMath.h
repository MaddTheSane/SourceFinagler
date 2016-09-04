//
//  TKMath.h
//  Source Finagler
//
//  Created by C.W. Betts on 9/3/16.
//
//

#ifndef TKMath_h
#define TKMath_h

#include <GLKit/GLKit.h>

typedef GLKVector2 TKVector2;
typedef GLKVector3 TKVector3;
typedef GLKVector4 TKVector4;

typedef GLKMatrix2 TKMatrix2;
typedef GLKMatrix3 TKMatrix3;
typedef GLKMatrix4 TKMatrix4;

static inline TKVector2 TKVector2Make(float s, float t)
{
	//return GLKVector2Make(x, y);
	GLKVector2 vec2 = {s, t};
	return vec2;
}

static inline TKVector3 TKVector3Make(float x, float y, float z)
{
	//return GLKVector3Make(x, y, z);
	GLKVector3 vec3 = {x, y, z};
	return vec3;
}

#define TKMatrix4Identity GLKMatrix4Identity

#define TKVertexAttribPosition GLKVertexAttribPosition
#define TKVertexAttribNormal GLKVertexAttribNormal
#define TKVertexAttribColor GLKVertexAttribColor
#define TKVertexAttribTexCoord0 GLKVertexAttribTexCoord0
#define TKVertexAttribTexCoord1 GLKVertexAttribTexCoord1

#endif /* TKMath_h */
