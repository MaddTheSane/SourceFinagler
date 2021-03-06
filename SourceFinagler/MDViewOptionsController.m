//
//  MDViewOptionsController.m
//  Source Finagler
//
//  Created by Mark Douma on 1/29/2008.
//  Copyright © 2008 Mark Douma. All rights reserved.
//


#import "MDViewOptionsController.h"
#import "TKAppController.h"
#import "MDHLDocument.h"
#import "MDOutlineView.h"
#import "MDBrowser.h"
#import "TKAppKitAdditions.h"


#pragma mark controller
#define MD_DEBUG 0


NSString * const MDShouldShowViewOptionsKey						= @"MDShouldShowViewOptions";
NSString * const MDShouldShowViewOptionsDidChangeNotification	= @"MDShouldShowViewOptionsDidChange";


@interface MDViewOptionsController (MDPrivate)
- (void)switchToView:(NSDictionary *)anIdentifier;
@end


@implementation MDViewOptionsController

- (instancetype)init {
	if ((self = [super initWithWindowNibName:@"MDViewOptions"])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willSwitchView:) name:MDWillSwitchViewNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentViewModeDidChange:) name:MDDocumentViewModeDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedItemsDidChange:) name:MDSelectedItemsDidChangeNotification object:nil];

	} else {
		[NSBundle runFailedNibLoadAlert:@"MDViewOptions"];
	}
	return self;
}


- (void)dealloc {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)awakeFromNib {
	documentViewMode = [[[NSUserDefaults standardUserDefaults] objectForKey:MDDocumentViewModeKey] integerValue];
	
	[[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
	[[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
	[(NSPanel *)self.window setBecomesKeyOnlyIfNeeded:YES];
	
	[self switchToView:nil];
	
}

- (void)selectedItemsDidChange:(NSNotification *)notification {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	MDHLDocument *newDocument = notification.userInfo[MDSelectedItemsDocumentKey];
	if (newDocument == nil) {
		/* a document is being closed, so set stuff to an intermediary "--" */
		[self.window setTitle:NSLocalizedString(@"View Options", @"")];
		[noViewOptionsField setStringValue:NSLocalizedString(@"No document", @"")];
		contentBox.contentView = noViewOptionsView;
	}
}


- (void)willSwitchView:(NSNotification *)notification {
#if MD_DEBUG
	NSLog(@"[%@ %@] userInfo == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [notification userInfo]);
#endif

	NSDictionary *userInfo = notification.userInfo;
	[self switchToView:userInfo];
}


- (void)switchToView:(NSDictionary *)userInfo {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	if (userInfo) {
		NSString *viewIdentifier = userInfo[MDViewNameKey];
		if ([viewIdentifier isEqualToString:MDViewKey]) {
			
			NSString *documentName = userInfo[MDDocumentNameKey];
			if (documentName) {
				self.window.title = documentName;
			}
			
			documentViewMode = [userInfo[MDDocumentViewModeKey] integerValue];
			
			if (documentViewMode == 0) {
	
			} else if (documentViewMode == MDListViewMode) {
			
				contentBox.contentView = listViewOptionsView;
			
			} else if (documentViewMode == MDColumnViewMode) {
				
				contentBox.contentView = browserViewOptionsView;
				
			}
		}
		
	} else {
		NSInteger viewMode = [[[NSUserDefaults standardUserDefaults] objectForKey:MDDocumentViewModeKey] integerValue];
		if (viewMode == MDListViewMode) {
			contentBox.contentView = listViewOptionsView;
		} else if (viewMode == MDColumnViewMode) {
			contentBox.contentView = browserViewOptionsView;
	}
}
}


- (void)documentViewModeDidChange:(NSNotification *)notification {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif

	documentViewMode = [notification.userInfo[MDDocumentViewModeKey] integerValue];
	
	if (documentViewMode == 1) {
		contentBox.contentView = listViewOptionsView;
	} else if (documentViewMode == 2) {
		contentBox.contentView = browserViewOptionsView;
	}
}

- (IBAction)showWindow:(id)sender {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self.window orderFront:nil];
	[[NSUserDefaults standardUserDefaults] setObject:@(MDShouldShowViewOptions) forKey:MDShouldShowViewOptionsKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:MDShouldShowViewOptionsDidChangeNotification object:self userInfo:nil];
}


- (void)windowWillClose:(NSNotification *)notification {
	
	if (notification.object == self.window) {
#if MD_DEBUG
		NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
		MDShouldShowViewOptions = NO;
		[[NSUserDefaults standardUserDefaults] setObject:@(MDShouldShowViewOptions) forKey:MDShouldShowViewOptionsKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:MDShouldShowViewOptionsDidChangeNotification object:self userInfo:nil];
	}
}


- (IBAction)changeListViewIconSize:(id)sender {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[[NSUserDefaults standardUserDefaults] setObject:@([sender tag]) forKey:MDListViewIconSizeKey];
}

@end
