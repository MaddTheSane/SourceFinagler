//
//  HKFileAdditions.m
//  HLKit
//
//  Created by Mark Douma on 9/30/2010.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

#import <HLKit/HKFileAdditions.h>
#import <HLKit/HKFoundationAdditions.h>

#import <Cocoa/Cocoa.h>

#import <AVFoundation/AVFoundation.h>

#import <TextureKit/TKImage.h>
#import <TextureKit/TKVTFImageRep.h>


#define HK_DEBUG 0

@implementation HKFile (HKAdditions)


- (NSString *)stringValue {
	return [self stringValueByExtractingToTempFile:NO];
}

- (NSString *)stringValueByExtractingToTempFile:(BOOL)shouldExtractToTempFile {
	if (fileType != HKFileTypeHTML && fileType != HKFileTypeText) return nil;
	
	NSData *textData = self.data;
	if (textData == nil) {
		NSLog(@"[%@ %@] failed to extract data!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return nil;
	}
	
	NSString *stringValue = nil;
	
	if (shouldExtractToTempFile) {
		NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.markdouma.SourceAddonFinagler"].stringByAssuringUniqueFilename;
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		if (![fileManager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:NULL]) {
			NSLog(@"[%@ %@] failed to create tempDirectory to extract file in!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
			return nil;
		}
		
		NSString *writePath = [tempPath stringByAppendingPathComponent:@"temp.txt"];
		if ([textData writeToFile:writePath atomically:NO]) {
			NSStringEncoding usedEncoding = NSUTF8StringEncoding;
			NSError *stringError = nil;
			stringValue = [NSString stringWithContentsOfFile:writePath usedEncoding:&usedEncoding error:&stringError];
			
			NSLog(@"[%@ %@] usedEncoding == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [NSString localizedNameOfStringEncoding:usedEncoding]);
			if (stringValue == nil) {
				NSLog(@"[%@ %@] string creation error == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), stringError);
			}
		}
		if (![fileManager removeItemAtPath:tempPath error:NULL]) {
			NSLog(@"[%@ %@] failed to cleanup temp folder!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		}
	} else {
		stringValue = [[NSString alloc] initWithData:textData encoding:NSUTF8StringEncoding];
		if (stringValue == nil) {
			NSLog(@"[%@ %@] failed to create string with NSUTF8StringEncoding", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
			
			stringValue = [[NSString alloc] initWithData:textData encoding:NSASCIIStringEncoding];
			if (stringValue == nil) {
				NSLog(@"[%@ %@] failed to create string with NSASCIIStringEncoding", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
				
				stringValue = [[NSString alloc] initWithData:textData encoding:NSISOLatin1StringEncoding];
				if (stringValue == nil) {
					NSLog(@"[%@ %@] failed to create string with NSISOLatin1StringEncoding, data == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), textData);
					stringValue = @"<failed to create string using UTF8, ASCII, or ISO Latin 1 encodings>";
				}
			}
		}
	}
	return stringValue;
}

- (NSSound *)sound {
	if (fileType != HKFileTypeSound)
		return nil;
	NSData *soundData = self.data;
	if (soundData)
		return [[NSSound alloc] initWithData:soundData];
	return nil;
}

- (NSImage *)image {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSImage *theImage = nil;
	if (fileType == HKFileTypeImage) {
		NSData *data = self.data;
		if (data) {
			if ([type isEqualToString:TKVTFType]) {
				theImage = [[TKImage alloc] initWithData:data firstRepresentationOnly:YES];
				if (theImage) {
					self.version = ((TKImage *)theImage).version;
					self.compression = ((TKImage *)theImage).compression;
					self.hasMipmaps = (((TKImage *)theImage).hasMipmaps ? NSLocalizedString(@"Yes", @"") : NSLocalizedString(@"No", @""));
					self.hasAlpha = (((TKImage *)theImage).hasAlpha ? NSLocalizedString(@"Yes", @"") : NSLocalizedString(@"No", @""));
				}
			} else {
				theImage = [[NSImage alloc] initWithData:data];
			}
		}
		if (theImage) {
			NSSize imageSize = theImage.size;
			self.dimensions = [NSString stringWithFormat:NSLocalizedString(@"%lu x %lu", @""), (NSUInteger)imageSize.width, (NSUInteger)imageSize.height];
		}
	} else if (fileType == HKFileTypeOther ||
			   fileType == HKFileTypeText ||
			   fileType == HKFileTypeHTML ||
			   fileType == HKFileTypeNotExtractable) {
		theImage = [HKItem copiedImageForItem:self];
		theImage.size = NSMakeSize(128.0, 128.0);
	}
	return theImage;
}

- (AVMovie *)movie {
	AVMovie *movie = nil;
	if (fileType == HKFileTypeMovie) {
		NSData *data = self.data;
		if (data) {
			if ([AVMovie class] && [AVMovie instancesRespondToSelector:@selector(initWithData:options:)]) {
				movie = [[AVMovie alloc] initWithData:data options:nil];
				if (!movie) {
					NSLog(@"[%@ %@] failed to create movie.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
				}
			} else {
				NSLog(@"[%@ %@] AVMovie not found, or can not load from data!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
			}
		}
	}
	return movie;
}

@end
