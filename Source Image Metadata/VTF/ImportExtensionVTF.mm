//
//  ImportExtension.m
//  Source Image Metadata
//
//  Created by C.W. Betts on 10/29/22.
//  Copyright © 2022 Mark Douma LLC. All rights reserved.
//

#import "ImportExtensionVTF.h"
#include <VTF/VTF.h>
#import <TextureKit/TKVTFImageRep.h>

using namespace VTFLib;

@implementation ImportExtensionVTF

- (BOOL)updateAttributes:(CSSearchableItemAttributeSet *)attributes forFileAtURL:(NSURL *)contentURL error:(NSError **)error {
	NSData *data = [[NSData alloc] initWithContentsOfURL:contentURL options:NSDataReadingMappedIfSafe error:error];
	if (data == nil) {
		return NO;
	}
	
	if ([data length] < sizeof(OSType)) {
		if (error) {
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:
					  @{NSLocalizedDescriptionKey: NSLocalizedString(@"The file too small", @"[data length] < 4 for file"),
						NSDebugDescriptionErrorKey: @"[data length] < 4 for file",
						NSURLErrorKey: contentURL
					  }];
		}
		return NO;
	}
	
	OSType magic = 0;
	[data getBytes:&magic length:sizeof(magic)];
	magic = CFSwapInt32BigToHost(magic);
	
	if (magic == TKHTMLErrorMagic) {
		if (error) {
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:
					  @{NSLocalizedDescriptionKey: NSLocalizedString(@"file appears to be an ERROR 404 HTML file rather than a valid VTF", @"file appears to be an ERROR 404 HTML file rather than a valid VTF"),
						NSDebugDescriptionErrorKey: @"file appears to be an ERROR 404 HTML file rather than a valid VTF",
						NSURLErrorKey: contentURL
					  }];
		}
		return NO;
	}
	
	CVTFFile *file = new CVTFFile();
	
	if (file == NULL) {
		if (error) {
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadInvalidFileNameError userInfo:
					  @{NSLocalizedDescriptionKey: NSLocalizedString(@"CVTFFile() returned NULL", @"CVTFFile() returned NULL"),
						NSDebugDescriptionErrorKey: @"CVTFFile() returned NULL",
						NSURLErrorKey: contentURL
					  }];
		}
		return NO;
	}
	
	if (file->Load([data bytes], (vlUInt)[data length], vlTrue) == NO) {
		if (magic == TKVTFMagic) {
			if (error) {
				*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:
						  @{NSLocalizedDescriptionKey: NSLocalizedString(@"file->Load() failed!", @"file->Load() failed!"),
							NSDebugDescriptionErrorKey: @"file->Load() failed!",
							NSURLErrorKey: contentURL
						  }];
			}
		} else {
			if (error) {
				*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:
						  @{NSLocalizedDescriptionKey: [NSString localizedStringWithFormat:NSLocalizedString(@"file->Load() failed! (does not appear to be a valid VTF; magic == 0x%x, %@)", @"file->Load() failed! (does not appear to be a valid VTF;"), (unsigned int)magic, NSFileTypeForHFSTypeCode(magic)],
							NSDebugDescriptionErrorKey: [NSString stringWithFormat:@"file->Load() failed! (does not appear to be a valid VTF; magic == 0x%x, %@)", (unsigned int)magic, NSFileTypeForHFSTypeCode(magic)],
							NSURLErrorKey: contentURL
						  }];
			}
		}
		delete file;
		return NO;
	}
	
	BOOL isEnvironmentMap = (file->GetFaceCount() > 1);
	
	BOOL hasAlphaChannel = !!(file->GetFlags() & (TEXTUREFLAGS_ONEBITALPHA | TEXTUREFLAGS_EIGHTBITALPHA));
	BOOL hasMipmaps = (file->GetMipmapCount() > 1);
	BOOL isAnimated = (file->GetFrameCount() > 1);
	NSString *theCompression = nil;
	SVTFImageFormatInfo imageFormatInfo = file->GetImageFormatInfo(file->GetFormat());
	if (imageFormatInfo.lpName != NULL) {
		theCompression = @(imageFormatInfo.lpName);
	}
	vlUInt theWidth = file->GetWidth();
	vlUInt theHeight = file->GetHeight();
	NSString *theVersion = [NSString stringWithFormat:@"%u.%u", file->GetMajorVersion(), file->GetMinorVersion()];
	
	attributes.hasAlphaChannel = @(hasAlphaChannel);
	[attributes setValue:@(hasMipmaps) forCustomKey:[[CSCustomAttributeKey alloc] initWithKeyName:@"com_markdouma_image_mipmaps"]];
	[attributes setValue:@(isAnimated) forCustomKey:[[CSCustomAttributeKey alloc] initWithKeyName:@"com_markdouma_image_animated"]];
	
	// only set environment mask if it's true?
	[attributes setValue:@(isEnvironmentMap) forCustomKey:[[CSCustomAttributeKey alloc] initWithKeyName:@"com_markdouma_image_environment_map"]];
	
	attributes.pixelWidth = @(theWidth);
	attributes.pixelHeight = @(theHeight);
	if (theVersion) {
		attributes.version = theVersion;
	}
	if (theCompression) {
		[attributes setValue:theCompression forCustomKey:[[CSCustomAttributeKey alloc] initWithKeyName:@"com_markdouma_image_compression"]];
	}
	
	delete file;
	return YES;
}

@end
