//
//  TKImageExportPreviewViewController.h
//  Texture Kit
//
//  Created by Mark Douma on 12/13/2010.
//  Copyright (c) 2010-2012 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class TKImageView, TKImageExportPreset, TKImageExportController;


@interface TKImageExportPreviewViewController : NSViewController {
	TKImageView			*imageView;
	IBOutlet NSProgressIndicator	*progressIndicator;
	
	// representedObject is a TKImageExportPreview
}

+ (instancetype)previewViewControllerWithExportController:(TKImageExportController *)controller preset:(TKImageExportPreset *)preset tag:(NSInteger)tag;
- (instancetype)initWithExportController:(TKImageExportController *)controller preset:(TKImageExportPreset *)preset tag:(NSInteger)tag NS_DESIGNATED_INITIALIZER;


@property (assign) IBOutlet TKImageView *imageView;

@end


