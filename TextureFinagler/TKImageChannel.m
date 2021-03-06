//
//  TKImageChannel.m
//  Source Finagler
//
//  Created by Mark Douma on 10/24/2011.
//  Copyright 2011 Mark Douma LLC. All rights reserved.
//

#import "TKImageChannel.h"
#import <TextureKit/TextureKit.h>


#define TK_DEBUG 1

#define TK_CHANNEL_IMAGE_DIMENSION 32.0

@interface TKImageChannel ()
- (NSImage *)imageWithImageRep:(TKImageRep *)anImageRep;
@end


@implementation TKImageChannel
@synthesize name;
@synthesize image;
@synthesize channelMask;
@synthesize enabled;
@synthesize filter;

+ (NSArray *)imageChannelsWithImageRep:(TKImageRep *)anImageRep {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
//	NSParameterAssert(anImageRep != nil);
	NSMutableArray *imageChannels = [NSMutableArray array];
	
	BOOL irHasAlpha = anImageRep.alpha;
	
	TKImageChannel *redChannel = [[self class] imageChannelWithImageRep:anImageRep channelMask:TKImageChannelMaskRed];
	if (redChannel) [imageChannels addObject:redChannel];
	TKImageChannel *greenChannel = [[self class] imageChannelWithImageRep:anImageRep channelMask:TKImageChannelMaskGreen];
	if (greenChannel) [imageChannels addObject:greenChannel];
	TKImageChannel *blueChannel = [[self class] imageChannelWithImageRep:anImageRep channelMask:TKImageChannelMaskBlue];
	if (blueChannel) [imageChannels addObject:blueChannel];
	
	if (irHasAlpha) {
		TKImageChannel *alphaChannel = [[self class] imageChannelWithImageRep:anImageRep channelMask:TKImageChannelMaskAlpha];
		if (alphaChannel) [imageChannels addObject:alphaChannel];
	}
	return [imageChannels copy];
}

+ (instancetype)imageChannelWithImageRep:(TKImageRep *)anImageRep channelMask:(TKImageChannelMask)aChannelMask {
	return [[[self class] alloc] initWithImageRep:anImageRep channelMask:aChannelMask];
}

- (instancetype)initWithImageRep:(TKImageRep *)anImageRep channelMask:(TKImageChannelMask)aChannelMask {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super init])) {
		channelMask = aChannelMask;
		
		switch (channelMask) {
			case TKImageChannelMaskRed:
				name = NSLocalizedString(@"Red", @"");
				break;
			case TKImageChannelMaskGreen:
				name = NSLocalizedString(@"Green", @"");
				break;
			case TKImageChannelMaskBlue:
				name = NSLocalizedString(@"Blue", @"");
				break;
			case TKImageChannelMaskAlpha:
				name = NSLocalizedString(@"Alpha", @"");
				break;
			default:
				break;
		}
		enabled = YES;
		self.filter = [CIFilter filterForChannelMask:channelMask];
		
		self.image = [self imageWithImageRep:anImageRep];
	}
	return self;
}

- (void)updateWithImageRep:(TKImageRep *)anImageRep {
	self.image = [self imageWithImageRep:anImageRep];
}

- (NSImage *)imageWithImageRep:(TKImageRep *)anImageRep {
	CIImage *coreImage = [[CIImage alloc] initWithCGImage:anImageRep.CGImage];
	[filter setValue:coreImage forKey:@"inputImage"];
	
	CIImage *outputImage = [filter valueForKey:@"outputImage"];
	
	NSCIImageRep *ciImageRep = [[NSCIImageRep alloc] initWithCIImage:outputImage];
	
	NSImage *anImage = [[NSImage alloc] initWithSize:NSMakeSize(TK_CHANNEL_IMAGE_DIMENSION, TK_CHANNEL_IMAGE_DIMENSION)];
	
	[anImage addRepresentation:ciImageRep];
	
	return anImage;
}

@end

@implementation CIFilter (TKImageChannelAdditions)

+ (CIFilter *)filterForChannelMask:(TKImageChannelMask)aChannelMask {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	CIFilter *imageFilter = [CIFilter filterWithName:@"CIColorMatrix"];
	[imageFilter setDefaults];
	
	switch (aChannelMask) {
		case TKImageChannelMaskRed: {
			[imageFilter setValuesForKeysWithDictionary:@{@"inputRVector": [CIVector vectorWithString:@"[1.0 0.0 0.0 0.0]"],
														 @"inputGVector": [CIVector vectorWithString:@"[1.0 0.0 0.0 0.0]"],
														 @"inputBVector": [CIVector vectorWithString:@"[1.0 0.0 0.0 0.0]"],
														 @"inputAVector": [CIVector vectorWithString:@"[0.0 0.0 0.0 1.0]"]}];
						
			break;
		}
			
		case TKImageChannelMaskGreen: {
			[imageFilter setValuesForKeysWithDictionary:@{@"inputRVector": [CIVector vectorWithString:@"[0.0 1.0 0.0 0.0]"],
														 @"inputGVector": [CIVector vectorWithString:@"[0.0 1.0 0.0 0.0]"],
														 @"inputBVector": [CIVector vectorWithString:@"[0.0 1.0 0.0 0.0]"],
														 @"inputAVector": [CIVector vectorWithString:@"[0.0 0.0 0.0 1.0]"]}];
			break;
		}
			
		case TKImageChannelMaskBlue: {
			[imageFilter setValuesForKeysWithDictionary:@{@"inputRVector": [CIVector vectorWithString:@"[0.0 0.0 1.0 0.0]"],
														 @"inputGVector": [CIVector vectorWithString:@"[0.0 0.0 1.0 0.0]"],
														 @"inputBVector": [CIVector vectorWithString:@"[0.0 0.0 1.0 0.0]"],
														 @"inputAVector": [CIVector vectorWithString:@"[0.0 0.0 0.0 1.0]"]}];
			break;
		}
			
		case TKImageChannelMaskAlpha : {
			[imageFilter setValuesForKeysWithDictionary:@{@"inputRVector": [CIVector vectorWithString:@"[0.0 0.0 0.0 1.0]"],
														 @"inputGVector": [CIVector vectorWithString:@"[0.0 0.0 0.0 1.0]"],
														 @"inputBVector": [CIVector vectorWithString:@"[0.0 0.0 0.0 1.0]"],
														 @"inputAVector": [CIVector vectorWithString:@"[0.0 0.0 0.0 1.0]"]}];
			
			break;
		}
			
		case TKImageChannelMaskRGBA: {
			[imageFilter setValuesForKeysWithDictionary:@{@"inputRVector": [CIVector vectorWithString:@"[1.0 0.0 0.0 0.0]"],
														 @"inputGVector": [CIVector vectorWithString:@"[0.0 1.0 0.0 0.0]"],
														 @"inputBVector": [CIVector vectorWithString:@"[0.0 0.0 1.0 0.0]"],
														 @"inputAVector": [CIVector vectorWithString:@"[0.0 0.0 0.0 1.0]"]}];
			
			break;
		}
		default:
			break;
	}
	return imageFilter;
}

@end
