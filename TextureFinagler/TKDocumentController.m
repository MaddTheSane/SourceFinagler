//
//  TKDocumentController.m
//  Texture Kit
//
//  Created by Mark Douma on 3/16/2009.
//  Copyright (c) 2009-2012 Mark Douma. All rights reserved.
//

#import "TKDocumentController.h"
#import <TextureKit/TextureKit.h>

#import "TKImageDocument.h"

#include <CoreServices/CoreServices.h>

#import "TKFoundationAdditions.h"



#define TK_DEBUG 1

static NSSet *nonImageUTTypes = nil;
NSString * const TKApplicationBundleIdentifier = @"com.markdouma.SourceFinagler";


@implementation TKDocumentController

+ (void)initialize {
	if (nonImageUTTypes == nil) {
		NSMutableArray *supportedDocTypes = [NSMutableArray array];
		NSArray *docTypes = [[NSBundle bundleWithIdentifier:TKApplicationBundleIdentifier] objectForInfoDictionaryKey:@"CFBundleDocumentTypes"];
//		NSLog(@"[%@ %@] docTypes == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), docTypes);
	
		for (NSDictionary *docType in docTypes) {
			NSString *docClass = docType[@"NSDocumentClass"];
			if ([docClass isEqualToString:@"TKImageDocument"]) {
				continue;
			}
			if (docClass) {
				NSArray *contentTypes = docType[@"LSItemContentTypes"];
				if (contentTypes && contentTypes.count) {
					NSString *utiType = contentTypes[0];
					if (![utiType isEqualToString:(NSString *)kUTTypeImage]) {
						[supportedDocTypes addObject:utiType];
					}
				}
			}
		}
		nonImageUTTypes = [NSSet setWithArray:supportedDocTypes];
	}
}

// Return the names of NSDocument subclasses supported by this application.
// In this app, the only class is "ImageDoc".
//
- (NSArray *)documentClassNames {
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	static NSArray *documentClassNames = nil;
	if (documentClassNames == nil) {
		documentClassNames = @[@"TKImageDocument",
							   @"TKModelDocument",
							   @"TKVMTMaterialDocument",
							   @"MDGCFDocument",
							   @"MDBSPDocument",
							   @"MDNCFDocument",
							   @"MDPAKDocument",
							   @"MDVPKDocument",
							   @"MDWADDocument",
							   @"MDSGADocument",
							   @"MDXZPDocument"];
	}
	return documentClassNames;
}

// Return the name of the document type that should be used when opening a URL
// • For ImageIO images: "In this app, we return the UTI type returned by CGImageSourceGetType."
- (NSString *)typeForContentsOfURL:(NSURL *)absURL error:(NSError **)outError {
//	NSLog(@"[%@ %@] absURL == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), absURL);
	
    NSString *documentUTType = nil;
	NSString *utiType = nil;
	id typeRef = NULL;
	
	if (![absURL getResourceValue:&typeRef forKey:NSURLTypeIdentifierKey error:outError]) {
		return nil;
	}
	
	utiType = (NSString *)(typeRef);
//	NSLog(@"[%@ %@] LSCopyItemAttribute()'s utiType == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), utiType);
	
	if ([[NSWorkspace sharedWorkspace] type:utiType conformsToType:(NSString *)kUTTypeImage] &&
		![utiType isEqualToString:TKVTFType] &&
		![utiType isEqualToString:TKDDSType] &&
		![utiType isEqualToString:TKSFTextureImageType]) {
		// file in question is a generic image, let ImageIO handle it
		
		CGImageSourceRef isrc = CGImageSourceCreateWithURL((CFURLRef)absURL, NULL);
		if (isrc) {
			documentUTType = (__bridge NSString *)CGImageSourceGetType(isrc);
			CFRelease(isrc);
//			NSLog(@"[%@ %@] CGImageSourceGetType()'s documentUTType == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), documentUTType);
			return documentUTType;
		}
	}
	// otherwise, file is one we handle, so let super handle it
	documentUTType = [super typeForContentsOfURL:absURL error:outError];
//	NSLog(@"[%@ %@] super's typeForContentsOfURL:error: == documentUTType == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), documentUTType);
	
	return documentUTType;
}

// Given a document type name, return the subclass of NSDocument
// that should be instantiated when opening a document of that type.
// In this app, the only class is "ImageDoc".
//
- (Class)documentClassForType:(NSString *)typeName {
//	NSLog(@"[%@ %@] type == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), typeName);
	
	if ([nonImageUTTypes containsObject:typeName]) {
		return [super documentClassForType:typeName];
	}
	
    return [[NSBundle mainBundle] classNamed:@"TKImageDocument"];
}

// Given a document type name, return a string describing the document 
// type that is fit to present to the user.
//
- (NSString *)displayNameForType:(NSString *)typeName {
//	NSLog(@"[%@ %@] typeName == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), typeName);
	
	if ([nonImageUTTypes containsObject:typeName]) {
		return [super displayNameForType:typeName];
	}
    return TKImageIOLocalizedString(typeName);
}

// Given a document type, return an array of corresponding file name extensions 
// and HFS file type strings of the sort returned by NSFileTypeForHFSTypeCode().
// In this app, 'typeName' is a UTI type so we can call UTTypeCopyDeclaration().
//
- (NSArray *)fileExtensionsFromType:(NSString *)typeName {
//	NSLog(@"[%@ %@] typeName == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), typeName);
	
    NSArray *readExts = nil;
	
	NSDictionary *utiDeclarations = (NSDictionary *)CFBridgingRelease(UTTypeCopyDeclaration((__bridge CFStringRef)typeName));
	NSDictionary *utiSpec = utiDeclarations[(NSString *)kUTTypeTagSpecificationKey];
	if (utiSpec) {
		id extensions = utiSpec[(NSString *)kUTTagClassFilenameExtension];
		if ([extensions isKindOfClass:[NSString class]]) {
			readExts = @[extensions];
		} else if ([extensions isKindOfClass:[NSArray class]]) {
			readExts = [NSArray arrayWithArray:extensions];
		}
	}
    
    return readExts;
}

@end
