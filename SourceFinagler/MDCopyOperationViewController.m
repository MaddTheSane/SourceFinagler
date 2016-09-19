//
//  MDCopyOperationViewController.m
//  Source Finagler
//
//  Created by Mark Douma on 11/2/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import "MDCopyOperationViewController.h"
#import "MDCopyOperation.h"
#import "TKAppKitAdditions.h"


#define MD_DEBUG 0

@implementation MDCopyOperationViewController
@synthesize tag;

+ (instancetype)viewControllerWithViewColorType:(MDCopyOperationViewBackgroundColorType)aColorType tag:(NSInteger)aTag {
	return [[[self class] alloc] initWithViewColorType:aColorType tag:aTag];
}

- (instancetype)init {
	return [self initWithViewColorType:MDWhiteBackgroundColorType tag:-1];
}

- (instancetype)initWithViewColorType:(MDCopyOperationViewBackgroundColorType)aColorType tag:(NSInteger)aTag {
	if ((self = [super initWithNibName:@"MDCopyOperationView" bundle:nil])) {
		colorType = aColorType;
		tag = aTag;
	} else {
		[NSBundle runFailedNibLoadAlert:@"MDCopyOperationView"];
	}
	return self;
}

static inline NSString *NSStringFromAutoresizingMask(NSAutoresizingMaskOptions mask) {
	NSMutableString *description = [NSMutableString string];
	if (mask == NSViewNotSizable) {
		[description appendString:@"NSViewNotSizable"];
		return description;
	}
	
	if (mask & NSViewMinXMargin) [description appendString:@"NSViewMinXMargin | "];
	if (mask & NSViewWidthSizable) [description appendString:@"NSViewWidthSizable | "];
	if (mask & NSViewMaxXMargin) [description appendString:@"NSViewMaxXMargin | "];
	if (mask & NSViewMinYMargin) [description appendString:@"NSViewMinYMargin | "];
	if (mask & NSViewHeightSizable) [description appendString:@"NSViewHeightSizable | "];
	if (mask & NSViewMaxYMargin) [description appendString:@"NSViewMaxYMargin"];
	return description;
}

- (void)awakeFromNib {
#if MD_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[progressIndicator setUsesThreadedAnimation:YES];
	[progressIndicator startAnimation:nil];
	
	((MDCopyOperationView *)self.view).colorType = colorType;
	((MDCopyOperationView *)self.view).tag = tag;
	
//	NSLog(@"[%@ %@] autoresizingMask == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), NSStringFromAutoresizingMask([[self view] autoresizingMask]));
	
}

- (void)mouseDidEnterRolloverButton:(MDRolloverButton *)button {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self.representedObject setRolledOver:YES];
}

- (void)mouseDidExitRolloverButton:(MDRolloverButton *)button {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self.representedObject setRolledOver:NO];
}

- (IBAction)stop:(id)sender {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self.representedObject setCancelled:YES];
}

@end
