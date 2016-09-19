//
//  MDCopyOperationView.h
//  Copy Progress Window
//
//  Created by Mark Douma on 4/4/2006.
//  Copyright (c) 2006 Mark Douma. All rights reserved.
//


#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, MDCopyOperationViewBackgroundColorType) {
	MDWhiteBackgroundColorType			NS_SWIFT_NAME(MDCopyOperationViewBackgroundColorType.white) = 0,
	MDAlternateBackgroundColorType		NS_SWIFT_NAME(MDCopyOperationViewBackgroundColorType.alternate) = 1
};

@class MDCopyOperationSeparatorView;

@interface MDCopyOperationView : NSView {
	MDCopyOperationSeparatorView				*separatorView;
	
	MDCopyOperationViewBackgroundColorType		colorType;
	NSLock										*lock;
	
	NSInteger									tag;
	
	
	NSColor										*whiteColor;
	NSColor										*alternateColor;
}

@property (strong) MDCopyOperationSeparatorView *separatorView;

@property (assign) MDCopyOperationViewBackgroundColorType colorType;
@property (assign) NSInteger tag;


- (void)switchColorType;

+ (NSSize)copyOperationViewSize;

@end
