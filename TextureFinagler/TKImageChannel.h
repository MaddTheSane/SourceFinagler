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
@property (strong) CIFilter *filter;

- (void)updateWithImageRep:(TKImageRep *)anImageRep;

@end



@interface CIFilter (TKImageChannelAdditions)

+ (CIFilter *)filterForChannelMask:(TKImageChannelMask)aChannelMask;

@end

static const TKImageChannelMask TKImageChannelRedMask		NS_DEPRECATED_WITH_REPLACEMENT_MAC("TKImageChannelMaskRed", 10.5, 10.11) = TKImageChannelMaskRed;
static const TKImageChannelMask TKImageChannelGreenMask		NS_DEPRECATED_WITH_REPLACEMENT_MAC("TKImageChannelMaskGreen", 10.5, 10.11) = TKImageChannelMaskGreen;
static const TKImageChannelMask TKImageChannelBlueMask		NS_DEPRECATED_WITH_REPLACEMENT_MAC("TKImageChannelMaskBlue", 10.5, 10.11) = TKImageChannelMaskBlue;
static const TKImageChannelMask TKImageChannelAlphaMask		NS_DEPRECATED_WITH_REPLACEMENT_MAC("TKImageChannelMaskAlpha", 10.5, 10.11) = TKImageChannelMaskAlpha;
static const TKImageChannelMask TKImageChannelRGBAMask		NS_DEPRECATED_WITH_REPLACEMENT_MAC("TKImageChannelMaskRGBA", 10.5, 10.11) = TKImageChannelMaskRGBA;
