//
//  TKImageView.h
//  Texture Kit
//
//  Created by Mark Douma on 11/15/2010.
//  Copyright (c) 2010-2012 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>


@class TKImageView, TKImageRep;

NS_ENUM(NSInteger) {
	TKImageViewZoomOutTag			= -1,
	TKImageViewZoomActualSizeTag	= 0,
	TKImageViewZoomInTag			= 1
};


@protocol TKImageViewDelegate <NSObject>
- (void)imageViewDidBecomeFirstResponder:(TKImageView *)anImageView;
@end


@interface TKImageView : IKImageView {
	
	
	__weak id<TKImageViewDelegate>				delegate;		// non-retained
	
	
	CALayer										*imageKitLayer;
	
	CALayer										*animationImageLayer;
	
	NSArray<TKImageRep*>						*animationImageReps;
	BOOL										isAnimating;
	
	CGImageRef									image;
	
	TKImageRep									*previewImageRep;
	BOOL										previewing;
	BOOL										showsImageBackground;
}

@property (nonatomic, strong) CALayer *imageKitLayer;

@property (strong) CALayer *animationImageLayer;

@property (copy) NSArray<TKImageRep*> *animationImageReps;


- (void)startAnimating;
- (void)stopAnimating;
@property (readonly, getter=isAnimating) BOOL animating;


@property (weak) IBOutlet id <TKImageViewDelegate> delegate;
@property (strong) TKImageRep *previewImageRep;
@property (assign, getter=isPreviewing) BOOL previewing;
@property (assign) BOOL showsImageBackground;

- (IBAction)toggleShowImageBackground:(id)sender;

- (IBAction)zoom:(id)sender;

@end
