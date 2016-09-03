//
//  TKImageExportPreset.h
//  Texture Kit
//
//  Created by Mark Douma on 12/11/2010.
//  Copyright (c) 2010-2011 Mark Douma LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TextureKit/TKVTFImageRep.h>
#import <TextureKit/TKDDSImageRep.h>


TEXTUREKIT_EXTERN NSString * const TKImageExportNameKey;					// NSString with name
TEXTUREKIT_EXTERN NSString * const TKImageExportFileTypeKey;				// NSString with name
TEXTUREKIT_EXTERN NSString * const TKImageExportFormatKey;					// NSString with name
TEXTUREKIT_EXTERN NSString * const TKImageExportDXTCompressionQualityKey;	// NSString with name
TEXTUREKIT_EXTERN NSString * const TKImageExportMipmapsKey;					// NSNumber with BOOL value



@interface TKImageExportPreset : NSObject <NSCoding, NSCopying> {
	NSString					*name;
	NSString					*fileType;
	NSString					*format;
	NSString					*compressionQuality;
	BOOL						mipmaps;
	
}

+ (NSArray *)imageExportPresetsWithContentsOfArrayAtPath:(NSString *)aPath;
+ (NSArray *)dictionaryRepresentationsOfImageExportPresets:(NSArray *)presets;



+ (instancetype)imageExportPresetWithDictionary:(NSDictionary *)aDictionary;
- (instancetype)initWithDictionary:(NSDictionary *)aDictionary;

+ (instancetype)imageExportPresetWithName:(NSString *)aName fileType:(NSString *)aFileType format:(NSString *)aFormat compressionQuality:(NSString *)aQuality mipmaps:(BOOL)aMipmaps;
- (instancetype)initWithName:(NSString *)aName fileType:(NSString *)aFileType format:(NSString *)aFormat compressionQuality:(NSString *)aQuality mipmaps:(BOOL)aMipmaps;


@property (copy) NSString	*name;
@property (copy) NSString *fileType;
@property (copy) NSString *format;
@property (copy) NSString *compressionQuality;
@property (assign) BOOL mipmaps;

- (NSDictionary *)dictionaryRepresentation;

@end


