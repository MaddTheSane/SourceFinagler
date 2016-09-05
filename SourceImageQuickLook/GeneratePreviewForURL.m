#include <ApplicationServices/ApplicationServices.h>
#include <QuickLook/QuickLook.h>
#include "GenerateThumbnails.h"
#import <Cocoa/Cocoa.h>
#import <TextureKit/TextureKit.h>


/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */
#ifdef __cplusplus
extern "C" {
#endif
	
	
#define MD_DEBUG 0
	
	
OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options) {
@autoreleasepool {
	NSString *nsContentUTI = (__bridge NSString *)contentTypeUTI;
	NSURL *nsUrl = (__bridge NSURL*)url;
	
	if (![nsContentUTI isEqualToString:TKVTFType] &&
		![nsContentUTI isEqualToString:TKDDSType] &&
		![nsContentUTI isEqualToString:TKSFTextureImageType]) {
		
		NSLog(@"SourceImage.qlgenerator; GeneratePreviewForURL(): contentTypeUTI != VTF or DDS or SFTI; (contentTypeUTI == %@)", contentTypeUTI);
		return noErr;
	}
	
#if MD_DEBUG
	NSLog(@"GeneratePreviewForURL(): %@", [nsUrl path]);
#endif
	
	NSData *fileData = [[NSData alloc] initWithContentsOfURL:nsUrl options:NSDataReadingMappedIfSafe error:NULL];
	if (fileData == nil) {
		NSLog(@"SourceImage.qlgenerator; GeneratePreviewForURL(): fileData == nil for url == %@", url);
		return noErr;
	}
	CGImageRef imageRef = NULL;
	
	if ([nsContentUTI isEqualToString:TKVTFType]) {
		imageRef = [[TKVTFImageRep imageRepWithData:fileData] CGImage];
	} else if ([nsContentUTI isEqualToString:TKDDSType]) {
		imageRef = [[TKDDSImageRep imageRepWithData:fileData] CGImage];
	} else if ([nsContentUTI isEqualToString:TKSFTextureImageType]) {
		TKImage *tkImage = [[TKImage alloc] initWithData:fileData firstRepresentationOnly:NO];
		NSArray<TKImageRep*> *aTKImageReps;
		if (tkImage) {
			
			TKImageRep *tkImageRep = nil;
			
			if ([tkImage sliceCount]) {
				
				
			} else if ([tkImage faceCount] && [tkImage frameCount]) {
				
				aTKImageReps = [tkImage representationsForFaceIndexes:[tkImage firstFaceIndexSet]
														 frameIndexes:[tkImage firstFrameIndexSet]
														mipmapIndexes:[tkImage firstMipmapIndexSet]];
				
				tkImageRep = aTKImageReps.firstObject;
			} else if ([tkImage faceCount]) {
				aTKImageReps = [tkImage representationsForFaceIndexes:[tkImage firstFaceIndexSet]
														mipmapIndexes:[tkImage firstMipmapIndexSet]];
				
				tkImageRep = aTKImageReps.firstObject;
			} else if ([tkImage frameCount]) {
				aTKImageReps = [tkImage representationsForFrameIndexes:[tkImage firstFrameIndexSet]
														 mipmapIndexes:[tkImage firstMipmapIndexSet]];
				
				tkImageRep = aTKImageReps.firstObject;
			} else {
				if ([tkImage mipmapCount]) {
					tkImageRep = [tkImage representationForMipmapIndex:0];
				}
			}
			
			imageRef = [tkImageRep CGImage];
		}
	}
	
	if (imageRef == NULL) {
		NSLog(@"SourceImage.qlgenerator; GeneratePreviewForURL(): MDCGImageCreateWithContentsOfFile() returned NULL for file %@", [nsUrl path]);
		return noErr;
	}
	
#if MD_DEBUG
	NSLog(@"GeneratePreviewForURL(): created imageRef");
#endif
	
	CGContextRef cgContext = QLPreviewRequestCreateContext(preview, CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), true, NULL);
	if (cgContext) {
		CGContextSaveGState(cgContext);
		CGContextDrawImage(cgContext, CGRectMake(0.0, 0.0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
		CGContextRestoreGState(cgContext);
		QLPreviewRequestFlushContext(preview, cgContext);
		CGContextRelease(cgContext);
	}
	
#if MD_DEBUG
	NSLog(@"GeneratePreviewForURL(): drew preview request");
#endif
	return noErr;
}
}
	
void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview) {
//	NSLog(@"SourceImage.qlgenerator; CancelPreviewGeneration()");
	
    // implement only if supported
}


#ifdef __cplusplus
}
#endif

