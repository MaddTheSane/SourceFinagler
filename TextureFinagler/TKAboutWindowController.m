//
//  TKAboutWindowController.m
//  Source Finagler
//
//  Created by Mark Douma on 6/28/2005.
//  Copyright © 2005 Mark Douma. All rights reserved.
//


#import "TKAboutWindowController.h"
#import "TKAppKitAdditions.h"


#define TK_DEBUG 0


@implementation TKAboutWindowController

- (instancetype)init {
	if ((self = [super initWithWindowNibName:@"TKAboutWindow"])) {
		
	} else {
		[NSBundle runFailedNibLoadAlert:@"TKAboutWindow"];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	nameField.stringValue = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
	versionField.stringValue = [NSString stringWithFormat:@"%@ %@ (%@)",
								  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"],
								  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
								  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	
	copyrightField.stringValue = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"];
}

- (IBAction)showWindow:(id)sender {
	if (!self.window.visible) {
		[self.window center];
	}
	[self.window makeKeyAndOrderFront:nil];
}

- (IBAction)showAcknowledgements:(id)sender {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSString *rtfPath = [[NSBundle mainBundle] pathForResource:@"Acknowledgments" ofType:@"rtf"];
	if (rtfPath) {
		[[NSWorkspace sharedWorkspace] openFile:rtfPath];
	}
}

@end
