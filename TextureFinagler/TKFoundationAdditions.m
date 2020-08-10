//
//  TKFoundationAdditions.m
//  TKFoundationAdditions
//
//  Created by Mark Douma on 12/03/2007.
//  Copyright (c) 2007-2011 Mark Douma LLC. All rights reserved.
//

#import "TKFoundationAdditions.h"
#include <sys/syslimits.h>
#include <CommonCrypto/CommonDigest.h>

#define TK_DEBUG 0



BOOL TKMouseInRects(NSPoint inPoint, NSArray<NSValue*> *inRects, BOOL isFlipped) {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	for (NSValue *rect in inRects) {
		if (NSMouseInRect(inPoint, rect.rectValue, isFlipped)) {
			return YES;
		}
	}
	return NO;
}

@implementation NSString (TKAdditions)

+ (nullable NSString *)stringWithFSRef:(const FSRef *)anFSRef error:(NSError *__nullable*__nullable)anError
{
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	UInt8 thePath[PATH_MAX + 1];
	
	OSStatus status = FSRefMakePath(anFSRef, thePath, PATH_MAX);
	
	if (status == noErr) {
		return [[NSFileManager defaultManager] stringWithFileSystemRepresentation:(const char *)thePath length:strnlen((const char *)thePath, PATH_MAX)];
	} else {
		if (anError) {
			*anError = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:NULL];
		}
		return nil;
	}
}

+ (NSString *)stringWithFSRef:(const FSRef *)anFSRef
{
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self stringWithFSRef:anFSRef error:NULL];
}

- (BOOL)getFSRef:(FSRef *)anFSRef error:(NSError **)anError {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (anError) *anError = nil;
	OSStatus status = noErr;
	status = FSPathMakeRef((const UInt8 *)self.fileSystemRepresentation, anFSRef, NULL);
	if (status != noErr) {
		if (anError) *anError = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
	}
	return (status == noErr);
}

/* TODO: I need to make sure that this method doesn't exceed the max 255 character filename limit	(NAME_MAX) */
- (NSString *)stringByAssuringUniqueFilename {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	BOOL isDir;
	
	if ([fileManager fileExistsAtPath:self isDirectory:&isDir]) {
		NSString *basePath = self.stringByDeletingLastPathComponent;
		NSString *filename = self.lastPathComponent;
		NSString *filenameExtension = filename.pathExtension;
		NSString *basename = filename.stringByDeletingPathExtension;
		
		NSArray *components = [basename componentsSeparatedByString:@"-"];
		
		if (components.count > 1) {
			// baseName contains at least one "-", determine if it's already a "duplicate". If it is, repeat the process of adding 1 to the value until the resulting filename would be unique. If it isn't, fall through to where we just tack on our own at the end of the filename
			NSString *basenameSuffix = components.lastObject;
			NSInteger suffixNumber = basenameSuffix.integerValue;
			if (suffixNumber > 0) {
				NSUInteger basenameSuffixLength = basenameSuffix.length;
			
				NSString *basenameSubstring = [basename substringWithRange:NSMakeRange(0, basename.length - (basenameSuffixLength + 1))];
				while (1) {
					suffixNumber += 1;
					
					NSString *targetPath;
					
					if ([filenameExtension isEqualToString:@""]) {
						targetPath = [basePath stringByAppendingPathComponent:[basenameSubstring stringByAppendingString:[NSString stringWithFormat:@"-%ld", (long)suffixNumber]]];
					} else {
						targetPath = [basePath stringByAppendingPathComponent:[[basenameSubstring stringByAppendingString:[NSString stringWithFormat:@"-%ld", (long)suffixNumber]] stringByAppendingPathExtension:filenameExtension]];
					}
					
					if (![fileManager fileExistsAtPath:targetPath isDirectory:&isDir]) {
						return targetPath;
					}
				}
			}
		}
		
		// filename doesn't contain an (applicable) "-", so we just tack our own onto the end
		
		NSInteger suffixNumber = 0;
		
		while (1) {
			suffixNumber += 1;
			NSString *targetPath;
			if ([filenameExtension isEqualToString:@""]) {
				targetPath = [basePath stringByAppendingPathComponent:[basename stringByAppendingString:[NSString stringWithFormat:@"-%ld", (long)suffixNumber]]];
			} else {
				targetPath = [basePath stringByAppendingPathComponent:[[basename stringByAppendingString:[NSString stringWithFormat:@"-%ld", (long)suffixNumber]] stringByAppendingPathExtension:filenameExtension]];				
			}
			if (![fileManager fileExistsAtPath:targetPath isDirectory:&isDir]) {
				return targetPath;
			}
		}
	}
	return self;
}

- (NSString *)stringByAbbreviatingFilenameTo31Characters {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSString *newFullPath = nil;
	NSString *filename = self.lastPathComponent;
	NSString *originalFilename = [filename copy];
	
	if (filename.length > 30) {
		NSRange nilRange = NSMakeRange(NSNotFound, 0);
		NSRange pRange = [filename rangeOfString:@"("];
		
		if (NSEqualRanges(nilRange, pRange)) {
			NSArray *components = [filename componentsSeparatedByString:@" "];
			
			if (components.count == 1) {
				NSString *prefix = [filename substringToIndex:29];
				NSString *lastCharacter = [filename substringFromIndex:filename.length - 1];
				
				filename = [NSString stringWithFormat:@"%@%C%@", prefix, (unsigned short)0x2026, lastCharacter];				
				
			} else if (components.count > 1) {
				NSUInteger lastComponentLength = [components.lastObject length];
				
				NSString *suffix = [filename substringFromIndex:filename.length - lastComponentLength - 1];
				suffix = [[NSString stringWithFormat:@"%C", (unsigned short)0x2026] stringByAppendingString:suffix];
				
				NSString *prefix = [filename substringToIndex:filename.length - lastComponentLength - 2];
				
				NSUInteger allowedPrefixLength = (31 - suffix.length);
				
				prefix = [prefix substringToIndex:allowedPrefixLength];
				filename = [prefix stringByAppendingString:suffix];
			}
		} else {
			NSString *suffix = [filename substringFromIndex:(pRange.location - 1)];
			NSString *prefix = [filename substringToIndex:(pRange.location - 1)];
			
			suffix = [[NSString stringWithFormat:@"%C", (unsigned short)0x2026] stringByAppendingString:suffix];
			
			NSUInteger allowedPrefixLength = (31 - suffix.length);
			
			prefix = [prefix substringToIndex:allowedPrefixLength];
			
			filename = [prefix stringByAppendingString:suffix];
		}
		
		if (![originalFilename isEqualToString:filename]) {
			newFullPath = [self.stringByDeletingLastPathComponent stringByAppendingPathComponent:filename];
		} else {
			newFullPath = self;
		}
	} else {
		newFullPath = self;
	}
	return newFullPath;
}

- (NSSize)sizeForStringWithSavedFrame {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSSize size = NSZeroSize;
	
	NSArray *boundsArray = [self componentsSeparatedByString:@" "];
	
	if (boundsArray.count != 4) {
//		NSLog(@"count of bounds array != 4, returning NSZeroSize...");
	} else {
		size.width = [boundsArray[2] doubleValue];
		size.height = [boundsArray[3] doubleValue];
	}

	return size;
}

+ (NSString *)stringWithPascalString:(ConstStr255Param )aPStr {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self stringWithPascalString:aPStr cfencoding:kCFStringEncodingMacRoman];
}

+ (NSString *)stringWithPascalString:(ConstStr255Param)aPStr encoding:(NSStringEncoding)encoding;
{
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self stringWithPascalString:aPStr cfencoding:CFStringConvertNSStringEncodingToEncoding(encoding)];
}


+ (NSString *)stringWithPascalString:(ConstStr255Param)aPStr cfencoding:(CFStringEncoding)encoding;
{
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self stringWithString:CFBridgingRelease(CFStringCreateWithPascalString(kCFAllocatorDefault, aPStr, encoding))];
}

- (BOOL)pascalString:(StringPtr)aBuffer length:(SInt16)aLength cfencoding:(CFStringEncoding)encoding
{
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return CFStringGetPascalString((CFStringRef)self, aBuffer, aLength, encoding);
}

- (BOOL)pascalString:(StringPtr)aBuffer length:(SInt16)aLength encoding:(NSStringEncoding)encoding
{
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self pascalString:aBuffer length:aLength cfencoding:CFStringConvertNSStringEncodingToEncoding(encoding)];
}

- (BOOL)pascalString:(StringPtr)aBuffer length:(SInt16)aLength {
	return [self pascalString:aBuffer length:aLength cfencoding:kCFStringEncodingMacRoman];
}

- (NSComparisonResult)caseInsensitiveNumericalCompare:(NSString *)string {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self compare:string options: NSLiteralSearch | NSCaseInsensitiveSearch | NSNumericSearch];
}

- (NSComparisonResult)localizedCaseInsensitiveNumericalCompare:(NSString *)string {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self compare:string options:NSLiteralSearch | NSCaseInsensitiveSearch | NSNumericSearch range:NSMakeRange(0, string.length) locale:[NSLocale currentLocale]];
}

- (BOOL)containsString:(NSString *)aString {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return (!NSEqualRanges([self rangeOfString:aString], NSMakeRange(NSNotFound, 0)));
}

- (NSString *)stringByReplacing:(NSString *)value with:(NSString *)newValue {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSMutableString *newString = [NSMutableString stringWithString:self];
    [newString replaceOccurrencesOfString:value withString:newValue options:NSLiteralSearch range:NSMakeRange(0, newString.length)];
    return [newString copy];
}

- (NSString *)slashToColon {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self stringByReplacing:@"/" with:@":"];
}

- (NSString *)colonToSlash {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self stringByReplacing:@":" with:@"/"];
}

- (NSString *)displayPath {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSString *displayPath = nil;
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	NSArray *pathComponents = [fileManager componentsToDisplayForPath:self];
	if (pathComponents && pathComponents.count) {
		if (displayPath == nil) {
			displayPath = @"/";
		}
		for (NSString *pathComponent in pathComponents) {
			displayPath = [displayPath stringByAppendingPathComponent:pathComponent];
		}
	}
	
	return displayPath;
}

- (NSData *)bookmarkDataWithOptions:(TKBookmarkCreationOptions)options error:(NSError **)outError {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSData *bookmarkData = nil;
	NSString *path = self.stringByResolvingSymlinksInPath.stringByStandardizingPath;
	
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if ([fileManager fileExistsAtPath:path]) {
		FSRef itemRef;
		if ([path getFSRef:&itemRef error:outError]) {
			NSURL *fileURL = [NSURL fileURLWithPath:path];
			return [fileURL bookmarkDataWithOptions:(NSURLBookmarkCreationOptions)(options & ~(TKBookmarkCreationOptions)(1)) includingResourceValuesForKeys:nil relativeToURL:nil error:outError];
		}
	} else {
		NSLog(@"[%@ %@] no file exists at %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), path);
		if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:fnfErr userInfo:nil];
	}
	return bookmarkData;
}

+ (instancetype)stringByResolvingBookmarkData:(NSData *)bookmarkData options:(TKBookmarkResolutionOptions)options bookmarkDataIsStale:(BOOL *)isStale error:(NSError **)outError {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSString *resolvedPath = nil;
	if (outError) *outError = nil;
	if (bookmarkData) {
		NSURL *newURL = [NSURL URLByResolvingBookmarkData:bookmarkData options:(NSURLBookmarkResolutionOptions)(options &= ~TKBookmarkResolutionDefaultOptions) relativeToURL:nil bookmarkDataIsStale:isStale error:outError];
		if (newURL) {
			resolvedPath = [newURL path];
		}
	}
	return resolvedPath ? [[self class] stringWithString:resolvedPath] : nil;
}

@end

@implementation NSUserDefaults (TKSortDescriptorAdditions)

- (void)setSortDescriptors:(NSArray *)sortDescriptors forKey:(NSString *)key {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sortDescriptors];
	if (data) [self setObject:data forKey:key];
}


- (NSArray *)sortDescriptorsForKey:(NSString *)key {
	id obj = [self objectForKey:key];
	if (![obj isKindOfClass:[NSData class]]) {
		return nil;
	}
	
	NSArray *toRet = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
	for (id obj2 in toRet) {
		if (![obj2 isKindOfClass:[NSSortDescriptor class]]) {
			return nil;
		}
	}
	return toRet;
}

@end

@implementation NSDictionary (TKSortDescriptorAdditions)

- (NSArray *)sortDescriptorsForKey:(NSString *)key {
	id obj = self[key];
	if (![obj isKindOfClass:[NSData class]]) {
		return nil;
	}
	
	NSArray *toRet = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
	for (id obj2 in toRet) {
		if (![obj2 isKindOfClass:[NSSortDescriptor class]]) {
			return nil;
		}
	}
	return toRet;
}

@end

@implementation NSMutableDictionary (TKSortDescriptorAdditions)

- (void)setSortDescriptors:(NSArray *)sortDescriptors forKey:(NSString *)key {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sortDescriptors];
	if (data) self[key] = data;
}

@end

@implementation NSURL (TKAdditions)
+ (nullable NSURL*)URLWithFSRef:(const FSRef *)anFSRef
{
	return CFBridgingRelease(CFURLCreateFromFSRef(kCFAllocatorDefault, anFSRef));
}

- (BOOL)getFSRef:(FSRef *)anFSRef error:(NSError *__nullable*__nullable)anError
{
	//As this will only work on file urls, auto-fail if we aren't one.
	if (![self isFileURL]) {
		if (anError) {
			*anError = [NSError
						errorWithDomain:NSOSStatusErrorDomain code:paramErr
						userInfo:@{NSLocalizedFailureReasonErrorKey: @"Can only convert from a file: URL scheme"
								   }];
		}
		return NO;
	}
	
	BOOL success = CFURLGetFSRef((CFURLRef)self, anFSRef);
	if (success) {
		return YES;
	}
	
	//CFURLGetFSRef doesn't tell us HOW it failed, only that it did.
	//So use the NSString method, just to double-check
	return [[[self absoluteURL] path] getFSRef:anFSRef error:anError];
}

@end


@implementation NSIndexSet (TKAdditions)

+ (instancetype)indexSetWithIndexSet:(NSIndexSet *)indexes {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [[[self class] alloc] initWithIndexSet:indexes];
}

- (NSIndexSet *)indexesIntersectingIndexes:(NSIndexSet *)indexes {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSMutableIndexSet *intersectingIndexes = [NSMutableIndexSet indexSet];
	
	NSUInteger theIndex = self.firstIndex;
	
	while (theIndex != NSNotFound) {
		if ([indexes containsIndex:theIndex]) [intersectingIndexes addIndex:theIndex];
		
		theIndex = [self indexGreaterThanIndex:theIndex];
	}
	
	return [intersectingIndexes copy];
}

@end



@implementation NSMutableIndexSet (TKAdditions)

- (void)setIndexes:(NSIndexSet *)indexes {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self removeAllIndexes];
	[self addIndexes:indexes];
}

@end

@implementation NSData (TKDescriptionAdditions)

- (NSString *)stringRepresentation {
	const char *bytes = self.bytes;
	NSUInteger stringLength = self.length;
	NSUInteger currentIndex;
	
	NSMutableString *stringRepresentation = [NSMutableString string];
	
	for (currentIndex = 0; currentIndex < stringLength; currentIndex++) {
		[stringRepresentation appendFormat:@"%02x", (unsigned char)bytes[currentIndex]];
	}
	return [stringRepresentation copy];
}

// prints raw hex + ascii
- (NSString *)enhancedDescription {
	
	NSMutableString *string = [NSMutableString string];   // full string result
	NSMutableString *hrStr = [NSMutableString string]; // "human readable" string
	
	NSInteger i, len;
	const unsigned char *b;
	len = self.length;
	b = self.bytes;
	
	if (len == 0) {
		return @"<empty>";
	}
	[string appendString:@"\n   "];
	
	NSInteger linelen = 16;
	for (i = 0; i < len; i++) {
		[string appendFormat:@" %02x", b[i]];
		if (isprint(b[i])) {
			[hrStr appendFormat:@"%c", b[i]];
		} else {
			[hrStr appendString:@"."];
		}
		if ((i % linelen) == (linelen - 1)) { // new line every linelen bytes
			[string appendFormat:@"    %@\n", hrStr];
			hrStr = [NSMutableString string];
			
			if (i < (len - 1)) {
				[string appendString:@"   "];
			}
		}
	}
	
	// make sure to print out the remaining hrStr part, aligned of course
	if ((len % linelen) != 0) {
		NSInteger bytesRemain = linelen - (len % linelen); // un-printed bytes
		for (i = 0; i < bytesRemain; i++) {
			[string appendString:@"   "];
		}
		[string appendFormat:@"    %@\n", hrStr];
	}
	return string;
}


@end


#include <CommonCrypto/CommonDigest.h>

//#ifdef TEXTUREKIT_EXTERN
//#error
//#endif
//#ifndef TEXTUREKIT_EXTERN

@implementation NSData (TKAdditions)


- (NSString *)sha1HexHash {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	char hashString[(2 * CC_SHA1_DIGEST_LENGTH) + 1];
	
	CC_SHA1([self bytes], [self length], digest);
	
	NSInteger currentIndex = 0;
	
	for (currentIndex = 0; currentIndex < CC_SHA1_DIGEST_LENGTH; currentIndex++) {
		sprintf(hashString+currentIndex*2, "%02x", digest[currentIndex]);
	}
	hashString[currentIndex * 2] = 0;
	
	return @(hashString);
}


- (NSData *)sha1Hash {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1([self bytes], [self length], digest);
	return [NSData dataWithBytes:&digest length:CC_SHA1_DIGEST_LENGTH];
}


@end


@implementation NSBundle (TKAdditions)

- (NSString *)checksumForAuxiliaryLibrary:(NSString *)dylibName {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSString *checksum = nil;
	NSString *executablePath = [self executablePath];
	if (executablePath && dylibName) {
		NSString *dylibPath = [[executablePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:dylibName];
		
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		BOOL isDir;
		
		if ([fileManager fileExistsAtPath:dylibPath isDirectory:&isDir] && !isDir) {
			NSError *error = nil;
			
			NSData *dylibData = [NSData dataWithContentsOfFile:dylibPath options:NSDataReadingUncached error:&error];
			if (dylibData) {
				checksum = [dylibData sha1HexHash];
			} else {
				NSLog(@"[%@ %@] [NSData dataWithContentsOfFile:options:error:] returned nil with error == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
			}
		}
	}
	return checksum;
}

@end


NSString *NSStringForAppleScriptListFromPaths(NSArray<NSString*> *paths) {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	@autoreleasepool {
		NSMutableString *listString = [[NSMutableString alloc] initWithString:@"{"];
		NSString *filePath;
		NSInteger currentIndex;
		NSInteger totalCount = paths.count;
		
		for (currentIndex = 0; currentIndex < totalCount; currentIndex++) {
			filePath = paths[currentIndex];
			[listString appendFormat:@"\"%@\" as POSIX file", filePath];
			
			if (currentIndex < (totalCount - 1)) {
				[listString appendString:@", "];
			}
		}
		[listString appendString:@"}"];
		
		return [listString copy];
	}
}


//@implementation NSArray (TKAdditions)
//
//- (BOOL)containsObjectIdenticalTo:(id)obj { 
//#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//#endif
//    return [self indexOfObjectIdenticalTo: obj] != NSNotFound; 
//}
//
//@end
//
//
//


@implementation NSMutableArray (TKAdditions)

- (void)insertObjectsFromArray:(NSArray *)array atIndex:(NSUInteger)anIndex {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(anIndex, array.count)]];
}


@end



////////////////////////////////////////////////////////////////
#pragma mark    NSMutableDictionary CATEGORY FOR THREAD-SAFETY
////////////////////////////////////////////////////////////////



@implementation NSMutableDictionary (TKThreadSafety)

- (id)threadSafeObjectForKey:(id)aKey usingLock:(NSLock *)aLock {
    id    result;
	
    [aLock lock];
    result = self[aKey];
    [aLock unlock];
	
    return result;
}

- (void)threadSafeRemoveObjectForKey:(id)aKey usingLock:(NSLock *)aLock {
    [aLock lock];
    [self removeObjectForKey:aKey];
    [aLock unlock];
}

- (void)threadSafeSetObject:(id)anObject forKey:(id)aKey usingLock:(NSLock *)aLock {
    [aLock lock];
	id anObject2 = anObject;
    self[aKey] = anObject2;
    [aLock unlock];
	anObject2 = nil;
}

@end



@implementation NSObject (TKDeepMutableCopy)

- (id)deepMutableCopy {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
    if ([self respondsToSelector:@selector(mutableCopyWithZone:)]) {
        return [self mutableCopy];
	} else if ([self respondsToSelector:@selector(copyWithZone:)]) {
        return [self copy];
	} else {
        return self;
	}
}

@end

@implementation NSDictionary (TKDeepMutableCopy)

- (id)deepMutableCopy {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
    NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] init];
	id key = nil;
	
	NSArray *allKeys = self.allKeys;
	
	for (key in allKeys) {
		id copiedObject = [self[key] deepMutableCopy];
		
		id keyCopy = nil;
		
		if ([key conformsToProtocol:@protocol(NSCopying)]) {
			keyCopy = [key copy];
		} else {
			keyCopy = key;
		}
		
		newDictionary[keyCopy] = copiedObject;
	}
    return newDictionary;
}

@end


@implementation NSArray (TKDeepMutableCopy)

- (id)deepMutableCopy {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
	
	for (id object in self) {
		id copiedObject = [object deepMutableCopy];
		[newArray addObject:copiedObject];
	}
	return [[self class] arrayWithArray:newArray];
}
	
@end



@implementation NSSet (TKDeepMutableCopy)

- (id)deepMutableCopy {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
    NSMutableSet *newSet = [[NSMutableSet alloc] init];
	
	NSArray *allObjects = self.allObjects;
	
	for (id object in allObjects) {
		id copiedObject = [object deepMutableCopy];
		[newSet addObject:copiedObject];
	}
	return [[self class] setWithSet:newSet];
}
	
@end



#if (TK_BUILDING_WITH_FOUNDATION_NSDATE_ADDITIONS)

@implementation NSDate (TKAdditions)



+ (id)dateByRoundingDownToNearestMinute {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [NSCalendarDate calendarDate];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:0
								   minutes:0
								   seconds:-[calendarDate secondOfMinute]];
}



+ (id)dateByRoundingUpToNearestMinute {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [NSCalendarDate calendarDate];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:0
								   minutes:1
								   seconds:-[calendarDate secondOfMinute]];
}



+ (id)dateByAddingTwoAndRoundingUpToNearestMinute {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [NSCalendarDate calendarDate];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:0
								   minutes:3
								   seconds:-[calendarDate secondOfMinute]];
}



+ (id)midnightYesterdayMorning {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [NSCalendarDate calendarDate];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:-[calendarDate hourOfDay] - 24
								   minutes:-[calendarDate minuteOfHour]
								   seconds:-[calendarDate secondOfMinute]];
}



+ (id)midnightThisMorning {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [NSCalendarDate calendarDate];
	return [calendarDate dateByAddingYears:0
								   months:0
									 days:0
									hours:-[calendarDate hourOfDay]
								  minutes:-[calendarDate minuteOfHour]
								  seconds:-[calendarDate secondOfMinute]];
}



+ (id)midnightTonight {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [NSCalendarDate calendarDate];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:-[calendarDate hourOfDay] + 24
								   minutes:-[calendarDate minuteOfHour]
								   seconds:-[calendarDate secondOfMinute]];
}



+ (id)midnightTomorrowNight  {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [NSCalendarDate calendarDate];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:-[calendarDate hourOfDay] + 48
								   minutes:-[calendarDate minuteOfHour]
								   seconds:-[calendarDate secondOfMinute]];
}



/* if dates are equal (the NSComparisonResult == NSOrderedSame, these methods return NO */

- (BOOL)isEarlierThanDate:(NSDate *)aDate {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return ([self compare:aDate] == NSOrderedAscending);
}



- (BOOL)isLaterThanDate:(NSDate *)aDate {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return ([self compare:aDate] == NSOrderedDescending);
}

/* end */


- (BOOL)isEarlierThanOrEqualToDate:(NSDate *)aDate {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return (([self compare:aDate] == NSOrderedAscending) || ([self compare:aDate] == NSOrderedSame));
	
}



- (BOOL)isLaterThanOrEqualToDate:(NSDate *)aDate {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return (([self compare:aDate] == NSOrderedDescending) || ([self compare:aDate] == NSOrderedSame));
	
}



- (id)dateByRoundingDownToNearestMinute {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:0
								   minutes:0
								   seconds:-[calendarDate secondOfMinute]];
	
}



- (id)dateByRoundingUpToNearestMinute {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:0
								   minutes:1
								   seconds:-[calendarDate secondOfMinute]];
	
}



- (id)dateByAddingTwoAndRoundingUpToNearestMinute {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:0
								   minutes:3
								   seconds:-[calendarDate secondOfMinute]];
}




- (id)midnightOfYesterdayMorning {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:-[calendarDate hourOfDay] - 24
								   minutes:-[calendarDate minuteOfHour]
								   seconds:-[calendarDate secondOfMinute]];
}



- (id)midnightOfMorning {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:-[calendarDate hourOfDay]
								   minutes:-[calendarDate minuteOfHour]
								   seconds:-[calendarDate secondOfMinute]];
}


- (id)midnightOfEvening {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:-[calendarDate hourOfDay] + 24
								   minutes:-[calendarDate minuteOfHour]
								   seconds:-[calendarDate secondOfMinute]];
}



- (id)midnightOfTomorrowEvening {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:-[calendarDate hourOfDay] + 48
								   minutes:-[calendarDate minuteOfHour]
								   seconds:-[calendarDate secondOfMinute]];
}





- (id)baseWeekly {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	return [calendarDate dateByAddingYears:0
									months:0
									  days:-[calendarDate dayOfWeek]
									 hours:0
								   minutes:0
								   seconds:0];
}


- (id)dateBySynchronizingToTimeOfDayOfDate:(NSDate *)aRepeatedCleaningDate {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	NSCalendarDate *repeatedCleaningDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[aRepeatedCleaningDate timeIntervalSinceReferenceDate]] autorelease];
	
	return [calendarDate dateByAddingYears:0
									months:0
									  days:0
									 hours:-[calendarDate hourOfDay] + [repeatedCleaningDate hourOfDay]
								   minutes:-[calendarDate minuteOfHour] + [repeatedCleaningDate minuteOfHour]
								   seconds:-[calendarDate secondOfMinute] + [repeatedCleaningDate secondOfMinute]];
	
}



//- (id)baseWeeklyForDate:(NSDate *)aDate {
//	NSCalendarDate *baseSundayDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
//	NSCalendarDate *baseWeeklyDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[aDate timeIntervalSinceReferenceDate]] autorelease];
//	
//	return [NSCalendarDate dateWithYear:[baseWeeklyDate yearOfCommonEra]
//								  month:[baseWeeklyDate monthOfYear]
//									day:[baseWeeklyDate dayOfMonth]
//								   hour:[baseSundayDate hourOfDay]
//								 minute:[baseSundayDate minuteOfHour]
//								 second:[baseSundayDate secondOfMinute]
//							   timeZone:nil];
//}



- (id)baseMonthly {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	
	return [calendarDate dateByAddingYears:0
									months:0
									  days:-[calendarDate dayOfMonth] + 1
									 hours:0
								   minutes:0
								   seconds:0];
	
}



- (id)dateByTransposingToCurrentDay {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	NSCalendarDate *now = [NSCalendarDate calendarDate];
	
	return [now dateByAddingYears:0
						   months:0
							 days:0
							hours:-[now hourOfDay] + [calendarDate hourOfDay]
						  minutes:-[now minuteOfHour] + [calendarDate minuteOfHour]
						  seconds:-[now secondOfMinute] + [calendarDate secondOfMinute]];
}



- (id)dateByTransposingToFirstDayOfCurrentWeek {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	NSCalendarDate *now = [NSCalendarDate calendarDate];
	
	return [now dateByAddingYears:0
						   months:0
							 days:-[now dayOfWeek]
							hours:-[now hourOfDay] + [calendarDate hourOfDay]
						  minutes:-[now minuteOfHour] + [calendarDate minuteOfHour]
						  seconds:-[now secondOfMinute] + [calendarDate secondOfMinute]];
}



- (id)dateByTransposingToFirstDayOfCurrentMonth {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSCalendarDate *calendarDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]] autorelease];
	NSCalendarDate *now = [NSCalendarDate calendarDate];
	
	return [now dateByAddingYears:0
						   months:0
							 days:-[now dayOfMonth] + 1
							hours:-[now hourOfDay] + [calendarDate hourOfDay]
						  minutes:-[now minuteOfHour] + [calendarDate minuteOfHour]
						  seconds:-[now secondOfMinute] + [calendarDate secondOfMinute]];
	
}

@end

#endif
