//
//  MDQuickLookPreviewViewController.m
//  ComplexBrowser
//
//  Created by Mark Douma on 6/27/2009.
//  Copyright 2009 Mark Douma. All rights reserved.
//

#import "MDQuickLookPreviewViewController.h"
#import "MDHLDocument.h"

#import <HLKit/HLKit.h>

#import "MDTransparentView.h"
#import <WebKit/WebKit.h>

//#define MD_DEBUG 1
#define MD_DEBUG 0


@implementation MDQuickLookPreviewViewController


//- (void)dealloc {
//#if MD_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//#endif
//	[super dealloc];
//}


- (void)awakeFromNib {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[super awakeFromNib];
	
	isQuickLookPanel = YES;
}



- (void)setRepresentedObject:(id)representedObject {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
//	// force our nib to load if it isn't already
//	[self view];

	// representedObject can be:
	//		nil
	//		an MDHLDocument
	//		an HKFile or HKFolder
	
	if (isPlayingSound) {
		[sound stop];
		[self setSound:nil];
	}
	if (representedObject) {
		if ([representedObject isKindOfClass:[MDHLDocument class]]) {
			box.contentView = imageViewView;

		} else if ([representedObject isKindOfClass:[HKItem class]]) {
			if ([representedObject respondsToSelector:@selector(fileType)]) {
				HKFileType fileType = HKFileTypeNone;
				fileType = ((HKFile *)representedObject).fileType;
				switch (fileType) {
					case HKFileTypeHTML :
						[webView.mainFrame loadHTMLString:[(HKFile *)representedObject stringValue] baseURL:nil];
						box.contentView = webViewView;
						break;
						
					case HKFileTypeText :
						textView.string = [(HKFile *)representedObject stringValue];
						box.contentView = textViewView;
						break;
						
					case HKFileTypeImage :
						box.contentView = imageViewView;
						break;
						
					case HKFileTypeSound :
						box.contentView = soundViewView;
						self.sound = [(HKFile *)representedObject sound];
						sound.delegate = self;
						break;
						
					case HKFileTypeMovie :
						box.contentView = movieViewView;
						break;
						
					case HKFileTypeOther :
						box.contentView = imageViewView;
						break;
						
					default:
						break;
				}
			}
		}
	} else {
		box.contentView = imageViewView;
	}
	super.representedObject = representedObject;
	
}


//- (void)cleanup {
//#if MD_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//#endif
//}

@end

