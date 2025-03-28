//
//  ImportExtension.m
//  Source Image Metadata
//
//  Created by C.W. Betts on 10/29/22.
//  Copyright © 2022 Mark Douma LLC. All rights reserved.
//

#import "ImportExtensionDDS.h"
#import <TextureKit/TKDDSImageRep.h>
#include <NVCore/Stream.h>
#include <NVImage/DirectDrawSurface.h>

using namespace nv;

@implementation ImportExtensionDDS

- (BOOL)updateAttributes:(CSSearchableItemAttributeSet *)attributes forFileAtURL:(NSURL *)contentURL error:(NSError **)error {
	NSFileHandle *handle = [NSFileHandle fileHandleForReadingFromURL:contentURL error:error];
	if (handle == nil) {
		return NO;
	}
	NSData *data = [handle readDataUpToLength:4 error:error];
	if (data == nil) {
		return NO;
	}
	
	if ([data length] < sizeof(OSType)) {
		if (error) {
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadInvalidFileNameError userInfo:
					  @{NSLocalizedDescriptionKey: @"File is too small",
						NSDebugDescriptionErrorKey: @"[data length] < 4 for file",
						NSURLErrorKey: contentURL
					  }];
		}
		return NO;
	}
	
	OSType magic = 0;
	[data getBytes:&magic length:sizeof(magic)];
	magic = CFSwapInt32BigToHost(magic);
	
	if (magic != TKDDSMagic) {
		if (error) {
			NSString *errString = [NSString stringWithFormat:@"file does not appear to be a valid DDS; magic == 0x%x, %@", (unsigned int)magic, NSFileTypeForHFSTypeCode(magic)];
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:
					  @{NSLocalizedDescriptionKey: errString,
						NSDebugDescriptionErrorKey: errString,
						NSURLErrorKey: contentURL
					  }];
		}
		return NO;
	}
	[handle seekToFileOffset:0];
	
	DirectDrawSurface *dds = new DirectDrawSurface();
	dds->load(contentURL.fileSystemRepresentation);
	[handle closeFile];
	
	if (!dds->isValid() || !dds->isSupported() || (dds->width() > 65535 || (dds->height() > 65535))) {
		if (!dds->isValid()) {
			if (error) {
				*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:
						  @{NSLocalizedDescriptionKey: @"dds image is not valid",
							NSDebugDescriptionErrorKey: @"dds image is not valid",
							NSURLErrorKey: contentURL
						  }];
			}
		} else if (!dds->isSupported()) {
			if (error) {
				*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:
						  @{NSLocalizedDescriptionKey: @"dds image format is not supported",
							NSDebugDescriptionErrorKey: @"dds image format is not supported",
							NSURLErrorKey: contentURL
						  }];
			}
		} else {
			if (error) {
				*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadTooLargeError userInfo:
						  @{NSLocalizedDescriptionKey: @"dds image dimensions are too large",
							NSDebugDescriptionErrorKey: @"dds image dimensions are too large",
							NSURLErrorKey: contentURL
						  }];
			}
		}
//		dds->printInfo();
		delete dds;
		return NO;
	}
	
#if MD_DEBUG
	dds->printInfo();
#endif
	
	BOOL hasAlphaChannel = dds->hasAlpha();
	BOOL hasMipmaps = (dds->mipmapCount() > 1);
	BOOL isEnvironmentMap = dds->isTextureCube();
	
	NSString *theCompression = nil;
	const char *compression = NULL;
	compression = dds->header.d3d9FormatString();
	if (compression) {
		theCompression = @(compression);
	}
	
	uint theWidth = dds->width();
	uint theHeight = dds->height();
	
	attributes.hasAlphaChannel = @(hasAlphaChannel);
	[attributes setValue:@(hasMipmaps) forCustomKey:[[CSCustomAttributeKey alloc] initWithKeyName:@"com_markdouma_image_mipmaps"]];
	
	// only set environment mask if it's true?
	[attributes setValue:@(isEnvironmentMap) forCustomKey:[[CSCustomAttributeKey alloc] initWithKeyName:@"com_markdouma_image_environment_map"]];
	
	attributes.pixelWidth = @(theWidth);
	attributes.pixelHeight = @(theHeight);
	attributes.pixelCount = @(theWidth * theHeight);
	if (theCompression) {
		[attributes setValue:theCompression forCustomKey:[[CSCustomAttributeKey alloc] initWithKeyName:@"com_markdouma_image_compression"]];
	}
	delete dds;
	
	return YES;
}

@end
