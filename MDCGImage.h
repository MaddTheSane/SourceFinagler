//
//  MDCGImage.h
//  Source Finagler
//
//  Created by Mark Douma on 9/25/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#include <ApplicationServices/ApplicationServices.h>
#import <Foundation/Foundation.h>

#ifndef __private_extern
#define __private_extern __attribute__((visibility("hidden")))
#endif


#ifdef __cplusplus
extern "C" {
#endif

__private_extern CGImageRef __nullable MDCGImageCreateCopyWithSize(CGImageRef __nonnull imageRef, CGSize size) CF_RETURNS_RETAINED;
	
#ifdef __cplusplus
}
#endif
	