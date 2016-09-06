//
//  MDPreviewViewController.h
//  Source Finagler
//
//  Created by Mark Douma on 9/30/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;
@class QTMovieView;
@class MDTransparentView;


@interface MDPreviewViewController : NSViewController <NSSoundDelegate> {
	IBOutlet NSBox				*box;
	
	IBOutlet NSView				*textViewView;
	IBOutlet NSTextView			*textView;
	
	IBOutlet NSView				*webViewView;
	IBOutlet WebView			*webView;

	IBOutlet NSView				*imageViewView;
	
	IBOutlet NSView				*movieViewView;
	
	IBOutlet MDTransparentView	*soundViewView;
	IBOutlet NSButton			*soundButton;
	
	BOOL						isPlayingSound;
	NSSound						*sound;
	
	BOOL						isQuickLookPanel;
}

@property (strong) NSSound *sound;
@property (assign, getter=isPlayingSound) BOOL playingSound;
@property (assign, getter=isQuickLookPanel) BOOL quickLookPanel;

- (IBAction)togglePlaySound:(id)sender;

@end
