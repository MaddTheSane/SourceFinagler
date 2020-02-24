//
//  MDCopyOperationContentView.m
//  Source Finagler
//
//  Created by Mark Douma on 6/12/2011.
//  Copyright 2011 Mark Douma LLC. All rights reserved.
//

#import "MDCopyOperationContentView.h"
#import "MDCopyOperationView.h"
#import "MDCopyOperationSeparatorView.h"
#import "TKAppKitAdditions.h"


#define MD_DEBUG 0

@implementation MDCopyOperationContentView

- (instancetype)initWithFrame:(NSRect)frame {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
    if ((self = [super initWithFrame:frame])) {
		viewsAndTags = [[NSMutableDictionary alloc] init];
		
    }
    return self;
}

- (BOOL)isOpaque {
	return YES;
}

static inline NSArray *MDReversedArray(NSArray *array) {
	NSMutableArray *reversedArray = [NSMutableArray array];
	NSEnumerator *enumerator = [array reverseObjectEnumerator];
	for (id object in enumerator) {
		[reversedArray addObject:object];
	}
	return reversedArray;
}

- (void)addCopyOperationView:(MDCopyOperationView *)copyOperationView {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (copyOperationView == nil) return;
	
	@synchronized(self) {
		
#if MD_DEBUG
		NSLog(@"[%@ %@] subviews (BEFORE) == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), MDReversedArray([self subviews]));
		NSLog(@"[%@ %@] height   (BEFORE) == %.3f", NSStringFromClass([self class]), NSStringFromSelector(_cmd), NSHeight([self frame]));
#endif
		
		NSUInteger viewCount = viewsAndTags.count;
		
		if (viewCount) {
			
			NSWindow *window = self.window;
			
			if (window) {
				// only resize if we have more than one operation
				
				NSSize newWindowSize = window.frame.size;
				
				newWindowSize.height -= 22.0; // title bar height
				newWindowSize.height += ([[copyOperationView class] copyOperationViewSize].height + [MDCopyOperationSeparatorView separatorViewHeight]);
				
				[window resizeToSize:newWindowSize];
			}
			
			NSNumber *highestTag = [viewsAndTags.allKeys sortedArrayUsingSelector:@selector(compare:)].lastObject;
			MDCopyOperationView *highestView = viewsAndTags[highestTag];
			
			MDCopyOperationSeparatorView *separatorView = [MDCopyOperationSeparatorView separatorViewPositionedAboveCopyOperationView:highestView];
			[self addSubview:separatorView];
		}
		
		NSArray *allViews = viewsAndTags.allValues;
		
		CGFloat totalHeight = 0;
		
		for (MDCopyOperationView *view in allViews) {
			totalHeight += NSHeight(view.frame);
			totalHeight += NSHeight(view.separatorView.frame);
		}
		
		NSRect viewFrame = copyOperationView.frame;
		viewFrame.origin.y += totalHeight;
		copyOperationView.frame = viewFrame;
		
		[self addSubview:copyOperationView];
		
		viewsAndTags[@(copyOperationView.tag)] = copyOperationView;
		
		[self setNeedsDisplay:YES];
		
#if MD_DEBUG
		NSLog(@"[%@ %@] subviews (AFTER) == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), MDReversedArray([self subviews]));
		NSLog(@"[%@ %@] height   (AFTER) == %.3f", NSStringFromClass([self class]), NSStringFromSelector(_cmd), NSHeight([self frame]));
#endif
	}
}

- (void)removeCopyOperationView:(MDCopyOperationView *)copyOperationView {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (copyOperationView == nil) return;

	@synchronized(self) {
		
#if MD_DEBUG
		NSLog(@"[%@ %@] subviews (BEFORE) == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), MDReversedArray([self subviews]));
		NSLog(@"[%@ %@] height   (BEFORE) == %.3f", NSStringFromClass([self class]), NSStringFromSelector(_cmd), NSHeight([self frame]));
#endif
		
		NSUInteger viewCount = viewsAndTags.count;
		
		MDCopyOperationView *foundView = viewsAndTags[@(copyOperationView.tag)];
		
		if (foundView == nil) return;
		
		if (viewCount == 1 && foundView) {
			[foundView removeFromSuperview];
			[viewsAndTags removeObjectForKey:@(copyOperationView.tag)];
			
#if MD_DEBUG
			NSLog(@"[%@ %@] subviews (AFTER) == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), MDReversedArray([self subviews]));
			NSLog(@"[%@ %@] height   (AFTER) == %.3f", NSStringFromClass([self class]), NSStringFromSelector(_cmd), NSHeight([self frame]));
#endif
			return;
		}
		
		[copyOperationView.separatorView removeFromSuperview];
		[copyOperationView removeFromSuperview];
		
		NSInteger removingTag = copyOperationView.tag;
		
		NSArray *allViews = viewsAndTags.allValues;
		
		for (MDCopyOperationView *view in allViews) {
			NSInteger viewTag = view.tag;
			
			NSUInteger autoresizingMask = view.autoresizingMask;
			
			if (removingTag < viewTag) {
				
				autoresizingMask &= ~NSViewMaxYMargin;
				autoresizingMask |= NSViewMinYMargin;
				
			} else {
				
				[view switchColorType];
				
				autoresizingMask &= ~NSViewMinYMargin;
				autoresizingMask |= NSViewMaxYMargin;
				
			}
			
			view.autoresizingMask = autoresizingMask;
			view.separatorView.autoresizingMask = autoresizingMask;
			
		}
		
		NSWindow *window = self.window;

		if (window) {
			// only resize if we have more than one operation
			
			NSSize newWindowSize = window.frame.size;
			
			newWindowSize.height -= 22.0; // title bar height
			newWindowSize.height -= (NSHeight(copyOperationView.frame) + NSHeight(copyOperationView.separatorView.frame));
			
			[window resizeToSize:newWindowSize];
		}
		
		for (MDCopyOperationView *view in allViews) {
			NSInteger viewTag = view.tag;
			
			NSUInteger autoresizingMask = view.autoresizingMask;
			
			if (removingTag < viewTag) {
				autoresizingMask &= ~NSViewMinYMargin;
				autoresizingMask |= NSViewMaxYMargin;
				
			} else {
				autoresizingMask &= ~NSViewMaxYMargin;
				autoresizingMask |= NSViewMinYMargin;
				
			}
			
			view.autoresizingMask = autoresizingMask;
			view.separatorView.autoresizingMask = autoresizingMask;
		}
		
		[viewsAndTags removeObjectForKey:@(copyOperationView.tag)];
		
		[self setNeedsDisplay:YES];
		
#if MD_DEBUG
		NSLog(@"[%@ %@] subviews (AFTER) == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), MDReversedArray([self subviews]));
		NSLog(@"[%@ %@] height   (AFTER) == %.3f", NSStringFromClass([self class]), NSStringFromSelector(_cmd), NSHeight([self frame]));
#endif
	}
}

@end
