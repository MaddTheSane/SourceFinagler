//
//  MDPreviewViewController.m
//  Source Finagler
//
//  Created by Mark Douma on 9/30/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import "MDPreviewViewController.h"
#import <WebKit/WebKit.h>
#import <QTKit/QTKit.h>
#import "MDTransparentView.h"
#import "MDHLDocument.h"

#import <HLKit/HLKit.h>

//#define MD_DEBUG 1
#define MD_DEBUG 0


@implementation MDPreviewViewController

@synthesize sound;
@synthesize playingSound = isPlayingSound;
@synthesize quickLookPanel = isQuickLookPanel;

- (instancetype)init {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self initWithNibName:@"MDHLColumnPreviewView" bundle:nil];
}

- (void)awakeFromNib {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[super awakeFromNib];
	isQuickLookPanel = NO;
	textView.font = [NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]];
}

- (void)setRepresentedObject:(id)representedObject {
#if MD_DEBUG
	NSLog(@"[%@ %@] representedObject == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), representedObject);
#endif
	
	if (isPlayingSound) {
		[sound stop];
		[self setSound:nil];
	}
	
	// representedObject can be:
	//		nil
	//		an MDHLDocument
	//		an HKFile or HKFolder
	
	if (!isQuickLookPanel) {
		if (representedObject) {
			if ([representedObject isKindOfClass:[MDHLDocument class]]) {
				box.contentView = imageViewView;
				
			} else if ([representedObject isKindOfClass:[HKItem class]]) {
				if ([representedObject respondsToSelector:@selector(fileType)]) {
					HKFileType fileType = HKFileTypeNone;
					fileType = ((HKFile *)representedObject).fileType;
					switch (fileType) {
						case HKFileTypeHTML :
						case HKFileTypeText :
						case HKFileTypeOther :
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
							
						default:
							break;
					}
				}
			}
		} else {
			box.contentView = imageViewView;
		}
	}
	super.representedObject = representedObject;
}

- (void)sound:(NSSound *)aSound didFinishPlaying:(BOOL)didFinishPlaying {
	if (didFinishPlaying) {
		soundButton.image = [NSImage imageNamed:@"play"];
	}
}

- (IBAction)togglePlaySound:(id)sender {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (sound.playing) {
		soundButton.image = [NSImage imageNamed:@"play"];
		[sound stop];
	} else {
		soundButton.image = [NSImage imageNamed:@"pause"];
		[sound play];
	}
}

@end
