//
//  TKImageExportPreview.h
//  Texture Kit
//
//  Created by Mark Douma on 12/14/2010.
//  Copyright (c) 2010-2012 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TKImage, TKImageRep, TKImageExportPreset, TKImageExportController;

@interface TKImageExportPreview : NSObject {
	
	__weak TKImageExportController		*controller;	// non-retained
	
	TKImage						*image;
	
	TKImageExportPreset			*preset;
	
	TKImageRep					*imageRep;
	
	NSUInteger					imageFileSize;
	
	NSInteger					tag;		// 0 thru 3
}

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithController:(TKImageExportController *)aController image:(TKImage *)anImage preset:(TKImageExportPreset *)aPreset tag:(NSInteger)aTag NS_DESIGNATED_INITIALIZER;

@property (weak) TKImageExportController *controller;
@property (strong) TKImage *image;
@property (strong) TKImageRep *imageRep;
@property (strong) TKImageExportPreset *preset;
@property (assign) NSUInteger imageFileSize;
@property (assign) NSInteger tag;

@end
