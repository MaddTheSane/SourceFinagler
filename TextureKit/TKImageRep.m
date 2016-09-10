//
//  TKImageRep.m
//  Texture Kit
//
//  Created by Mark Douma on 11/5/2010.
//  Copyright (c) 2010-2013 Mark Douma LLC. All rights reserved.
//

#import <TextureKit/TKImageRep.h>
#include <CoreServices/CoreServices.h>

#import <TextureKit/TKDDSImageRep.h>
#import <TextureKit/TKVTFImageRep.h>

#include <Accelerate/Accelerate.h>

#import "TKFoundationAdditions.h"
#import "TKPrivateInterfaces.h"



#define TK_DEBUG 1


static NSString * const TKImageRepSliceIndexKey			= @"TKImageRepSliceIndex";
static NSString * const TKImageRepFaceKey				= @"TKImageRepFace";
static NSString * const TKImageRepFrameIndexKey			= @"TKImageRepFrameIndex";
static NSString * const TKImageRepMipmapIndexKey		= @"TKImageRepMipmapIndex";

static NSString * const TKImageRepBitmapInfoKey			= @"TKImageRepBitmapInfo";
static NSString * const TKImageRepPixelFormatKey		= @"TKImageRepPixelFormat";

static NSString * const TKImageRepImagePropertiesKey	= @"TKImageRepImageProperties";


NSString * const TKImageMipmapGenerationKey				= @"TKImageMipmapGeneration";
NSString * const TKImageWrapModeKey						= @"TKImageWrapMode";
NSString * const TKImageRoundModeKey					= @"TKImageRoundMode";


//typedef struct TKPixelFormatInfo {
//	TKPixelFormat			pixelFormat;
//	NSUInteger				bitsPerComponent;
//	NSUInteger				bitsPerPixel;
//	CGBitmapInfo			bitmapInfo;
//	CGColorSpaceModel		colorSpaceModel;
//	CGColorRenderingIntent	renderingIntent;
//} TKPixelFormatInfo;
//
//static const TKPixelFormatInfo TKPixelFormatInfoTable[] = {
//	{TKPixelFormatXRGB1555,			5, 16, kCGImageAlphaNoneSkipFirst, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatL,				8, 8,  kCGImageAlphaNone,	kCGColorSpaceModelMonochrome,	kCGRenderingIntentDefault},
//	{TKPixelFormatLA,				8, 16, kCGImageAlphaPremultipliedLast, kCGColorSpaceModelMonochrome,	 kCGRenderingIntentDefault},
//	{TKPixelFormatA,				8, 8,  kCGImageAlphaOnly, kCGColorSpaceModelUnknown, kCGRenderingIntentDefault},
//	{TKPixelFormatRGB,				8, 24, kCGImageAlphaNone, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatXRGB,				8, 32, kCGImageAlphaNoneSkipFirst, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatRGBX,				8, 32, kCGImageAlphaNoneSkipLast, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatARGB,				8, 32, kCGImageAlphaPremultipliedFirst, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatRGBA,				8, 32, kCGImageAlphaPremultipliedLast, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatRGB161616,		16, 48, kCGImageAlphaNone | kCGBitmapByteOrder16Host, kCGColorSpaceModelRGB, kCGRenderingIntentDefault},
//	{TKPixelFormatRGBA16161616,		16, 64, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder16Host, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatRGBA16161616F,	16, 64, kCGImageAlphaPremultipliedLast | kCGBitmapFloatComponents | kCGBitmapByteOrder16Host, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatL32F,				32, 32, kCGImageAlphaNone | kCGBitmapFloatComponents | kCGBitmapByteOrder32Host, kCGColorSpaceModelMonochrome, kCGRenderingIntentDefault},
//	{TKPixelFormatRGB323232F,		32, 96, kCGImageAlphaNone | kCGBitmapFloatComponents | kCGBitmapByteOrder32Host, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatRGBA32323232F,	32, 128, kCGImageAlphaPremultipliedLast | kCGBitmapFloatComponents | kCGBitmapByteOrder32Host, kCGColorSpaceModelRGB, kCGRenderingIntentDefault},
//	{TKPixelFormatRGB565,			5, 16, kCGImageAlphaNoneSkipFirst, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatBGR565,			5, 16, kCGImageAlphaNoneSkipFirst, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatBGRX5551,			5, 16, kCGImageAlphaNoneSkipLast, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatBGRA5551,			5, 16, kCGImageAlphaNoneSkipFirst, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//	{TKPixelFormatBGRA,				8, 32, kCGImageAlphaPremultipliedLast, kCGColorSpaceModelRGB,	kCGRenderingIntentDefault},
//};
//static const NSUInteger TKPixelFormatInfoTableCount = sizeof(TKPixelFormatInfoTable)/sizeof(TKPixelFormatInfoTable[0]);
//
//
//static inline TKPixelFormat TKPixelFormatFromCGImage(CGImageRef imageRef) {
//	NSCParameterAssert(imageRef != NULL);
//	size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
//	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
//	for (NSUInteger i = 0; i < TKPixelFormatInfoTableCount; i++) {
//		if (TKPixelFormatInfoTable[i].bitsPerPixel == bitsPerPixel && TKPixelFormatInfoTable[i].bitmapInfo == bitmapInfo) {
//			return TKPixelFormatInfoTable[i].pixelFormat;
//		}
//	}
//	return TKPixelFormatUnknown;
//}
//
//static inline TKPixelFormatInfo TKPixelFormatInfoFromPixelFormat(TKPixelFormat aPixelFormat) {
//	NSCParameterAssert(aPixelFormat < TKPixelFormatInfoTableCount);
//	for (NSUInteger i = 0; i < TKPixelFormatInfoTableCount; i++) {
//		if (TKPixelFormatInfoTable[i].pixelFormat == aPixelFormat) {
//			TKPixelFormatInfo pixelFormatInfo = {TKPixelFormatInfoTable[i].pixelFormat,
//				                                 TKPixelFormatInfoTable[i].bitsPerComponent,
//				                                 TKPixelFormatInfoTable[i].bitsPerPixel,
//				                                 TKPixelFormatInfoTable[i].bitmapInfo,
//												 TKPixelFormatInfoTable[i].colorSpaceModel,
//												 TKPixelFormatInfoTable[i].renderingIntent,
//												 };
//			return pixelFormatInfo;
//		}
//	}
//	TKPixelFormatInfo pixelFormatInfo = {0, 0, 0, 0, kCGColorSpaceModelUnknown, kCGRenderingIntentDefault};
//	return pixelFormatInfo;
//}

typedef struct TKDXTCompressionQualityDescription {
	TKDXTCompressionQuality		compressionQuality;
	const char					*description;
} TKDXTCompressionQualityDescription;

static const TKDXTCompressionQualityDescription TKDXTCompressionQualityDescriptionTable[] = {
	{ TKDXTCompressionLowQuality, "Low" },
	{ TKDXTCompressionMediumQuality, "Medium" },
	{ TKDXTCompressionHighQuality, "High" },
	{ TKDXTCompressionHighestQuality, "Highest" },
	{ TKDXTCompressionDefaultQuality, "Default" },
	{ TKDXTCompressionNotApplicable, "N/A" }
};
static const NSUInteger TKDXTCompressionQualityDescriptionTableCount = sizeof(TKDXTCompressionQualityDescriptionTable)/sizeof(TKDXTCompressionQualityDescription);

NSString *NSStringFromDXTCompressionQuality(TKDXTCompressionQuality aQuality) {
	for (NSUInteger i = 0; i < TKDXTCompressionQualityDescriptionTableCount; i++) {
		if (TKDXTCompressionQualityDescriptionTable[i].compressionQuality == aQuality) {
			return @(TKDXTCompressionQualityDescriptionTable[i].description);
		}
	}
	return @"<Unknown>";
}

TKDXTCompressionQuality TKDXTCompressionQualityFromString(NSString *aQuality) {
	for (NSUInteger i = 0; i < TKDXTCompressionQualityDescriptionTableCount; i++) {
		if ([@(TKDXTCompressionQualityDescriptionTable[i].description) isEqualToString:aQuality]) {
			return TKDXTCompressionQualityDescriptionTable[i].compressionQuality;
		}
	}
	return TKDXTCompressionDefaultQuality;
}


@interface TKImageRep ()

@property (nonatomic, assign) NSUInteger sliceIndex;
@property (nonatomic, assign) TKFace face;
@property (nonatomic, assign) NSUInteger frameIndex;
@property (nonatomic, assign) NSUInteger mipmapIndex;

@property (nonatomic, assign) TKPixelFormat pixelFormat;
@property (nonatomic, assign) CGBitmapInfo bitmapInfo;
@property (nonatomic, assign) CGImageAlphaInfo alphaInfo;


@end


@interface TKImageRep (TKPrivate)

+ (NSArray *)imageRepsWithData:(NSData *)aData firstRepresentationOnly:(BOOL)firstRepOnly;
- (void)getBitmapInfoAndPixelFormatIfNecessary;
@end

static NSArray *handledUTITypes = nil;
static NSArray *handledFileTypes = nil;

static TKDXTCompressionQuality defaultDXTCompressionQuality = TKDXTCompressionDefaultQuality;


@implementation TKImageRep

@synthesize sliceIndex;
@synthesize face;
@synthesize frameIndex;
@synthesize mipmapIndex;

@dynamic pixelFormat;
@dynamic bitmapInfo;
@dynamic alphaInfo;

@synthesize imageProperties;


/* Implemented by subclassers to indicate what UTI-identified data types they can deal with. */
+ (NSArray *)imageUnfilteredTypes {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
#if TK_DEBUG
//	NSArray *superTypes = [super imageUnfilteredTypes];
//	NSLog(@"[%@ %@] super's imageUnfilteredTypes == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), superTypes);
#endif
	
	if (handledUTITypes == nil) {
		handledUTITypes = CFBridgingRelease(CGImageSourceCopyTypeIdentifiers());
#if TK_DEBUG
//		NSLog(@"[%@ %@] CGImageSourceCopyTypeIdentifiers() == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), handledUTITypes);
#endif
	}
	return handledUTITypes;
}



+ (NSArray *)imageUnfilteredFileTypes {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
//	NSArray *superTypes = [super imageUnfilteredFileTypes];
//	NSLog(@"[%@ %@] super's imageUnfilteredFileTypes == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), superTypes);
	
	if (handledFileTypes == nil) {
		NSMutableArray *mFileTypes = [NSMutableArray array];
		
		NSArray *utiTypes = CFBridgingRelease(CGImageSourceCopyTypeIdentifiers());
		if (utiTypes && utiTypes.count) {
			for (NSString *utiType in utiTypes) {
				NSDictionary *utiDeclarations = CFBridgingRelease(UTTypeCopyDeclaration((__bridge CFStringRef)utiType));
				NSDictionary *utiSpec = utiDeclarations[(NSString *)kUTTypeTagSpecificationKey];
				if (utiSpec) {
					id extensions = utiSpec[(NSString *)kUTTagClassFilenameExtension];
					if ([extensions isKindOfClass:[NSString class]]) {
						[mFileTypes addObject:extensions];
					} else {
						[mFileTypes addObjectsFromArray:extensions];
					}
				}
			}
		}
		
//		NSLog(@"[%@ %@] utiTypes == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), utiTypes);
//		NSLog(@"[%@ %@] fileTypes == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), fileTypes);
		
		handledFileTypes = [mFileTypes copy];
		
	}
//	NSLog(@"[%@ %@] handledFileTypes == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), handledFileTypes);
	
	return handledFileTypes;
}


+ (NSArray *)imageUnfilteredPasteboardTypes {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	static NSArray *imageUnfilteredPasteboardTypes = nil;
	
	if (imageUnfilteredPasteboardTypes == nil) {
		NSArray *types = [super imageUnfilteredPasteboardTypes];
#if TK_DEBUG
//		NSLog(@"[%@ %@] super's imageUnfilteredPasteboardTypes == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), types);
#endif
		imageUnfilteredPasteboardTypes = types;
	}
	return imageUnfilteredPasteboardTypes;
}

//+ (BOOL)canInitWithPasteboard:(NSPasteboard *)pasteboard {
//	
//}


+ (BOOL)canInitWithData:(NSData *)aData {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ([TKVTFImageRep canInitWithData:aData] ||
		[TKDDSImageRep canInitWithData:aData]) {
		return NO;
	}
	return YES;
}
	

+ (Class)imageRepClassForType:(NSString *)aType {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ([handledUTITypes containsObject:aType]) {
		return [self class];
	}
	return [super imageRepClassForType:aType];
}

+ (Class)imageRepClassForFileType:(NSString *)fileType {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ([handledFileTypes containsObject:fileType]) {
		return [self class];
	}
	return [super imageRepClassForFileType:fileType];
}


+ (TKDXTCompressionQuality)defaultDXTCompressionQuality {
	TKDXTCompressionQuality rDefaultDXTCompressionQuality = 0;
	@synchronized(self) {
		rDefaultDXTCompressionQuality = defaultDXTCompressionQuality;
	}
	return rDefaultDXTCompressionQuality;
}


+ (void)setDefaultDXTCompressionQuality:(TKDXTCompressionQuality)aQuality {
	@synchronized(self) {
		defaultDXTCompressionQuality = aQuality;
	}
}


+ (NSArray *)imageRepsWithData:(NSData *)aData firstRepresentationOnly:(BOOL)firstRepOnly {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)aData, NULL);
	if (source == NULL) {
		NSLog(@"[%@ %@] CGImageSourceCreateWithData() failed!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return nil;
	}
	
	NSUInteger imageCount = (NSUInteger)CGImageSourceGetCount(source);
#if TK_DEBUG
	NSLog(@"[%@ %@] imageCount == %lu", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)imageCount);
#endif
	
	
	// build options dictionary for image creation that specifies: 
	//
	// kCGImageSourceShouldCache = kCFBooleanTrue
	//      Specifies that image should be cached in a decoded form.
	//
	// kCGImageSourceShouldAllowFloat = kCFBooleanTrue
	//      Specifies that image should be returned as a floating
	//      point CGImageRef if supported by the file format.
	
	NSDictionary *options = @{(id)kCGImageSourceShouldCache: @YES,
																	   (id)kCGImageSourceShouldAllowFloat: @YES};
	
	NSMutableArray *imageReps = [NSMutableArray array];
	
	for (NSUInteger i = 0; i < imageCount; i++) {
		CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, (CFDictionaryRef)options);
		
		if (imageRef) {
			// Assign user preferred default profiles if image is not tagged with a profile
			//		imageRef = CGImageCreateCopyWithDefaultSpace(image);
			
			
//#if TK_DEBUG
//			NSDictionary *metadata = [(NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, i, (CFDictionaryRef)options) autorelease];
//			NSLog(@"[%@ %@] metadata == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), metadata);
//#endif
			
			NSDictionary *properties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, i, (CFDictionaryRef)options));
			
			TKImageRep *imageRep = [[TKImageRep alloc] initWithCGImage:imageRef
															sliceIndex:TKSliceIndexNone
																  face:TKFaceNone
															frameIndex:TKFrameIndexNone
														   mipmapIndex:i];
			
			if (imageRep) {
				imageRep.imageProperties = properties;
				
				[imageReps addObject:imageRep];
			}
			CGImageRelease(imageRef);
		}
		
		if (firstRepOnly && i == 0) {
			CFRelease(source);
			return [imageReps copy];
		}
	}
	
	CFRelease(source);

	return [imageReps copy];
}



+ (NSArray *)imageRepsWithData:(NSData *)aData {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [[self class] imageRepsWithData:aData firstRepresentationOnly:NO];
}

+ (instancetype)imageRepWithData:(NSData *)aData {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSArray *imageReps = [[self class] imageRepsWithData:aData firstRepresentationOnly:YES];
	return imageReps.firstObject;
}


- (instancetype)initWithData:(NSData *)aData {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSArray *imageReps = [[self class] imageRepsWithData:aData firstRepresentationOnly:YES];
	return self = imageReps.firstObject;
}

- (instancetype)init {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super init])) {
		sliceIndex = TKSliceIndexNone;
		face = TKFaceNone;
		frameIndex = TKFrameIndexNone;
		mipmapIndex = 0;
		bitmapInfo = UINT_MAX;
		alphaInfo = UINT_MAX;
		pixelFormat = TKPixelFormatUnknown;
	}
	return self;
}


/* create TKImageRep(s) from NSBitmapImageRep(s) */

+ (instancetype)imageRepWithImageRep:(NSBitmapImageRep *)aBitmapImageRep {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ([aBitmapImageRep isKindOfClass:[TKImageRep class]]) {
		return [[[self class] alloc] initWithCGImage:aBitmapImageRep.CGImage
										   sliceIndex:((TKImageRep *)aBitmapImageRep).sliceIndex
												 face:((TKImageRep *)aBitmapImageRep).face
										   frameIndex:((TKImageRep *)aBitmapImageRep).frameIndex
										  mipmapIndex:((TKImageRep *)aBitmapImageRep).mipmapIndex];
	}
	return [[[self class] alloc] initWithCGImage:aBitmapImageRep.CGImage];
}


+ (NSArray *)imageRepsWithImageReps:(NSArray *)bitmapImageReps {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSMutableArray *imageReps = [NSMutableArray array];
	for (NSBitmapImageRep *imageRep in bitmapImageReps) {
		TKImageRep *tkImageRep = [[self class] imageRepWithImageRep:imageRep];
		if (tkImageRep) [imageReps addObject:tkImageRep];
	}
	return imageReps;
}


- (instancetype)initWithCGImage:(CGImageRef)cgImage {
	return [self initWithCGImage:cgImage
					  sliceIndex:TKSliceIndexNone
							face:TKFaceNone
					  frameIndex:TKFrameIndexNone
					 mipmapIndex:0];
}



- (instancetype)initWithCGImage:(CGImageRef)cgImage sliceIndex:(NSUInteger)aSlice face:(TKFace)aFace frameIndex:(NSUInteger)aFrame mipmapIndex:(NSUInteger)aMipmap {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super initWithCGImage:cgImage])) {
		self.frameIndex = aFrame;
		self.mipmapIndex = aMipmap;
		self.face = aFace;
		self.sliceIndex = aSlice;
		self.bitmapInfo = CGImageGetBitmapInfo(cgImage);
		self.alphaInfo = CGImageGetAlphaInfo(cgImage);
		self.pixelFormat = TKPixelFormatFromCGImage(cgImage);
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super initWithCoder:coder])) {
		self.sliceIndex = [coder decodeIntegerForKey:TKImageRepSliceIndexKey];
		self.face = [coder decodeIntegerForKey:TKImageRepFaceKey];
		self.frameIndex = [coder decodeIntegerForKey:TKImageRepFrameIndexKey];
		self.mipmapIndex = [coder decodeIntegerForKey:TKImageRepMipmapIndexKey];
		
		self.bitmapInfo = [[coder decodeObjectForKey:TKImageRepBitmapInfoKey] unsignedIntValue];
		self.pixelFormat = [coder decodeIntegerForKey:TKImageRepPixelFormatKey];
		
		self.imageProperties = [coder decodeObjectForKey:TKImageRepImagePropertiesKey];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[super encodeWithCoder:coder];
	
	[coder encodeInteger:sliceIndex forKey:TKImageRepSliceIndexKey];
	[coder encodeInteger:face forKey:TKImageRepFaceKey];
	[coder encodeInteger:frameIndex forKey:TKImageRepFrameIndexKey];
	[coder encodeInteger:mipmapIndex forKey:TKImageRepMipmapIndexKey];
	
	[coder encodeObject:@(bitmapInfo) forKey:TKImageRepBitmapInfoKey];
	[coder encodeInteger:pixelFormat forKey:TKImageRepPixelFormatKey];
	
	[coder encodeObject:imageProperties forKey:TKImageRepImagePropertiesKey];
}

- (id)copyWithZone:(NSZone *)zone {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	TKImageRep *copy = (TKImageRep *)[super copyWithZone:zone];
#if TK_DEBUG
//	NSLog(@"[%@ %@] copy == %@, class == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), copy, NSStringFromClass([copy class]));
#endif
	copy->imageProperties = nil;
	copy.imageProperties = imageProperties;
	return copy;
}

- (NSData *)data {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self getBitmapInfoAndPixelFormatIfNecessary];
	CGImageRef imageRef = self.CGImage;
	NSData *imageData = CFBridgingRelease(CGDataProviderCopyData(CGImageGetDataProvider(imageRef)));
	return imageData;
//	return [(NSData *)CGDataProviderCopyData(CGImageGetDataProvider(imageRef)) autorelease];
}


//- (void)setAlpha:(BOOL)flag {
//#if TK_DEBUG
//	NSLog(@"[%@ %@] *************** flag == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (flag == YES ? @"YES" : @"NO"));
//#endif
//	[super setAlpha:flag];
//}
//
//
//- (BOOL)hasAlpha {
//	BOOL supersHasAlpha = [super hasAlpha];
//#if TK_DEBUG
//	NSLog(@"[%@ %@] *************** supersHasAlpha == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (supersHasAlpha == YES ? @"YES" : @"NO"));
//#endif
//	return supersHasAlpha;
//}


- (void)getBitmapInfoAndPixelFormatIfNecessary {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (bitmapInfo == UINT_MAX) {
#if TK_DEBUG
//		NSLog(@"[%@ %@] bitmapInfo == UINT_MAX", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
		CGImageRef imageRef = self.CGImage;
		self.bitmapInfo = CGImageGetBitmapInfo(imageRef);
	}
	if (alphaInfo == UINT_MAX) {
		CGImageRef imageRef = self.CGImage;
		self.alphaInfo = CGImageGetAlphaInfo(imageRef);
	}
	if (pixelFormat == TKPixelFormatUnknown) {
#if TK_DEBUG
//		NSLog(@"[%@ %@] pixelFormat == TKPixelFormatUnknown", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
		CGImageRef imageRef = self.CGImage;
		self.pixelFormat = TKPixelFormatFromCGImage(imageRef);
	}
}



- (CGBitmapInfo)bitmapInfo {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self getBitmapInfoAndPixelFormatIfNecessary];
	return bitmapInfo;
}

- (void)setBitmapInfo:(CGBitmapInfo)aBitmapInfo {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	bitmapInfo = aBitmapInfo;
}


- (CGImageAlphaInfo)alphaInfo {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self getBitmapInfoAndPixelFormatIfNecessary];
	return alphaInfo;
}

- (void)setAlphaInfo:(CGImageAlphaInfo)info {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	alphaInfo = info;
}


- (TKPixelFormat)pixelFormat {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self getBitmapInfoAndPixelFormatIfNecessary];
	return pixelFormat;
}

- (void)setPixelFormat:(TKPixelFormat)aFormat {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	pixelFormat = aFormat;
}

- (NSData *)RGBAData {
	return [self representationUsingPixelFormat:TKPixelFormatRGBA];
}

- (NSData *)representationUsingPixelFormat:(TKPixelFormat)aPixelFormat {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self getBitmapInfoAndPixelFormatIfNecessary];
	
	if (aPixelFormat == pixelFormat) return self.data;
	
	CGImageRef imageRef = self.CGImage;
	TKPixelFormatInfo pixelFormatInfo = TKPixelFormatInfoFromPixelFormat(aPixelFormat);
	
	
	
	
//	if (pixelFormatInfo == NULL) return nil;
	
	
	
	
	
	
	
	
	
	size_t newLength = CGImageGetWidth(imageRef) * (pixelFormatInfo.bitsPerPixel / 8) * CGImageGetHeight(imageRef);
	
	if (newLength == 0) return nil;
	
	void *bitmapData = malloc(newLength);
	if (bitmapData == NULL) {
		NSLog(@"[%@ %@] malloc(%llu) failed!", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long long)newLength);
		return nil;
	}
	
	size_t imageWidth = CGImageGetWidth(imageRef);
	size_t imageHeight = CGImageGetHeight(imageRef);
	
	size_t bitsPerComponent = pixelFormatInfo.bitsPerPixel/4;
	size_t bytesPerRow = CGImageGetWidth(imageRef) * (pixelFormatInfo.bitsPerPixel / 8);
	
	CGColorSpaceRef colorspace = CGImageGetColorSpace(imageRef);
	if (colorspace == NULL) {
		NSLog(@"[%@ %@] CGImageGetColorSpace(imageRef) returned NULL", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//		colorspace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
		colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	} else {
		CGColorSpaceRetain(colorspace);
	}
	
	CGContextRef bitmapContext = CGBitmapContextCreate(bitmapData,
													   imageWidth,
													   imageHeight,
													   bitsPerComponent,
													   bytesPerRow,
													   colorspace,
													   pixelFormatInfo.bitmapInfo);
	if (bitmapContext == NULL) {
		NSLog(@"[%@ %@] CGBitmapContextCreate() returned NULL!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		CGColorSpaceRelease(colorspace);
		free(bitmapData);
		return nil;
	}
	
	CGContextDrawImage(bitmapContext, CGRectMake(0.0, 0.0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
	NSData *repData = [NSData dataWithBytes:bitmapData length:newLength];
	CGContextRelease(bitmapContext);
	CGColorSpaceRelease(colorspace);
	free(bitmapData);
	return repData;
}


void TKInitBuffer(vImage_Buffer *result, int height, int width, size_t bytesPerPixel) {
	size_t rowBytes = width * bytesPerPixel;
	
	//Widen rowBytes out to a integer multiple of 16 bytes
	rowBytes = (rowBytes + 15) & ~15;
	
	//Make sure we are not an even power of 2 wide. 
	//Will loop a few times for rowBytes <= 16.
	
	while (0 == (rowBytes & (rowBytes - 1)))
		rowBytes += 16;	//grow rowBytes
	
	//Set up the buffer
	result->height = height;
	result->width = width;
	result->rowBytes = rowBytes;
	result->data = malloc(rowBytes * height); 
}

void TKFreeBuffer(vImage_Buffer *buffer) {
	if (buffer && buffer->data)
		free(buffer->data);
}


+ (NSData *)dataRepresentationOfData:(NSData *)data inPixelFormat:(TKPixelFormat)sourcePixelFormat size:(NSSize)size usingPixelFormat:(TKPixelFormat)destPixelFormat {
	NSParameterAssert(data != nil);
	if (sourcePixelFormat == destPixelFormat) return data;
//#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//#endif
	
	if ((sourcePixelFormat == TKPixelFormatRGBA16161616F || sourcePixelFormat == TKPixelFormatABGR16161616F) && destPixelFormat == TKPixelFormatRGBA32323232F) {
		
		vImage_Buffer preSourceBuffer;
		preSourceBuffer.data = (void*)data.bytes;
		preSourceBuffer.height = size.height;
		preSourceBuffer.width = size.width;
		preSourceBuffer.rowBytes = size.width * sizeof(UInt16)  * 4;

		//First, convert it to a full float:
		vImage_Buffer sourceBuffer;
		TKInitBuffer(&sourceBuffer, size.height, size.width, 32);
		
		vImage_Error error = vImageConvert_Planar16FtoPlanarF(&preSourceBuffer, &sourceBuffer, kvImageNoFlags);
		
		if (error != kvImageNoError) {
			NSLog(@"[%@ %@] vImageConvert_Planar16FtoPlanarF() returned %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned int)error);
			
		}

		NSMutableData *rData = [NSMutableData dataWithLength:size.width * size.height * sizeof(float)];
		NSMutableData *gData = [NSMutableData dataWithLength:size.width * size.height * sizeof(float)];
		NSMutableData *bData = [NSMutableData dataWithLength:size.width * size.height * sizeof(float)];
		NSMutableData *aData = [NSMutableData dataWithLength:size.width * size.height * sizeof(float)];
		vImage_Buffer rBuffer;
		rBuffer.height = size.height;
		rBuffer.width = size.width;
		rBuffer.rowBytes = size.width * sizeof(float);
		vImage_Buffer gBuffer;
		vImage_Buffer bBuffer;
		vImage_Buffer aBuffer;
		
		gBuffer = bBuffer = aBuffer = rBuffer;
		
		rBuffer.data = rData.mutableBytes;
		gBuffer.data = gData.mutableBytes;
		bBuffer.data = bData.mutableBytes;
		aBuffer.data = aData.mutableBytes;
		
		switch (sourcePixelFormat) {
			case TKPixelFormatRGBA16161616F:
				vImageExtractChannel_ARGBFFFF(&sourceBuffer, &rBuffer, 0, kvImageNoFlags);
				vImageExtractChannel_ARGBFFFF(&sourceBuffer, &gBuffer, 1, kvImageNoFlags);
				vImageExtractChannel_ARGBFFFF(&sourceBuffer, &bBuffer, 2, kvImageNoFlags);
				vImageExtractChannel_ARGBFFFF(&sourceBuffer, &aBuffer, 3, kvImageNoFlags);
				break;
				
			case TKPixelFormatABGR16161616F:
				vImageExtractChannel_ARGBFFFF(&sourceBuffer, &aBuffer, 0, kvImageNoFlags);
				vImageExtractChannel_ARGBFFFF(&sourceBuffer, &bBuffer, 1, kvImageNoFlags);
				vImageExtractChannel_ARGBFFFF(&sourceBuffer, &gBuffer, 2, kvImageNoFlags);
				vImageExtractChannel_ARGBFFFF(&sourceBuffer, &rBuffer, 3, kvImageNoFlags);
				break;
				
			default:
				break;
		}
		
		TKFreeBuffer(&sourceBuffer);
		
		vImage_Buffer destBuffer;
		TKInitBuffer(&destBuffer, size.height, size.width, 32);
		
		vImageOverwriteChannels_ARGBFFFF(&bBuffer, &destBuffer, &destBuffer,  0x1, kvImageNoFlags);
		vImageOverwriteChannels_ARGBFFFF(&gBuffer, &destBuffer, &destBuffer,  0x2, kvImageNoFlags);
		vImageOverwriteChannels_ARGBFFFF(&rBuffer, &destBuffer, &destBuffer,  0x4, kvImageNoFlags);
		vImageOverwriteChannels_ARGBFFFF(&aBuffer, &destBuffer, &destBuffer,  0x8, kvImageNoFlags);
		
		//NSData *dataRepresentation = [NSData dataWithBytesNoCopy:destBuffer.data length:size.width * size.height * sizeof(float) * 4 freeWhenDone:YES];
		
		NSData *dataRepresentation = [NSData dataWithBytes:destBuffer.data length:size.width * size.height * sizeof(float) * 4];
		TKFreeBuffer(&destBuffer);

		return dataRepresentation;
	} else if ((sourcePixelFormat == TKPixelFormatBGRA || sourcePixelFormat == TKPixelFormatABGR || sourcePixelFormat == TKPixelFormatXBGR || sourcePixelFormat == TKPixelFormatXRGB || sourcePixelFormat == TKPixelFormatRGBX || sourcePixelFormat == TKPixelFormatARGB || sourcePixelFormat == TKPixelFormatRGBA || sourcePixelFormat == TKPixelFormatRGB) && (destPixelFormat == TKPixelFormatARGB || destPixelFormat == TKPixelFormatRGBA)) {
		vImage_Buffer sourceBuffer;
		sourceBuffer.data = (void*)data.bytes;
		sourceBuffer.height = size.height;
		sourceBuffer.width = size.width;
		if (sourcePixelFormat == TKPixelFormatRGB) {
			sourceBuffer.rowBytes = size.width * 3;
		} else {
			sourceBuffer.rowBytes = size.width * 4;
		}
		NSMutableData *rData = [NSMutableData dataWithLength:size.width * size.height];
		NSMutableData *gData = [NSMutableData dataWithLength:size.width * size.height];
		NSMutableData *bData = [NSMutableData dataWithLength:size.width * size.height];
		NSMutableData *aData = [NSMutableData dataWithLength:size.width * size.height];
		vImage_Buffer rBuffer;
		rBuffer.height = size.height;
		rBuffer.width = size.width;
		rBuffer.rowBytes = size.width;
		vImage_Buffer gBuffer;
		vImage_Buffer bBuffer;
		vImage_Buffer aBuffer;
		
		gBuffer = bBuffer = aBuffer = rBuffer;

		rBuffer.data = rData.mutableBytes;
		gBuffer.data = gData.mutableBytes;
		bBuffer.data = bData.mutableBytes;
		aBuffer.data = aData.mutableBytes;
		switch (sourcePixelFormat) {
			case TKPixelFormatBGRA:
				vImageExtractChannel_ARGB8888(&sourceBuffer, &bBuffer, 0, kvImageNoFlags);
				vImageExtractChannel_ARGB8888(&sourceBuffer, &gBuffer, 1, kvImageNoFlags);
				vImageExtractChannel_ARGB8888(&sourceBuffer, &rBuffer, 2, kvImageNoFlags);
				vImageExtractChannel_ARGB8888(&sourceBuffer, &aBuffer, 3, kvImageNoFlags);
				break;
				
			case TKPixelFormatABGR:
			case TKPixelFormatXBGR:
				vImageExtractChannel_ARGB8888(&sourceBuffer, &aBuffer, 0, kvImageNoFlags);
				vImageExtractChannel_ARGB8888(&sourceBuffer, &bBuffer, 1, kvImageNoFlags);
				vImageExtractChannel_ARGB8888(&sourceBuffer, &gBuffer, 2, kvImageNoFlags);
				vImageExtractChannel_ARGB8888(&sourceBuffer, &rBuffer, 3, kvImageNoFlags);
				break;
				
			case TKPixelFormatRGBA:
			case TKPixelFormatRGBX:
				vImageExtractChannel_ARGB8888(&sourceBuffer, &aBuffer, 3, kvImageNoFlags);
				//fall-through
			case TKPixelFormatRGB:
				vImageExtractChannel_ARGB8888(&sourceBuffer, &rBuffer, 0, kvImageNoFlags);
				vImageExtractChannel_ARGB8888(&sourceBuffer, &gBuffer, 1, kvImageNoFlags);
				vImageExtractChannel_ARGB8888(&sourceBuffer, &bBuffer, 2, kvImageNoFlags);
				break;
				
			case TKPixelFormatARGB:
			case TKPixelFormatXRGB:
				vImageExtractChannel_ARGB8888(&sourceBuffer, &aBuffer, 0, kvImageNoFlags);
				vImageExtractChannel_ARGB8888(&sourceBuffer, &rBuffer, 1, kvImageNoFlags);
				vImageExtractChannel_ARGB8888(&sourceBuffer, &gBuffer, 2, kvImageNoFlags);
				vImageExtractChannel_ARGB8888(&sourceBuffer, &bBuffer, 3, kvImageNoFlags);
				break;
				
			default:
				break;
		}
		if (sourcePixelFormat == TKPixelFormatXBGR || sourcePixelFormat == TKPixelFormatXRGB || sourcePixelFormat == TKPixelFormatRGBX || sourcePixelFormat == TKPixelFormatRGB) {
			//because the alpha channel will likely contain garbage data.
			memset(aData.mutableBytes, 0xFF, aData.length);
		}
		
		NSMutableData *combinedData = [NSMutableData dataWithLength:size.width * 4 * size.height];
		vImage_Buffer combinedBuffer;
		combinedBuffer.data = combinedData.mutableBytes;
		combinedBuffer.height = size.height;
		combinedBuffer.width = size.width;
		combinedBuffer.rowBytes = size.width * 4;
		
		if (destPixelFormat == TKPixelFormatARGB) {
			vImageOverwriteChannels_ARGB8888(&bBuffer, &combinedBuffer, &combinedBuffer,  0x1, kvImageNoFlags);
			vImageOverwriteChannels_ARGB8888(&gBuffer, &combinedBuffer, &combinedBuffer,  0x2, kvImageNoFlags);
			vImageOverwriteChannels_ARGB8888(&rBuffer, &combinedBuffer, &combinedBuffer,  0x4, kvImageNoFlags);
			vImageOverwriteChannels_ARGB8888(&aBuffer, &combinedBuffer, &combinedBuffer,  0x8, kvImageNoFlags);
		} else  if (destPixelFormat == TKPixelFormatRGBA) {
			vImageOverwriteChannels_ARGB8888(&bBuffer, &combinedBuffer, &combinedBuffer,  0x2, kvImageNoFlags);
			vImageOverwriteChannels_ARGB8888(&gBuffer, &combinedBuffer, &combinedBuffer,  0x4, kvImageNoFlags);
			vImageOverwriteChannels_ARGB8888(&rBuffer, &combinedBuffer, &combinedBuffer,  0x8, kvImageNoFlags);
			vImageOverwriteChannels_ARGB8888(&aBuffer, &combinedBuffer, &combinedBuffer,  0x1, kvImageNoFlags);
		}
		
		return [combinedData copy];
	} else if (sourcePixelFormat == TKPixelFormatABGR32323232F && destPixelFormat == TKPixelFormatRGBA32323232F) {
		vImage_Buffer sourceBuffer;
		sourceBuffer.data = (void*)data.bytes;
		sourceBuffer.height = size.height;
		sourceBuffer.width = size.width;
		sourceBuffer.rowBytes = size.width * sizeof(float) * 4;
		NSMutableData *rData = [NSMutableData dataWithLength:size.width * size.height * sizeof(float)];
		NSMutableData *gData = [NSMutableData dataWithLength:size.width * size.height * sizeof(float)];
		NSMutableData *bData = [NSMutableData dataWithLength:size.width * size.height * sizeof(float)];
		NSMutableData *aData = [NSMutableData dataWithLength:size.width * size.height * sizeof(float)];
		vImage_Buffer rBuffer;
		rBuffer.height = size.height;
		rBuffer.width = size.width;
		rBuffer.rowBytes = size.width * sizeof(float);
		vImage_Buffer gBuffer;
		vImage_Buffer bBuffer;
		vImage_Buffer aBuffer;
		
		gBuffer = bBuffer = aBuffer = rBuffer;
		
		rBuffer.data = rData.mutableBytes;
		gBuffer.data = gData.mutableBytes;
		bBuffer.data = bData.mutableBytes;
		aBuffer.data = aData.mutableBytes;
		
		vImageExtractChannel_ARGBFFFF(&sourceBuffer, &aBuffer, 0, kvImageNoFlags);
		vImageExtractChannel_ARGBFFFF(&sourceBuffer, &bBuffer, 1, kvImageNoFlags);
		vImageExtractChannel_ARGBFFFF(&sourceBuffer, &gBuffer, 2, kvImageNoFlags);
		vImageExtractChannel_ARGBFFFF(&sourceBuffer, &rBuffer, 3, kvImageNoFlags);
		
		vImage_Buffer destBuffer;
		TKInitBuffer(&destBuffer, size.height, size.width, 32);
		
		vImageOverwriteChannels_ARGBFFFF(&bBuffer, &destBuffer, &destBuffer,  0x1, kvImageNoFlags);
		vImageOverwriteChannels_ARGBFFFF(&gBuffer, &destBuffer, &destBuffer,  0x2, kvImageNoFlags);
		vImageOverwriteChannels_ARGBFFFF(&rBuffer, &destBuffer, &destBuffer,  0x4, kvImageNoFlags);
		vImageOverwriteChannels_ARGBFFFF(&aBuffer, &destBuffer, &destBuffer,  0x8, kvImageNoFlags);
		
		NSData *dataRepresentation = [[NSData alloc] initWithBytes:destBuffer.data length:size.width * size.height * sizeof(float) * 4];
		TKFreeBuffer(&destBuffer);
		
		return dataRepresentation;
	}
	
	return nil;
}

+ (NSData *)representationUsingPixelFormat:(TKPixelFormat)destPixelFormat ofData:(NSData *)aData inPixelFormat:(TKPixelFormat)sourcePixelFormat {
	NSParameterAssert(aData != nil);
	if (sourcePixelFormat == destPixelFormat) return aData;
	
	if (sourcePixelFormat == TKPixelFormatRGBA16161616F && destPixelFormat == TKPixelFormatRGBA32323232F) {
		// TODO: implement
		
	}
	
	
	return nil;
}


//- (NSData *)representationUsingPixelFormat:(TKPixelFormat)aPixelFormat {
//#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//#endif
//	[self getBitmapInfoAndPixelFormatIfNecessary];
//	
//	if (aPixelFormat == pixelFormat) return [self data];
//	
//	CGImageRef imageRef = [self CGImage];
//	TKPixelFormatInfo *pixelFormatInfo = TKPixelFormatInfoFromPixelFormat(aPixelFormat);
//	if (pixelFormatInfo == NULL) return nil;
//	
//	size_t newLength = CGImageGetWidth(imageRef) * (pixelFormatInfo->bitsPerPixel / 8) * CGImageGetHeight(imageRef);
//	
//	
//	void *bitmapData = malloc(newLength);
//	if (bitmapData == NULL) {
//		NSLog(@"[%@ %@] malloc(%llu) failed!", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long long)newLength);
//		return nil;
//	}
//	
//	size_t imageWidth = CGImageGetWidth(imageRef);
//	size_t imageHeight = CGImageGetHeight(imageRef);
//	
//	size_t bitsPerComponent = pixelFormatInfo->bitsPerPixel/4;
//	size_t bytesPerRow = CGImageGetWidth(imageRef) * (pixelFormatInfo->bitsPerPixel / 8);
//	
//	CGColorSpaceRef colorspace = CGImageGetColorSpace(imageRef);
//	if (colorspace == NULL) {
//		NSLog(@"[%@ %@] CGImageGetColorSpace(imageRef) returned NULL", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
////		colorspace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
//		colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
//	} else {
//		CGColorSpaceRetain(colorspace);
//	}
//	
//	CGContextRef bitmapContext = CGBitmapContextCreate(bitmapData,
//													   imageWidth,
//													   imageHeight,
//													   bitsPerComponent,
//													   bytesPerRow,
//													   colorspace,
//													   pixelFormatInfo->bitmapInfo);
//	if (bitmapContext == NULL) {
//		NSLog(@"[%@ %@] CGBitmapContextCreate() returned NULL!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//		CGColorSpaceRelease(colorspace);
//		free(bitmapData);
//		return nil;
//	}
//	
//	CGContextDrawImage(bitmapContext, CGRectMake(0.0, 0.0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
//	NSData *repData = [NSData dataWithBytes:bitmapData length:newLength];
//	CGContextRelease(bitmapContext);
//	CGColorSpaceRelease(colorspace);
//	free(bitmapData);
//	return repData;
//}


//- (NSData *)representationForType:(NSString *)utiType {
//#if TK_DEBUG
//	NSLog(@"[%@ %@] utiType == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), utiType);
//#endif
//	NSMutableData *imageData = [NSMutableData data];
//	
//	CGImageDestinationRef imageDest = CGImageDestinationCreateWithData((CFMutableDataRef)imageData , (CFStringRef)utiType, 1, NULL);
//	if (imageDest == NULL) {
//		return nil;
//	}
//	
//	CGImageRef imageRef = [self CGImage];
//	CGImageDestinationAddImage(imageDest, imageRef, NULL);
//	CGImageDestinationFinalize(imageDest);
//	CFRelease(imageDest);
//	
//	return [[imageData copy] autorelease];
//}



- (void)setSliceIndex:(NSUInteger)aSliceIndex face:(TKFace)aFace frameIndex:(NSUInteger)aFrameIndex mipmapIndex:(NSUInteger)aMipmapIndex {
	self.sliceIndex = aSliceIndex;
	self.face = aFace;
	self.frameIndex = aFrameIndex;
	self.mipmapIndex = aMipmapIndex;
}


- (NSArray *)imageRepsByApplyingNormalMapFilterWithHeightEvaluationWeights:(CIVector *)heightEvaluationWeights
															 filterWeights:(CIVector *)aFilterWeights
																  wrapMode:(TKWrapMode)aWrapMode
														  normalizeMipmaps:(BOOL)normalizeMipmaps
														  normalMapLibrary:(TKNormalMapLibrary)normalMapLibrary {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	TKDDSImageRep *ddsImageRep = [TKDDSImageRep imageRepWithImageRep:self];
	return [ddsImageRep imageRepsByApplyingNormalMapFilterWithHeightEvaluationWeights:heightEvaluationWeights
																		filterWeights:aFilterWeights
																			 wrapMode:aWrapMode
																	 normalizeMipmaps:normalizeMipmaps
																	 normalMapLibrary:normalMapLibrary];
}

- (NSArray *)mipmapImageRepsUsingFilter:(TKMipmapGenerationType)filterType {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	TKDDSImageRep *ddsImageRep = [TKDDSImageRep imageRepWithImageRep:self];
	return [ddsImageRep mipmapImageRepsUsingFilter:filterType];
}

- (void)setProperty:(NSString *)property withValue:(id)value {
#if TK_DEBUG
//	NSLog(@"[%@ %@] property == %@, value == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), property, value);
#endif
	[super setProperty:property withValue:value];
}

- (NSComparisonResult)compare:(TKImageRep *)anImageRep {
#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSSize ourSize = self.size;
	NSSize theirSize = anImageRep.size;
	
	if (NSEqualSizes(ourSize, theirSize)) {
		NSUInteger theirSliceIndex = anImageRep.sliceIndex;
		TKFace theirFace = anImageRep.face;
		NSUInteger theirFrameIndex = anImageRep.frameIndex;
		NSUInteger theirMipmapIndex = anImageRep.mipmapIndex;
		
		NSUInteger ourIndexes[] = {sliceIndex, face, frameIndex, mipmapIndex};
		NSUInteger theirIndexes[] = {theirSliceIndex, theirFace, theirFrameIndex, theirMipmapIndex};
		
		NSIndexPath *ourIndexPath = [[NSIndexPath alloc] initWithIndexes:ourIndexes length:4];
		NSIndexPath *theirIndexPath = [[NSIndexPath alloc] initWithIndexes:theirIndexes length:4];
		
		NSComparisonResult comparisonResult = [ourIndexPath compare:theirIndexPath];
		
		return comparisonResult;
	}
	
	if ( (ourSize.width == theirSize.width && ourSize.height > theirSize.height) ||
		 (ourSize.width > theirSize.width && ourSize.height == theirSize.height) ||
		 (ourSize.width > theirSize.width && ourSize.height > theirSize.height) ||
		 (ourSize.width < theirSize.width && ourSize.height > theirSize.height && (ourSize.width * ourSize.height > theirSize.width * theirSize.height)) ||
		 (ourSize.width > theirSize.width && ourSize.height < theirSize.height && (ourSize.width * ourSize.height > theirSize.width * theirSize.height))) {
		
		return NSOrderedAscending;
	}
	return NSOrderedDescending;
}

+ (TKImageRep *)imageRepForFace:(TKFace)aFace ofImageRepsInArray:(NSArray *)imageReps {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	for (TKImageRep *imageRep in imageReps) {
		if (imageRep.face == aFace) return imageRep;
	}
	return nil;
}

- (BOOL)isEqual:(id)object {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
//	if ([object isKindOfClass:[self class]]) {
	if ([object isKindOfClass:[TKImageRep class]]) {
#if TK_DEBUG
		NSLog(@"[%@ %@] (TKImageRepLeopardIsEqualCompatability)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
		return [super isEqual:object];
	}
	return NO;
}

- (NSString *)description {
	NSMutableString *description = [NSMutableString string];
	[description appendFormat:@"%@ sliceIndex == %lu, ", super.description, (unsigned long)sliceIndex];
	[description appendFormat:@"face == %lu, ", (unsigned long)face];
	[description appendFormat:@"frameIndex == %lu, ", (unsigned long)frameIndex];
	[description appendFormat:@"mipmapIndex == %lu, ", (unsigned long)mipmapIndex];
	[description appendFormat:@"bitmapInfo == %lu, ", (unsigned long)self.bitmapInfo];
	[description appendFormat:@"alphaInfo == %lu, ", (unsigned long)self.alphaInfo];
	[description appendFormat:@"bitmapFormat == %lu, ", (unsigned long)self.bitmapFormat];
	[description appendFormat:@"imageProperties == %@", self.imageProperties];
	return [description copy];
}


@end


@implementation TKImageRep (TKLargestRepresentationAdditions)

+ (TKImageRep *)largestRepresentationInArray:(NSArray *)imageReps {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (imageReps == nil) return nil;
	
	NSUInteger repCount = imageReps.count;
	if (repCount == 1) return imageReps[0];
	
	NSDate *theStartDate = [NSDate date];
	NSArray *sortedImageReps = [imageReps sortedArrayUsingSelector:@selector(compare:)];
	NSTimeInterval elapsedTime = fabs(theStartDate.timeIntervalSinceNow);
#if TK_DEBUG
	NSLog(@"[%@ %@] elapsed time to sort %lu TKImageReps == %.7f sec / %.4f ms", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)repCount, elapsedTime, elapsedTime * 1000.0);
#endif
	
	return sortedImageReps[0];
}

@end
