//
//  TKImageChannel.h
//  Source Finagler
//
//  Created by Mark Douma on 10/24/2011.
//  Copyright 2011 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@class TKImageRep;

typedef NS_OPTIONS(NSUInteger, TKImageChannelMask) {
	TKImageChannelMaskRed		= 1 << 0,
	TKImageChannelMaskGreen		= 1 << 1,
	TKImageChannelMaskBlue		= 1 << 2,
	TKImageChannelMaskAlpha		= 1 << 3,
	TKImageChannelMaskRGBA		= TKImageChannelMaskRed | TKImageChannelMaskGreen | TKImageChannelMaskBlue | TKImageChannelMaskAlpha,

	
	TKImageChannelRedMask		NS_SWIFT_UNAVAILABLE("Use .Red instead") = TKImageChannelMaskRed,
	TKImageChannelGreenMask		NS_SWIFT_UNAVAILABLE("Use .Green instead") = TKImageChannelMaskGreen,
	TKImageChannelBlueMask		NS_SWIFT_UNAVAILABLE("Use .Blue instead") = TKImageChannelMaskBlue,
	TKImageChannelAlphaMask		NS_SWIFT_UNAVAILABLE("Use .Alpha instead") = TKImageChannelMaskAlpha,
	TKImageChannelRGBAMask		NS_SWIFT_UNAVAILABLE("Use .RGBA instead") = TKImageChannelMaskRGBA
};



@interface TKImageChannel : NSObject {
	NSString				*name;
	NSImage					*image;
	TKImageChannelMask		channelMask;
	CIFilter				*filter;
	BOOL					enabled;
}

+ (NSArray<TKImageChannel*> *)imageChannelsWithImageRep:(TKImageRep *)anImageRep;

+ (instancetype)imageChannelWithImageRep:(TKImageRep *)anImageRep channelMask:(TKImageChannelMask)aChannelMask;
- (instancetype)initWithImageRep:(TKImageRep *)anImageRep channelMask:(TKImageChannelMask)aChannelMask NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;


@property (copy) NSString *name;
@property (copy) NSImage *image;
@property (assign) TKImageChannelMask channelMask;
@property (assign, getter=isEnabled) BOOL enabled;
@property (retain) CIFilter *filter;


- (void)updateWithImageRep:(TKImageRep *)anImageRep;

@end



@interface CIFilter (TKImageChannelAdditions)

+ (CIFilter *)filterForChannelMask:(TKImageChannelMask)aChannelMask;

@end
