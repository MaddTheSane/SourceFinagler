//
//  HLSpotlightMain.h
//  Source Finagler
//
//  Created by C.W. Betts on 9/4/16.
//
//

#ifndef HLSpotlightMain_h
#define HLSpotlightMain_h

#include <CoreFoundation/CoreFoundation.h>

#ifndef __private_extern
#define __private_extern __attribute__((visibility("hidden")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

__private_extern Boolean GetMetadataForFile(void *thisInterface, CFMutableDictionaryRef attributes, CFStringRef contentTypeUTI, CFStringRef pathToFile);

#ifdef __cplusplus
}
#endif

#endif /* HLSpotlightMain_h */
