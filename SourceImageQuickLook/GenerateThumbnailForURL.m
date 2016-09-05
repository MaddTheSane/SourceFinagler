#include <ApplicationServices/ApplicationServices.h>
#include <QuickLook/QuickLook.h>
#include "GenerateThumbnails.h"
#import <Cocoa/Cocoa.h>
#import "MDCGImage.h"
#import <TextureKit/TextureKit.h>


/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */
	
	
#define MD_DEBUG 0
	

	
OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxImageSize) {
@autoreleasepool {
	NSString *nsContentUTI = (__bridge NSString *)contentTypeUTI;
	NSURL *nsUrl = (__bridge NSURL*)url;
	
	if (![nsContentUTI isEqualToString:TKVTFType] &&
		![nsContentUTI isEqualToString:TKDDSType] &&
		![nsContentUTI isEqualToString:TKSFTextureImageType]) {
		
		NSLog(@"SourceImage.qlgenerator; GenerateThumbnailForURL(): contentTypeUTI != VTF or DDS or SFTI; (contentTypeUTI == %@)", contentTypeUTI);
		return noErr;
	}
	
#if MD_DEBUG
	NSLog(@"GenerateThumbnailForURL(): %@", [(NSURL *)url path]);
#endif
	
	NSData *imageData = [[NSData alloc] initWithContentsOfURL:nsUrl];
	
	if (imageData == nil || [imageData length] < sizeof(OSType)) {
		NSLog(@"GenerateThumbnailForURL(): data %@ for file == %@", (imageData == nil ? @"== nil" : @"length < 4"), [nsUrl path]);
		return noErr;
	}
	
	OSType magic = 0;
	[imageData getBytes:&magic length:sizeof(magic)];
	magic = NSSwapBigIntToHost(magic);
	
	if (magic == TKHTMLErrorMagic) {
		NSLog(@"GenerateThumbnailForURL(): file at path \"%@\" appears to be an ERROR 404 HTML file rather than a valid VTF", [nsUrl path]);
		return noErr;
	}
	
	CGImageRef imageRef = NULL;
	
	if ([nsContentUTI isEqualToString:TKVTFType]) {
		imageRef = [[TKVTFImageRep imageRepWithData:imageData] CGImage];
	} else if ([nsContentUTI isEqualToString:TKDDSType]) {
		imageRef = [[TKDDSImageRep imageRepWithData:imageData] CGImage];
	} else if ([nsContentUTI isEqualToString:TKSFTextureImageType]) {
		TKImage *tkImage = [[TKImage alloc] initWithData:imageData firstRepresentationOnly:NO];
		NSArray<TKImageRep*> *aTKImageReps;
		if (tkImage) {
			TKImageRep *tkImageRep = nil;
			
			if ([tkImage sliceCount]) {
				//TODO: implement?
			} else if ([tkImage faceCount] && [tkImage frameCount]) {
				aTKImageReps = [tkImage
								representationsForFaceIndexes:[tkImage firstFaceIndexSet]
								frameIndexes:[tkImage firstFrameIndexSet]
								mipmapIndexes:[tkImage firstMipmapIndexSet]];

				tkImageRep = aTKImageReps.firstObject;
			} else if ([tkImage faceCount]) {
				aTKImageReps = [tkImage
								representationsForFaceIndexes:[tkImage firstFaceIndexSet]
								mipmapIndexes:[tkImage firstMipmapIndexSet]];
				
				tkImageRep = aTKImageReps.firstObject;
			} else if ([tkImage frameCount]) {
				aTKImageReps = [tkImage
								representationsForFrameIndexes:[tkImage firstFrameIndexSet]
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
		NSLog(@"SourceImage.qlgenerator; GenerateThumbnailForURL(): MDCGImageCreateWithData() returned NULL for file %@", [nsUrl path]);
		return noErr;
	}
	
#if MD_DEBUG
	NSLog(@"GenerateThumbnailForURL(): created imageRef");
#endif
	
	CGSize theMaxImageSize = QLThumbnailRequestGetMaximumSize(thumbnail);
	
	if (CGImageGetWidth(imageRef) > theMaxImageSize.width || CGImageGetHeight(imageRef) > theMaxImageSize.height) {
		CGSize newSize = theMaxImageSize;
		if (newSize.width < newSize.height) {
			newSize.height = newSize.width;
		} else {
			newSize.width = newSize.height;
		}
		
		newSize.height = newSize.width * (CGFloat)CGImageGetHeight(imageRef)/(CGFloat)CGImageGetWidth(imageRef);
		
#if MD_DEBUG
		NSLog(@"GenerateThumbnailForURL(): going to call CGCreateCopyWithSize()");
#endif
		CGImageRef newImage = MDCGImageCreateCopyWithSize(imageRef, newSize);
		QLThumbnailRequestSetImage(thumbnail, newImage, NULL);
		CGImageRelease(newImage);
	} else {
		QLThumbnailRequestSetImage(thumbnail, imageRef, NULL);
		
	}
	
#if MD_DEBUG
	NSLog(@"GenerateThumbnailForURL(): set thumbnail image");
#endif
	
	return noErr;
}
}
	
void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail) {
//	NSLog(@"SourceImage.qlgenerator; CancelThumbnailGeneration()");

	// implement only if supported
}

