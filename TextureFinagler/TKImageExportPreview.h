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
	
	__unsafe_unretained TKImageExportController		*controller;	// non-retained
	
	TKImage						*image;
	
	TKImageExportPreset			*preset;
	
	TKImageRep					*imageRep;
	
	NSUInteger					imageFileSize;
	
	NSInteger					tag;		// 0 thru 3
}

- (instancetype)initWithController:(TKImageExportController *)aController image:(TKImage *)anImage preset:(TKImageExportPreset *)aPreset tag:(NSInteger)aTag NS_DESIGNATED_INITIALIZER;

@property (assign) TKImageExportController *controller;

@property (retain) TKImage *image;

@property (retain) TKImageRep *imageRep;

@property (retain) TKImageExportPreset *preset;

@property (assign) NSUInteger imageFileSize;

@property (assign) NSInteger tag;

@end


