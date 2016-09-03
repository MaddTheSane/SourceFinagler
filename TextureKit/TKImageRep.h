//
//  TKImageRep.h
//  Texture Kit
//
//  Created by Mark Douma on 11/5/2010.
//  Copyright (c) 2010-2013 Mark Douma LLC. All rights reserved.
//

#import <AppKit/NSBitmapImageRep.h>
#import <Foundation/NSDictionary.h>
#import <TextureKit/TextureKitDefines.h>


typedef NS_ENUM(NSUInteger, TKFace) {
	TKFaceRight				= 0,	// +x
	TKFaceLeft				= 1,	// -x
	TKFaceBack				= 2,	// +y
	TKFaceFront				= 3,	// -y
	TKFaceUp				= 4,	// +z
	TKFaceDown				= 5,	// -z
	TKFaceSphereMap			= 6,	// fall back
	TKFaceNone				= NSNotFound
};


NS_ENUM(NSUInteger) {
	TKSliceIndexNone	= NSNotFound,
	TKFrameIndexNone	= NSNotFound,
	TKMipmapIndexNone	= NSNotFound
};


typedef NS_ENUM(NSUInteger, TKDXTCompressionQuality) {
	TKDXTCompressionLowQuality		= 0,
	TKDXTCompressionMediumQuality	= 1,
	TKDXTCompressionHighQuality		= 2,
	TKDXTCompressionHighestQuality	= 3,
	TKDXTCompressionDefaultQuality	= TKDXTCompressionHighQuality,
	TKDXTCompressionNotApplicable	= 1000
};

TEXTUREKIT_EXTERN NSString *NSStringFromDXTCompressionQuality(TKDXTCompressionQuality aQuality);
TEXTUREKIT_EXTERN TKDXTCompressionQuality TKDXTCompressionQualityFromString(NSString *aQuality);


typedef NS_ENUM(NSUInteger, TKPixelFormat) {
	TKPixelFormatXRGB1555,
	TKPixelFormatL,
	TKPixelFormatLA,
	TKPixelFormatA,
	TKPixelFormatRGB,
	TKPixelFormatXRGB,
	TKPixelFormatRGBX,
	TKPixelFormatARGB,
	TKPixelFormatRGBA,
	TKPixelFormatL16,
	TKPixelFormatRGB161616,
	TKPixelFormatRGBA16161616,
	
	TKPixelFormatL32F,
	TKPixelFormatRGB323232F,
	TKPixelFormatRGBA32323232F,
	
	TKPixelFormatRGB565,		// non-native
	TKPixelFormatBGR565,		// non-native
	TKPixelFormatBGRX5551,		// non-native
	TKPixelFormatBGRA5551,		// non-native
	TKPixelFormatBGRA,			// non-native
	TKPixelFormatRGBA16161616F,	// non-native
	TKPixelFormatRGBX5551,		// ?
	
	TKPixelFormatABGR,			// non-native
	TKPixelFormatXBGR,			// non-native
	
	
	
	TKPixelFormatR16F,			// non-native
	TKPixelFormatGR1616F,		// non-native
	TKPixelFormatABGR16161616F,	// non-native
	TKPixelFormatABGR32323232F,	// non-native
	
	TKPixelFormatUnknown			= NSNotFound
};


typedef NS_ENUM(NSUInteger, TKMipmapGenerationType) {
	TKMipmapGenerationNoMipmaps				= 0,
	TKMipmapGenerationUsingBoxFilter		= 1,
	TKMipmapGenerationUsingTriangleFilter	= 2,
	TKMipmapGenerationUsingKaiserFilter		= 3
};

typedef NS_ENUM(NSUInteger, TKWrapMode) {
	TKWrapModeClamp					= 0,
	TKWrapModeRepeat				= 1,
	TKWrapModeMirror				= 2
};

typedef NS_ENUM(NSUInteger, TKRoundMode) {
	TKRoundModeNone					= 0,
	TKRoundModeNextPowerOfTwo		= 1,
	TKRoundModeNearestPowerOfTwo	= 2,
	TKRoundModePreviousPowerOfTwo	= 3
};

typedef NS_ENUM(NSUInteger, TKNormalMapLibrary) {
	TKNormalMapLibraryUseNVIDIATextureTools		= 0,
	TKNormalMapLibraryUseAccelerateFramework	= 1
};



TEXTUREKIT_EXTERN NSString * const TKImageMipmapGenerationKey;
TEXTUREKIT_EXTERN NSString * const TKImageWrapModeKey;
TEXTUREKIT_EXTERN NSString * const TKImageRoundModeKey;



@interface TKImageRep : NSBitmapImageRep <NSCoding, NSCopying> {
	NSUInteger				sliceIndex;
	TKFace					face;
	NSUInteger				frameIndex;
	NSUInteger				mipmapIndex;
	
	TKPixelFormat			pixelFormat;
	CGBitmapInfo			bitmapInfo;
	CGImageAlphaInfo		alphaInfo;
	
	NSDictionary			*imageProperties;
	
}

+ (NSArray *)imageRepsWithData:(NSData *)aData;

+ (id)imageRepWithData:(NSData *)aData;
- (instancetype)initWithData:(NSData *)aData;

- (instancetype)initWithCGImage:(CGImageRef)cgImage sliceIndex:(NSUInteger)aSlice face:(TKFace)aFace frameIndex:(NSUInteger)aFrame mipmapIndex:(NSUInteger)aMipmap;


/* create TKImageRep(s) from NSBitmapImageRep(s) */
+ (id)imageRepWithImageRep:(NSBitmapImageRep *)aBitmapImageRep;
+ (NSArray<TKImageRep*> *)imageRepsWithImageReps:(NSArray<NSBitmapImageRep*> *)bitmapImageReps;



+ (TKDXTCompressionQuality)defaultDXTCompressionQuality;
+ (void)setDefaultDXTCompressionQuality:(TKDXTCompressionQuality)aQuality;
#if __has_feature(objc_class_property)
@property (class) TKDXTCompressionQuality defaultDXTCompressionQuality;
#endif

@property (readonly, nonatomic, assign) NSUInteger sliceIndex;
@property (readonly, nonatomic, assign) TKFace face;
@property (readonly, nonatomic, assign) NSUInteger frameIndex;
@property (readonly, nonatomic, assign) NSUInteger mipmapIndex;

@property (readonly, nonatomic, assign) TKPixelFormat pixelFormat;
@property (readonly, nonatomic, assign) CGBitmapInfo bitmapInfo;
@property (readonly, nonatomic, assign) CGImageAlphaInfo alphaInfo;

@property (retain) NSDictionary *imageProperties;


- (void)setSliceIndex:(NSUInteger)aSliceIndex face:(TKFace)aFace frameIndex:(NSUInteger)aFrameIndex mipmapIndex:(NSUInteger)aMipmapIndex;


- (NSData *)data;

- (NSData *)RGBAData;
- (NSData *)representationUsingPixelFormat:(TKPixelFormat)aPixelFormat;

//- (NSData *)representationForType:(NSString *)utiType;

- (NSComparisonResult)compare:(TKImageRep *)imageRep;


+ (TKImageRep *)imageRepForFace:(TKFace)aFace ofImageRepsInArray:(NSArray *)imageReps;


@end



@interface TKImageRep (TKLargestRepresentationAdditions)

+ (TKImageRep *)largestRepresentationInArray:(NSArray<TKImageRep*> *)tkImageReps;

@end


//TEXTUREKIT_EXTERN NSData *TKImageDataFromNSData(NSData *data, NSUInteger pixelCount, NSUInteger bitsPerPixel, CGBitmapInfo sourceBitmapInfo, CGBitmapInfo destinationBitmapInfo);
//
//TEXTUREKIT_EXTERN NSData *TKBGRADataFromImageData(NSData *data, NSUInteger pixelCount, NSUInteger bitsPerPixel, CGBitmapInfo aCGBitmapInfo);



