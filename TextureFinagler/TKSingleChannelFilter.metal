//
//  TKSingleChannelFilter.metal
//  Source Finagler
//
//  Created by C.W. Betts on 3/21/23.
//  Copyright © 2023 Mark Douma LLC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <CoreImage/CIKernelMetalLib.h>


/*
A Core Image kernel routine that computes a multiply effect.
The code looks up the source pixel in the sampler and then multiplies it by the value passed to the routine.
*/
[[stitchable]]
float4 singleChannelFilter(coreimage::sampler Image, float redScale, float greenScale, float blueScale, float alphaScale) {
	float4 originalColor, grayscaleColor;
	originalColor = coreimage::unpremultiply(sample(Image, samplerCoord(Image)));
	
	const float sum = redScale + greenScale + blueScale + alphaScale;
	
	const float newRedScale = redScale / sum;
	const float newGreenScale = greenScale / sum;
	const float newBlueScale = blueScale / sum;
	
	const float gray = originalColor.r * newRedScale +
					   originalColor.g * newGreenScale +
					   originalColor.b * newBlueScale;
					   
	grayscaleColor.rgba = float4(gray, gray, gray, 1.0);
	return coreimage::premultiply(grayscaleColor);
}
