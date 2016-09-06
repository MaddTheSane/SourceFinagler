//
//  MDQuickLookButton.m
//  Source Finagler
//
//  Created by Mark Douma on 2/24/2009.
//  Copyright 2009 Mark Douma. All rights reserved.
//

#import "MDQuickLookControlButton.h"

@interface MDQuickLookControlButton (Private)
- (void)finishSetup;

- (void)_showToolTipWithText:(NSString *)aString;
- (void)_closeToolTip;
- (void)_updateToolTip;
- (void)mouseEntered:(id)sender;
- (void)mouseExited:(id)sender;
- (void)viewWillMoveToWindow:(id)fp8;
- (void)viewDidMoveToWindow;
- (void)viewDidHide;
- (void)viewDidUnhide;
- (void)setTitle:(NSString *)aTitle;

@end

@implementation MDQuickLookControlButton

- (instancetype)initWithFrame:(NSRect)frame {
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	if ((self = [super initWithFrame:frame])) {
		[self finishSetup];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	if ((self = [super initWithCoder:coder])) {
		[self finishSetup];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	[super encodeWithCoder:coder];
}

- (void)finishSetup {
	//TODO: implement?
}

- (BOOL)acceptsFirstResponder {
	BOOL accepts = super.acceptsFirstResponder;
	NSLog(@"[%@ %@] super's acceptsFirstResponder == %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), accepts);
	
	return NO;
}

- (BOOL)becomeFirstResponder {
	return NO;
}


- (void)_showToolTipWithText:(NSString *)aString {
	//TODO: implement?
}


- (void)_closeToolTip {
	//TODO: implement?
}


- (void)_updateToolTip {
	//TODO: implement?
}


- (void)mouseEntered:(id)sender {
	//TODO: implement?
}


- (void)mouseExited:(id)sender {
	//TODO: implement?
	
}


- (void)viewWillMoveToWindow:(id)fp8 {
	//TODO: implement?
	
}


- (void)viewDidMoveToWindow {
	//TODO: implement?
	
}



- (void)viewDidHide {
	//TODO: implement?
	
}


- (void)viewDidUnhide {
	//TODO: implement?
	
}


- (void)setTitle:(NSString *)aTitle {
	//TODO: implement?
}




//- (void)drawRect:(NSRect)rect {
//    // Drawing code here.
//}

@end
