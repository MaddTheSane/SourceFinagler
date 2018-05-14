//
//  TKAppKitAdditions.m
//  
//
//  Created by Mark Douma on 6/4/2010.
//  Copyright (c) 2010 Mark Douma LLC. All rights reserved.
//

#import "TKAppKitAdditions.h"
#include <CoreServices/CoreServices.h>


#define TK_DEBUG 0


NSString *NSStringFromDefaultsKeyPath(NSString *defaultsKey) {
	return [NSString stringWithFormat:@"defaults.%@", defaultsKey];
}

@implementation NSAlert (TKAdditions)

+ (NSAlert *)alertWithMessageText:(NSString *)messageText informativeText:(NSString *)informativeText firstButton:(NSString *)firstButtonTitle secondButton:(NSString *)secondButtonTitle thirdButton:(NSString *)thirdButtonTitle {
	
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = messageText;
	alert.informativeText = informativeText;
	if (firstButtonTitle) {
		[alert addButtonWithTitle:firstButtonTitle];
	}
	if (secondButtonTitle) {
		[alert addButtonWithTitle:secondButtonTitle];
	}
	if (thirdButtonTitle) {
		[alert addButtonWithTitle:thirdButtonTitle];
	}
	return alert;
}

@end

@implementation NSBundle (TKAppKitAdditions)

+ (void)runFailedNibLoadAlert:(NSString *)nibName {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSBeep();
	NSString *appName = nil;
	appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	if (appName == nil) {
		appName = NSLocalizedString(@"This application", @"");
	}
	NSAlert *alert = [NSAlert new];
	alert.alertStyle = NSAlertStyleCritical;
	alert.messageText = [NSString stringWithFormat:NSLocalizedString(@"%@ encountered an error while trying to load the \"%@\" user interface file.", @""), appName, nibName];
	alert.informativeText = NSLocalizedString(@"Please reinstall the application.", @"");
	[alert addButtonWithTitle:NSLocalizedString(@"Quit", @"")];
	
	NSModalResponse choice = [alert runModal];
	if (choice == NSAlertFirstButtonReturn) [NSApp terminate:nil];	
}

@end


@implementation NSColor (TKAdditions)

- (NSString *)hexValue {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSString *hexValue = nil;
	NSColor *convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	if (convertedColor) {
		CGFloat red;
		CGFloat green;
		CGFloat blue;
		
		[convertedColor getRed:&red green:&green blue:&blue alpha:NULL];
		
		NSInteger redInt = red * 255.99999;
		NSInteger greenInt = green * 255.99999;
		NSInteger blueInt = blue * 255.99999;
		
		hexValue = [NSString stringWithFormat:@"#%02x%02x%02x", (unsigned int)redInt, (unsigned int)greenInt, (unsigned int)blueInt];
		
	}
	
	return hexValue;
}

@end


@implementation NSFont (TKAdditions)

- (NSString *)cssRepresentation {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	NSMutableString *cssRepresentation = [NSMutableString stringWithCapacity:120];
	
	NSString *familyName = self.familyName;
	
	if (familyName) {
		NSFontSymbolicTraits symbolicTraits = self.fontDescriptor.symbolicTraits;
		
		// NSLog(@"[NSFont cssRepresentation] symbolicTraits == %u", symbolicTraits);
		BOOL isSansSerif = (symbolicTraits & NSFontSansSerifClass);
		BOOL isBold = (symbolicTraits & NSFontBoldTrait);
		BOOL isItalic = (symbolicTraits & NSFontItalicTrait);
		
		if (isSansSerif) {
			[cssRepresentation appendFormat:@"\nfont-family: \"%@\", sans-serif;", familyName];
		} else {
			[cssRepresentation appendFormat:@"\nfont-family: \"%@\", serif;", familyName];
		}
		
		if (isBold) {
			[cssRepresentation appendString:@"\nfont-weight: bold;"];
		}
		
		if (isItalic) {
			[cssRepresentation appendString:@"\nfont-style: italic;"];
		}
		
	}
	return [cssRepresentation copy];
}

@end


@implementation NSMenu (TKAdditions)

- (BOOL)containsItem:(NSMenuItem *)aMenuItem {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return (!([self indexOfItem:aMenuItem] == -1));
}

- (void)setItemArray:(NSArray<NSMenuItem*> *)newArray {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	[self removeAllItems];
	NSUInteger newCount = newArray.count;
	NSUInteger i;
	
	for (i = 0; i < newCount; i++) {
		[self insertItem:newArray[i] atIndex:i];
		
		if ([[self itemAtIndex:i] respondsToSelector:@selector(isHidden)] &&
			[[self itemAtIndex:i] respondsToSelector:@selector(setHidden:)]) {
			
			if ([self itemAtIndex:i].hidden) {
				NSLog(@"[%@ %@] itemAtIndex %lu is hidden!", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)i);
				[[self itemAtIndex:i] setHidden:NO];
			}
		}
	}
}


//- (void)removeAllItems {
//#if TK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//#endif
//	NSArray *currentArray = [self itemArray];
//	NSUInteger currentCount = [currentArray count];
//	NSUInteger i;
//	
//	for (i = 0; i < currentCount; i++) {
//		[self removeItemAtIndex:0];
//	}
//}


@end


@implementation NSOpenPanel (TKAdditions)

+ (NSOpenPanel *)openPanelWithTitle:(NSString *)title
							message:(NSString *)message
				  actionButtonTitle:(NSString *)actionButtonTitle
			allowsMultipleSelection:(BOOL)allowsMultipleSelection
			   canChooseDirectories:(BOOL)canChooseDirectories
						   delegate:(id <NSOpenSavePanelDelegate>)delegate {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	if (title) openPanel.title = title;
	if (message) openPanel.message = message;
	if (actionButtonTitle) openPanel.prompt = actionButtonTitle;
	openPanel.allowsMultipleSelection = allowsMultipleSelection;
	openPanel.canChooseDirectories = canChooseDirectories;
	if (delegate) openPanel.delegate = delegate;
	return openPanel;
}

@end

@implementation NSPopUpButton (TKAdditions)

- (void)setItemArray:(NSArray<NSMenuItem*> *)value {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	BOOL isPulldown = self.pullsDown;
	
	NSMenu *theMenu = self.menu;
	
	[theMenu setItemArray:value];
	
	if (isPulldown && [[theMenu itemAtIndex:0] respondsToSelector:@selector(setHidden:)]) {
		[[theMenu itemAtIndex:0] setHidden:YES];
	}
}

@end


@implementation NSToolbarItem (TKAdditions)
+ (instancetype)toolbarItemWithItemIdentifier:(NSString *)anIdentifier tag:(NSInteger)aTag image:(NSImage *)anImage label:(NSString *)aLabel paletteLabel:(NSString *)aPaletteLabel target:(id)anObject action:(SEL)anAction {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSToolbarItem *toolbarItem = [[[self class] alloc] initWithItemIdentifier:anIdentifier];
	toolbarItem.tag = aTag;
	toolbarItem.image = anImage;
	toolbarItem.label = aLabel;
	toolbarItem.paletteLabel = aPaletteLabel;
	toolbarItem.target = anObject;
	toolbarItem.action = anAction;
	return toolbarItem;
}

@end

@implementation NSUserDefaults (TKAdditions)

- (void)setFont:(NSFont *)aFont forKey:(NSString *)aKey {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSData *data = nil;
	data = [NSKeyedArchiver archivedDataWithRootObject:aFont];
	if (data) {
		[self setObject:data forKey:aKey];
	}
}

- (NSFont *)fontForKey:(NSString *)aKey {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSData *data = nil;
	NSFont *font = nil;
	
	data = [self objectForKey:aKey];
	font = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if (![font isKindOfClass:[NSFont class]]) {
		font = nil;
	}
	return font;
}

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSData *data = nil;
	data = [NSKeyedArchiver archivedDataWithRootObject:aColor];
	if (data) {
		[self setObject:data forKey:aKey];
	}
}

- (NSColor *)colorForKey:(NSString *)aKey {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSData *data = nil;
	NSColor *color = nil;
	
	data = [self objectForKey:aKey];
	color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	if (![color isKindOfClass:[NSColor class]]) {
		color = nil;
	}
	return color;
}

@end

@implementation NSView (TKAdditions)

- (void)setFrameFromString:(NSString *)aString {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSRect boundsRect;
	NSArray *boundsArray = [aString componentsSeparatedByString:@" "];
	
	if (boundsArray.count != 4) {
		NSLog(@"[%@ %@] count of bounds array != 4, aborting...", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	} else {
		boundsRect.origin.x = 0.0;
		boundsRect.origin.y = 0.0;
		boundsRect.size.width = [boundsArray[2] floatValue];
		boundsRect.size.height = [boundsArray[3] floatValue];
		
		self.frame = boundsRect;
	}
}

- (NSString *)stringWithSavedFrame {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSRect frameRect = self.frame;
	
	NSString *dimensionString = [NSString stringWithFormat:@"%ld %ld %ld %ld", (long)frameRect.origin.x, (long)frameRect.origin.y, (long)frameRect.size.width, (long)frameRect.size.height];
	
	return dimensionString;
}

@end


static NSView *blankView() {
	static NSView *view = nil;
	if (!view) {
		view = [[NSView alloc] init];
	}
	return view;
} 

@implementation NSWindow (TKAdditions)

- (CGFloat)toolbarHeight {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSToolbar *toolbar = self.toolbar;
	CGFloat toolbarHeight = 0.0;
	NSRect windowFrame;
	
	if (toolbar && toolbar.visible) {
		windowFrame = [[self class] contentRectForFrameRect:self.frame styleMask:self.styleMask];
		toolbarHeight = NSHeight(windowFrame) - NSHeight(self.contentView.frame);
	}
	return toolbarHeight;
}

- (void)resizeToSize:(NSSize)newSize {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSRect aFrame;
	
	CGFloat newHeight = newSize.height + self.toolbarHeight;
	CGFloat newWidth = newSize.width;
	
	aFrame = [[self class] contentRectForFrameRect:self.frame styleMask:self.styleMask];
	
	aFrame.origin.y += aFrame.size.height;
	aFrame.origin.y -= newHeight;
	aFrame.size.height = newHeight;
	aFrame.size.width = newWidth;
	
	aFrame = [[self class] frameRectForContentRect:aFrame styleMask:self.styleMask];
	
	[self setFrame:aFrame display:YES animate:YES];
}

- (void)switchView:(NSView *)aView newTitle:(NSString *)aString {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (self.contentView != aView) {
		self.contentView = blankView();
		[self setTitle:NSLocalizedString(aString, @"")];
		[self resizeToSize:aView.frame.size];
		self.contentView = aView;
		//[self setShowsResizeIndicator:NO];
	}
}

- (void)switchView:(NSView *)aView {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (self.contentView != aView) {
		self.contentView = blankView();
		[self resizeToSize:aView.frame.size];
		self.contentView = aView;
		//[self setShowsResizeIndicator:NO];
	}
}

@end

@implementation NSWorkspace (TKAdditions)

// TODO: For 10.5+, rewrite to use Scripting Bridge rather than NSAppleScript
- (BOOL)revealInFinder:(NSArray *)filePaths {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSMutableArray *URLs = [NSMutableArray array];
	for (NSString *path in filePaths) {
		NSURL *URL = [NSURL fileURLWithPath:path];
		if (URL)
			[URLs addObject:URL];
	}
	[self activateFileViewerSelectingURLs:URLs];
	return YES;
}

- (NSImage *)iconForApplicationForURL:(NSURL *)aURL {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSImage *image = nil;
	if (aURL) {
		NSURL *appURL = CFBridgingRelease(LSCopyDefaultApplicationURLForURL((__bridge CFURLRef)aURL, kLSRolesAll, NULL));
		if (appURL) {
			image = [self iconForFile:[appURL path]];
		}
	}
	return image;
}

- (NSString *)absolutePathForAppBundleWithIdentifier:(NSString *)aBundleIdentifier name:(NSString *)aNameWithDotApp creator:(NSString *)creator {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSString *absolutePath = nil;
	if (aBundleIdentifier && !aNameWithDotApp && !creator) {
		NSArray<NSURL*> *appURLs = CFBridgingRelease(LSCopyApplicationURLsForBundleIdentifier((__bridge CFStringRef)aBundleIdentifier, NULL));
		if (appURLs && appURLs.count > 0) {
			return appURLs.firstObject.path;
		}
	}
	if (aBundleIdentifier || aNameWithDotApp || creator) {
		FSRef fileRef;
		OSType creatorCode = kLSUnknownCreator;
		if (creator) {
			OSType creatorType = NSHFSTypeCodeFromFileType(creator);
			if (creatorType != 0) {
				creatorCode = creatorType;
			}
		}
		
		OSStatus status = noErr;
		status = LSFindApplicationForInfo(creatorCode, (aBundleIdentifier ? (__bridge CFStringRef)aBundleIdentifier : NULL), (aNameWithDotApp ? (__bridge CFStringRef)aNameWithDotApp : NULL), &fileRef, NULL);
		
		if (status == noErr) {
			absolutePath = [NSString stringWithFSRef:&fileRef];
		}
	}
	return absolutePath;
}


- (BOOL)launchApplicationAtPath:(NSString *)path arguments:(NSArray<NSString*> *)argv error:(NSError **)outError {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	BOOL success = YES;
	if (outError) *outError = nil;
	
	if (path) {
		//NSWorkspace launchApplicationAtURL:options:configuration:error
		success = [self launchApplicationAtURL:[NSURL fileURLWithPath:path] options:NSWorkspaceLaunchDefault configuration:@{NSWorkspaceLaunchConfigurationArguments: argv ?: @[]} error:outError] != nil;
	}
	return success;
}

@end
