//
//  TKImage.h
//  Texture Kit
//
//  Created by Mark Douma on 11/5/2010.
//  Copyright (c) 2010-2013 Mark Douma LLC. All rights reserved.
//

#import <AppKit/NSImage.h>
#import <TextureKit/TextureKitDefines.h>
#import <TextureKit/TKDDSImageRep.h>
#import <TextureKit/TKVTFImageRep.h>

@class NSIndexSet;

typedef NS_ENUM(NSUInteger, TKImageType) {
	TKVTFImageType			= 0, ///< loaded image is a VTF
	TKDDSImageType			= 1, ///< loaded image is a DDS
	TKSFTIImageType			= 2, ///< Source Finagler Texture Image type (NSCoding)
	TKRegularImageType		= 3, ///< loaded image is a native type (anything ImageIO.framework supports)
	TKEmptyImageType		= 4, ///< when an TKImage is created with \c initWithSize: ??
	TKUnknownImageType		= NSNotFound
};

// In VTF images:
// 
//// if sliceCount (depth) > 1, the image must have a single face, frame, and mipmap level
// if sliceCount (depth) > 0, the image must have a single face, frame, and mipmap level

TEXTUREKIT_EXTERN NSString * const TKSFTextureImageType;		// UTI Type
TEXTUREKIT_EXTERN NSString * const TKSFTextureImageFileType;	// filename extension
TEXTUREKIT_EXTERN NSString * const TKSFTextureImagePboardType;

TEXTUREKIT_EXTERN NSData * TKSFTextureImageMagicData;

// 80 / 160
// 72 / 136

@interface TKImage : NSImage <NSCoding, NSCopying> {
	
@private
	id _private;
	
@protected
	
	NSMutableDictionary		*reps;
	
	NSString				*version;
	NSString				*compression;
	
	NSUInteger				sliceCount;
	NSUInteger				faceCount;
	NSUInteger				frameCount;
	NSUInteger				mipmapCount;
	
	TKImageType				imageType;
	
	BOOL					isDepthTexture;
	BOOL					isCubemap;
	BOOL					isSpheremap;
	BOOL					isAnimated;
	BOOL					hasMipmaps;
	BOOL					hasAlpha;
}

- (instancetype)initWithData:(NSData *)aData firstRepresentationOnly:(BOOL)firstRepOnly;

- (void)removeRepresentations:(NSArray *)imageReps;


@property (readonly, nonatomic, assign) NSUInteger sliceCount;
@property (readonly, nonatomic, assign) NSUInteger faceCount;
@property (readonly, nonatomic, assign) NSUInteger frameCount;
@property (readonly, nonatomic, assign) NSUInteger mipmapCount;

@property (readonly, nonatomic, assign, getter=isDepthTexture) BOOL depthTexture;
@property (readonly, nonatomic, assign, getter=isAnimated) BOOL animated;
@property (readonly, nonatomic, assign, getter=isSpheremap) BOOL spheremap;
@property (readonly, nonatomic, assign, getter=isCubemap) BOOL cubemap;
@property (readonly, nonatomic, assign) BOOL hasMipmaps;


@property (nonatomic, assign, setter=setAlpha:) BOOL hasAlpha;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *compression;

@property (nonatomic, assign) TKImageType imageType;


@property (readonly, copy) NSIndexSet *allSliceIndexes;
@property (readonly, copy) NSIndexSet *allFaceIndexes;
@property (readonly, copy) NSIndexSet *allFrameIndexes;
@property (readonly, copy) NSIndexSet *allMipmapIndexes;

@property (readonly, copy) NSIndexSet *mipmapIndexes;

@property (readonly, copy) NSIndexSet *firstSliceIndexSet;
@property (readonly, copy) NSIndexSet *firstFaceIndexSet;
@property (readonly, copy) NSIndexSet *firstFrameIndexSet;
@property (readonly, copy) NSIndexSet *firstMipmapIndexSet;


/* for depth texture images */
- (TKImageRep *)representationForSliceIndex:(NSUInteger)sliceIndex;
- (void)setRepresentation:(TKImageRep *)representation forSliceIndex:(NSUInteger)sliceIndex;
- (void)removeRepresentationForSliceIndex:(NSUInteger)sliceIndex;



/* for static, non-animated texture images */
- (TKImageRep *)representationForMipmapIndex:(NSUInteger)mipmapIndex;
- (void)setRepresentation:(TKImageRep *)representation forMipmapIndex:(NSUInteger)mipmapIndex;
- (void)removeRepresentationForMipmapIndex:(NSUInteger)mipmapIndex;

- (NSArray<TKImageRep*> *)representationsForMipmapIndexes:(NSIndexSet *)mipmapIndexes;
- (void)setRepresentations:(NSArray<TKImageRep*> *)representations forMipmapIndexes:(NSIndexSet *)mipmapIndexes;
- (void)removeRepresentationsForMipmapIndexes:(NSIndexSet *)mipmapIndexes;



/* for animated (multi-frame) texture images */
- (TKImageRep *)representationForFrameIndex:(NSUInteger)frameIndex mipmapIndex:(NSUInteger)mipmapIndex;
- (void)setRepresentation:(TKImageRep *)representation forFrameIndex:(NSUInteger)frameIndex mipmapIndex:(NSUInteger)mipmapIndex;
- (void)removeRepresentationForFrameIndex:(NSUInteger)frameIndex mipmapIndex:(NSUInteger)mipmapIndex;

- (NSArray<TKImageRep*> *)representationsForFrameIndexes:(NSIndexSet *)frameIndexes mipmapIndexes:(NSIndexSet *)mipmapIndexes;								/* USED	*/
- (void)setRepresentations:(NSArray<TKImageRep*> *)representations forFrameIndexes:(NSIndexSet *)frameIndexes mipmapIndexes:(NSIndexSet *)mipmapIndexes;
- (void)removeRepresentationsForFrameIndexes:(NSIndexSet *)frameIndexes mipmapIndexes:(NSIndexSet *)mipmapIndexes;




/* for multi-sided texture images */
- (TKImageRep *)representationForFace:(TKFace)aFace mipmapIndex:(NSUInteger)mipmapIndex;
- (void)setRepresentation:(TKImageRep *)representation forFace:(TKFace)aFace mipmapIndex:(NSUInteger)mipmapIndex;
- (void)removeRepresentationForFace:(TKFace)aFace mipmapIndex:(NSUInteger)mipmapIndex;

- (NSArray<TKImageRep*> *)representationsForFaceIndexes:(NSIndexSet *)faceIndexes mipmapIndexes:(NSIndexSet *)mipmapIndexes;
- (void)setRepresentations:(NSArray<TKImageRep*> *)representations forFaceIndexes:(NSIndexSet *)faceIndexes mipmapIndexes:(NSIndexSet *)mipmapIndexes;
- (void)removeRepresentationsForFaceIndexes:(NSIndexSet *)faceIndexes mipmapIndexes:(NSIndexSet *)mipmapIndexes;



/* for animated (multi-frame), multi-sided texture images */
- (TKImageRep *)representationForFace:(TKFace)aFace frameIndex:(NSUInteger)frameIndex mipmapIndex:(NSUInteger)mipmapIndex;
- (void)setRepresentation:(TKImageRep *)representation forFace:(TKFace)aFace frameIndex:(NSUInteger)frameIndex mipmapIndex:(NSUInteger)mipmapIndex;
- (void)removeRepresentationForFace:(TKFace)aFace frameIndex:(NSUInteger)frameIndex mipmapIndex:(NSUInteger)mipmapIndex;

- (NSArray<TKImageRep*> *)representationsForFaceIndexes:(NSIndexSet *)faceIndexes frameIndexes:(NSIndexSet *)frameIndexes mipmapIndexes:(NSIndexSet *)mipmapIndexes;
- (void)setRepresentations:(NSArray<TKImageRep*> *)representations forFaceIndexes:(NSIndexSet *)faceIndexes frameIndexes:(NSIndexSet *)frameIndexes mipmapIndexes:(NSIndexSet *)mipmapIndexes;
- (void)removeRepresentationsForFaceIndexes:(NSIndexSet *)faceIndexes frameIndexes:(NSIndexSet *)frameIndexes mipmapIndexes:(NSIndexSet *)mipmapIndexes;


- (void)generateMipmapsUsingFilter:(TKMipmapGenerationType)filterType;

- (void)removeMipmaps;


- (NSData *)DDSRepresentationWithOptions:(NSDictionary *)options;
- (NSData *)DDSRepresentationUsingFormat:(TKDDSFormat)aFormat quality:(TKDXTCompressionQuality)aQuality options:(NSDictionary *)options;


- (NSData *)VTFRepresentationWithOptions:(NSDictionary *)options;
- (NSData *)VTFRepresentationUsingFormat:(TKVTFFormat)aFormat quality:(TKDXTCompressionQuality)aQuality options:(NSDictionary *)options;


- (NSData *)dataForType:(NSString *)utiType properties:(NSDictionary *)properties;

@end
