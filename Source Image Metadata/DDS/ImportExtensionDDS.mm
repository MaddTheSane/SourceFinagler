//
//  ImportExtension.m
//  Source Image Metadata
//
//  Created by C.W. Betts on 10/29/22.
//  Copyright © 2022 Mark Douma LLC. All rights reserved.
//

#import "ImportExtensionDDS.h"
#import <TextureKit/TKDDSImageRep.h>
#include <NVTT/NVTextureTools.h>

using namespace nv;

@implementation ImportExtensionDDS

- (BOOL)updateAttributes:(CSSearchableItemAttributeSet *)attributes forFileAtURL:(NSURL *)contentURL error:(NSError **)error {
	NSData *data = [[NSData alloc] initWithContentsOfURL:contentURL options:0 error:error];
	if (data == nil) {
		return NO;
	}
	
	if ([data length] < sizeof(OSType)) {
		if (error) {
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadInvalidFileNameError userInfo:
					  @{NSLocalizedDescriptionKey: @"[data length] < 4 for file",
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
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadInvalidFileNameError userInfo:
					  @{NSLocalizedDescriptionKey: errString,
						NSDebugDescriptionErrorKey: errString,
						NSURLErrorKey: contentURL
					  }];
		}
		return NO;
	}
	MemoryInputStream *mis = new MemoryInputStream((const unsigned char *)[data bytes], uint([data length]));
	
	DirectDrawSurface *dds = new DirectDrawSurface();
	dds->load(mis);
	if (!dds->isValid() || !dds->isSupported() || (dds->width() > 65535 || (dds->height() > 65535))) {
		if (!dds->isValid()) {
			if (error) {
				*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadInvalidFileNameError userInfo:
						  @{NSLocalizedDescriptionKey: @"dds image is not valid",
							NSDebugDescriptionErrorKey: @"dds image is not valid",
							NSURLErrorKey: contentURL
						  }];
			}
		} else if (!dds->isSupported()) {
			if (error) {
				*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadInvalidFileNameError userInfo:
						  @{NSLocalizedDescriptionKey: @"dds image format is not supported",
							NSDebugDescriptionErrorKey: @"dds image format is not supported",
							NSURLErrorKey: contentURL
						  }];
			}
		} else {
			if (error) {
				*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadInvalidFileNameError userInfo:
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
	
	return YES;
}

@end
