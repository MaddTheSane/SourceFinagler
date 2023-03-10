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

class NSHandleInputStream : public nv::Stream
{
	NV_FORBID_COPY(NSHandleInputStream);
public:
	NSHandleInputStream(NSFileHandle *stream): _inStr(stream) {}
	~NSHandleInputStream() {
		_inStr = nil;
	}
	
	void seek(uint pos) override {
		NSError *err;
		[_inStr seekToOffset:pos error:&err];
		if (!error) {
			error = err;
		}
	}
	
	uint tell() const override {
		return (uint)_inStr.offsetInFile;
	}
	
	uint serialize(void *data, uint len) override {
		NSError *err;
		NSData *dat = [_inStr readDataUpToLength:len error:&err];
		if (!error) {
			error = err;
		}
		[dat getBytes:data length:dat.length];
		
		return (uint)dat.length;
	}
	
	uint size() const override {
		unsigned long long currPos = _inStr.offsetInFile;
		[_inStr seekToEndOfFile];
		unsigned long long fullSize = _inStr.offsetInFile;
		[_inStr seekToFileOffset:currPos];
		return (uint)fullSize;
	}
	
	bool isSeekable() const override {
		return true;
	}
	
	bool isAtEnd() const override {
		unsigned long long currPos = _inStr.offsetInFile;
		[_inStr seekToEndOfFile];
		unsigned long long fullSize = _inStr.offsetInFile;
		[_inStr seekToFileOffset:currPos];
		return currPos == fullSize;
	}
	
	bool isLoading() const override {
		return true;
	}
	
	bool isSaving() const override {
		return false;
	}
	
	bool isError() const override {
		return error != nil;
	}
	
	void clearError() override {
		error = nil;
	}
	
private:
	NSFileHandle *_inStr;
	NSError *error;
};

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
	[handle seekToFileOffset:0];
	NSHandleInputStream *mis = new NSHandleInputStream(handle);
	
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
	delete dds;
	
	return YES;
}

@end
