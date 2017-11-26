//
//  MDCopyOperationSeparatorView.h
//  Source Finagler
//
//  Created by Mark Douma on 6/12/2011.
//  Copyright 2011 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MDCopyOperationView;

@interface MDCopyOperationSeparatorView : NSView

+ (instancetype)separatorView;
+ (instancetype)separatorViewPositionedAboveCopyOperationView:(MDCopyOperationView *)copyOperationView;

@property (class, readonly) CGFloat separatorViewHeight;

@end
