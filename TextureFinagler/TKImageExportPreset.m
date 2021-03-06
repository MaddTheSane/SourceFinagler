//
//  TKImageExportPreset.m
//  Texture Kit
//
//  Created by Mark Douma on 12/11/2010.
//  Copyright (c) 2010-2012 Mark Douma LLC. All rights reserved.
//

#import "TKImageExportPreset.h"

NSString * const TKImageExportNameKey						= @"TKImageExportName";
NSString * const TKImageExportFileTypeKey					= @"TKImageExportFileType";
NSString * const TKImageExportFormatKey						= @"TKImageExportFormat";
NSString * const TKImageExportDXTCompressionQualityKey		= @"TKImageExportDXTCompressionQuality";
NSString * const TKImageExportMipmapGenerationKey			= @"TKImageExportMipmaps";


#define TK_DEBUG 1


@interface TKImageExportPreset (TKPrivate)
- (void)updateName;
@end

extern NSString * const TKImageExportPresetsKey;
static TKImageExportPreset *originalImagePreset = nil;
static NSMutableArray *imagePresets = nil;


@implementation TKImageExportPreset
@synthesize name;
@synthesize fileType;
@synthesize compressionFormat;
@synthesize compressionQuality;
@synthesize mipmapGeneration;

+ (void)initialize {
	if (imagePresets == nil) {
		imagePresets = [[NSMutableArray alloc] init];
		[imagePresets setArray:[TKImageExportPreset imageExportPresetsWithDictionaryRepresentations:[[NSUserDefaults standardUserDefaults] objectForKey:TKImageExportPresetsKey]]];
	}
}

+ (NSArray *)imageExportPresetsWithDictionaryRepresentations:(NSArray *)dictionaryRepresentations {
	if (dictionaryRepresentations == nil) return nil;
	NSMutableArray *imageExportPresets = [NSMutableArray array];
	for (NSDictionary *dictionary in dictionaryRepresentations) {
		TKImageExportPreset *preset = [TKImageExportPreset imageExportPresetWithDictionary:dictionary];
		if (preset) [imageExportPresets addObject:preset];
	}
	NSArray *rImageExportPresets = [imageExportPresets copy];
	return rImageExportPresets;
}

+ (NSArray *)dictionaryRepresentationsOfImageExportPresets:(NSArray *)presets {
	if (presets == nil) return nil;
	NSMutableArray *dictReps = [NSMutableArray array];
	for (TKImageExportPreset *preset in presets) {
		NSDictionary *dictRep = [preset dictionaryRepresentation];
		if (dictRep) [dictReps addObject:dictRep];
	}
	NSArray *rDictReps = [dictReps copy];
	return rDictReps;
}

+ (TKImageExportPreset *)originalImagePreset {
	@synchronized(self) {
		if (originalImagePreset == nil) {
#if TK_DEBUG
			NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
			originalImagePreset = [[[self class] alloc] initWithName:NSLocalizedString(@"Original", @"") fileType:nil compressionFormat:nil compressionQuality:nil mipmapGeneration:TKMipmapGenerationNoMipmaps];
		}
	}
	return originalImagePreset;
}

+ (instancetype)imageExportPresetWithDictionary:(NSDictionary *)aDictionary {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [[[self class] alloc] initWithDictionary:aDictionary];
}

+ (instancetype)imageExportPresetWithName:(NSString *)aName fileType:(NSString *)aFileType compressionFormat:(NSString *)aCompressionFormat compressionQuality:(NSString *)aQuality mipmapGeneration:(TKMipmapGenerationType)aMipmapGeneration {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [[[self class] alloc] initWithName:aName fileType:aFileType compressionFormat:aCompressionFormat compressionQuality:aQuality mipmapGeneration:aMipmapGeneration];
}

- (instancetype)initWithName:(NSString *)aName fileType:(NSString *)aFileType compressionFormat:(NSString *)aCompressionFormat compressionQuality:(NSString *)aQuality mipmapGeneration:(TKMipmapGenerationType)aMipmapGeneration {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super init])) {
		name = [aName copy];
		fileType = [aFileType copy];
		compressionFormat = [aCompressionFormat copy];
		compressionQuality = [aQuality copy];
		mipmapGeneration = aMipmapGeneration;
	}
	return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)aDictionary {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super init])) {
		name = aDictionary[TKImageExportNameKey];
		fileType = aDictionary[TKImageExportFileTypeKey];
		compressionFormat = aDictionary[TKImageExportFormatKey];
		compressionQuality = aDictionary[TKImageExportDXTCompressionQualityKey];
		mipmapGeneration = [aDictionary[TKImageExportMipmapGenerationKey] unsignedIntegerValue];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super init])) {
		name = [coder decodeObjectForKey:TKImageExportNameKey];
		fileType = [coder decodeObjectForKey:TKImageExportFileTypeKey];
		compressionFormat = [coder decodeObjectForKey:TKImageExportFormatKey];
		compressionQuality = [coder decodeObjectForKey:TKImageExportDXTCompressionQualityKey];
		mipmapGeneration = [coder decodeIntegerForKey:TKImageExportMipmapGenerationKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[coder encodeObject:name forKey:TKImageExportNameKey];
	[coder encodeObject:fileType forKey:TKImageExportFileTypeKey];
	[coder encodeObject:compressionFormat forKey:TKImageExportFormatKey];
	[coder encodeObject:compressionQuality forKey:TKImageExportDXTCompressionQualityKey];
	[coder encodeInteger:mipmapGeneration forKey:TKImageExportMipmapGenerationKey];
}

- (id)copyWithZone:(NSZone *)zone {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (self == originalImagePreset) {
		NSLog(@"[%@ %@] **** attempting to copy originalImagePreset; returning self", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return originalImagePreset;
	}
	
	TKImageExportPreset *copy = [[TKImageExportPreset alloc] initWithName:name
																 fileType:fileType
																   compressionFormat:compressionFormat
													   compressionQuality:compressionQuality
														 mipmapGeneration:mipmapGeneration];
	return copy;
}

- (void)setNilValueForKey:(NSString *)key {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ([key isEqualToString:@"mipmapGeneration"]) {
		mipmapGeneration = TKMipmapGenerationNoMipmaps;
	} else {
		[super setNilValueForKey:key];
	}
}

- (void)updateName {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ([imagePresets containsObject:self]) {
		
	}
	
	for (TKImageExportPreset *preset in imagePresets) {
		if ([preset matchesPreset:self]) {
			self.name = preset.name;
			return;
		}
	}
	[self setName:NSLocalizedString(@"[Custom]", @"")];
}

- (void)setFileType:(NSString *)value {
	fileType = [value copy];
	[self updateName];
}

- (void)setCompressionFormat:(NSString *)value {
	compressionFormat = [value copy];
	[self updateName];
}

- (void)setCompressionQuality:(NSString *)value {
	compressionQuality = [value copy];
	[self updateName];
}

- (void)setMipmapGeneration:(TKMipmapGenerationType)aMipmapGeneration {
	mipmapGeneration = aMipmapGeneration;
	[self updateName];
}

- (NSDictionary *)dictionaryRepresentation {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSDictionary *dictionaryRepresentation = @{TKImageExportNameKey: name,
											  TKImageExportFileTypeKey: fileType,
											  TKImageExportFormatKey: compressionFormat,
											  TKImageExportDXTCompressionQualityKey: compressionQuality,
											  TKImageExportMipmapGenerationKey: @(mipmapGeneration)};
	return dictionaryRepresentation;
}

- (BOOL)isEqual:(id)object {
	if (!object || ![object isKindOfClass:[TKImageExportPreset class]]) {
		return NO;
	}
	return [self isEqualToPreset:object];
}

- (BOOL)isEqualToPreset:(TKImageExportPreset *)preset {
	if ([preset.name isEqualToString:NSLocalizedString(@"Original", @"")] &&
		[name isEqualToString:NSLocalizedString(@"Original", @"")] &&
		[preset.name isEqualToString:name]) {
		return YES;
	}
	
	return ([preset.name isEqualToString:name] &&
			[preset.fileType isEqualToString:fileType] &&
			[preset.compressionFormat isEqualToString:compressionFormat] &&
			[preset.compressionQuality isEqualToString:compressionQuality] &&
			preset.mipmapGeneration == mipmapGeneration);
}

// matchesPreset: all but name is equal
- (BOOL)matchesPreset:(TKImageExportPreset *)preset {
	return ([preset.fileType isEqualToString:fileType] &&
			[preset.compressionFormat isEqualToString:compressionFormat] &&
			[preset.compressionQuality isEqualToString:compressionQuality] &&
			preset.mipmapGeneration == mipmapGeneration);
}

- (NSString *)description {
//	NSMutableString *description = [NSMutableString stringWithString:[super description]];
	NSMutableString *description = [NSMutableString string];
	[description appendFormat:@" %@, ", name];
	[description appendFormat:@"%@, ", fileType];
	[description appendFormat:@"%@, ", compressionFormat];
	[description appendFormat:@"%@, ", compressionQuality];
	[description appendFormat:@"mipmapGeneration == %lu", (unsigned long)mipmapGeneration];
	return description;
}

@end

@implementation TKDDSImageRep (TKImageExportPresetAdditions)

+ (NSData *)DDSRepresentationOfImageRepsInArray:(NSArray *)tkImageReps usingPreset:(TKImageExportPreset *)preset {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [[self class] DDSRepresentationOfImageRepsInArray:tkImageReps
												 usingFormat:TKDDSFormatFromString(preset.compressionFormat)
													 quality:TKDXTCompressionQualityFromString(preset.compressionQuality)
													 options:@{TKImageMipmapGenerationKey: @(preset.mipmapGeneration)}];
}

@end


@implementation TKVTFImageRep (TKImageExportPresetAdditions)

+ (NSData *)VTFRepresentationOfImageRepsInArray:(NSArray *)tkImageReps usingPreset:(TKImageExportPreset *)preset {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	return [[self class] VTFRepresentationOfImageRepsInArray:tkImageReps
												 usingFormat:TKVTFFormatFromString(preset.compressionFormat)
													 quality:TKDXTCompressionQualityFromString(preset.compressionQuality)
													 options:@{TKImageMipmapGenerationKey: @(preset.mipmapGeneration)}];
}

@end
