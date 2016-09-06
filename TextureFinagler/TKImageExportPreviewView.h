//
//  TKImageExportPreviewView.h
//  Source Finagler
//
//  Created by Mark Douma on 7/17/2011.
//  Copyright 2011 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TKImageExportPreviewView, TKImageExportPreviewViewController;


@protocol TKImageExportPreviewViewDelegate <NSObject>
- (void)didSelectImageExportPreviewView:(TKImageExportPreviewView *)anImageExportPreviewView;
@end


@interface TKImageExportPreviewView : NSView {
	BOOL isHighlighted;
}

@property (weak) IBOutlet id <TKImageExportPreviewViewDelegate> delegate;
@property (weak) IBOutlet TKImageExportPreviewViewController *viewController;
@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;


@end


