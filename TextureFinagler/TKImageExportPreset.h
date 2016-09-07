//
//  TKImageExportPreset.h
//  Texture Kit
//
//  Created by Mark Douma on 12/11/2010.
//  Copyright (c) 2010-2012 Mark Douma LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TextureKit/TextureKit.h>


TEXTUREKIT_EXTERN NSString * const TKImageExportNameKey;					// NSString with name
TEXTUREKIT_EXTERN NSString * const TKImageExportFileTypeKey;				// NSString with name
TEXTUREKIT_EXTERN NSString * const TKImageExportFormatKey;					// NSString with name
TEXTUREKIT_EXTERN NSString * const TKImageExportDXTCompressionQualityKey;	// NSString with name
TEXTUREKIT_EXTERN NSString * const TKImageExportMipmapGenerationKey;		// NSNumber with NSUInteger value


@interface TKImageExportPreset : NSObject <NSCoding, NSCopying> {
	NSString					*name;
	NSString					*fileType;
	NSString					*compressionFormat;
	NSString					*compressionQuality;
	TKMipmapGenerationType		mipmapGeneration;
	
}

+ (NSArray<TKImageExportPreset*> *)imageExportPresetsWithDictionaryRepresentations:(NSArray<NSDictionary<NSString*,id>*> *)dictionaryRepresentations;
+ (NSArray<NSDictionary<NSString*,id>*> *)dictionaryRepresentationsOfImageExportPresets:(NSArray<TKImageExportPreset*> *)presets;


+ (TKImageExportPreset *)originalImagePreset;
#if __has_feature(objc_class_property)
@property (class, readonly, copy) TKImageExportPreset *originalImagePreset;
#endif

+ (instancetype)imageExportPresetWithDictionary:(NSDictionary *)aDictionary;
- (instancetype)initWithDictionary:(NSDictionary *)aDictionary NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

+ (instancetype)imageExportPresetWithName:(NSString *)aName fileType:(NSString *)aFileType compressionFormat:(NSString *)aCompressionFormat compressionQuality:(NSString *)aQuality mipmapGeneration:(TKMipmapGenerationType)aMipmapGeneration;
- (instancetype)initWithName:(NSString *)aName fileType:(NSString *)aFileType compressionFormat:(NSString *)aCompressionFormat compressionQuality:(NSString *)aQuality mipmapGeneration:(TKMipmapGenerationType)aMipmapGeneration NS_DESIGNATED_INITIALIZER;


@property (copy) NSString *name;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, copy) NSString *compressionFormat;
@property (nonatomic, copy) NSString *compressionQuality;
@property (nonatomic, assign) TKMipmapGenerationType mipmapGeneration;


- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToPreset:(TKImageExportPreset *)preset;

// matchesPreset: all but name is equal
- (BOOL)matchesPreset:(TKImageExportPreset *)preset;

- (NSDictionary *)dictionaryRepresentation;

@end

@interface TKDDSImageRep (TKImageExportPresetAdditions)
+ (NSData *)DDSRepresentationOfImageRepsInArray:(NSArray *)tkImageReps usingPreset:(TKImageExportPreset *)preset;
@end

@interface TKVTFImageRep (TKImageExportPresetAdditions)
+ (NSData *)VTFRepresentationOfImageRepsInArray:(NSArray *)tkImageReps usingPreset:(TKImageExportPreset *)preset;
@end
