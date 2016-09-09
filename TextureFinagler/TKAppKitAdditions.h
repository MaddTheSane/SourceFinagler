//
//  TKAppKitAdditions.h
//  
//
//  Created by Mark Douma on 6/4/2010.
//  Copyright (c) 2010 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TextureKit/TKFoundationAdditions.h>

#ifdef __cplusplus
extern "C" {
#endif
	
extern NSString *NSStringFromDefaultsKeyPath(NSString *defaultsKey);

#ifdef __cplusplus
}
#endif

	
@interface NSAlert (TKAdditions)
+ (NSAlert *)alertWithMessageText:(NSString *)messageText informativeText:(NSString *)informativeText firstButton:(NSString *)firstButtonTitle secondButton:(NSString *)secondButtonTitle thirdButton:(NSString *)thirdButtonTitle;
@end

@interface NSBundle (TKAppKitAdditions)
+ (void)runFailedNibLoadAlert:(NSString *)nibName;
@end

@interface NSColor (TKAdditions)
@property (readonly, copy) NSString *hexValue;
@end

@interface NSFont (TKAdditions)
@property (readonly, copy) NSString *cssRepresentation;
@end

@interface NSMenu (TKAdditions)
- (BOOL)containsItem:(NSMenuItem *)aMenuItem;
- (void)setItemArray:(NSArray<NSMenuItem*> *)anArray;
@end

@interface NSOpenPanel (TKAdditions)
+ (NSOpenPanel *)openPanelWithTitle:(NSString *)title
							message:(NSString *)message
				  actionButtonTitle:(NSString *)actionButtonTitle
			allowsMultipleSelection:(BOOL)allowsMultipleSelection
			   canChooseDirectories:(BOOL)canChooseDirectories
						   delegate:(id <NSOpenSavePanelDelegate>)delegate;


@end

@interface NSPopUpButton (TKAdditions)
- (void)setItemArray:(NSArray<NSMenuItem*> *)value;
@end

@interface NSToolbarItem (TKAdditions)
+ (instancetype)toolbarItemWithItemIdentifier:(NSString *)anIdentifier tag:(NSInteger)aTag image:(NSImage *)anImage label:(NSString *)aLabel paletteLabel:(NSString *)aPaletteLabel target:(id)anObject action:(SEL)anAction;
@end

@interface NSUserDefaults (TKAdditions)
- (void)setFont:(NSFont *)aFont forKey:(NSString *)aKey;
- (NSFont *)fontForKey:(NSString *)aKey;
- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey;
- (NSColor *)colorForKey:(NSString *)aKey;
@end

@interface NSView (TKAdditions) 
- (void)setFrameFromString:(NSString *)aString;
@property (readonly, copy) NSString *stringWithSavedFrame;
@end

@interface NSWindow (TKAdditions)
@property (readonly) CGFloat toolbarHeight;
- (void)resizeToSize:(NSSize)newSize;
- (void)switchView:(NSView *)aView newTitle:(NSString *)aString;
- (void)switchView:(NSView *)aView;
@end

@interface NSWorkspace (TKAdditions)

- (BOOL)revealInFinder:(NSArray<NSString*> *)filePaths;

- (NSImage *)iconForApplicationForURL:(NSURL *)aURL;
- (NSString *)absolutePathForAppBundleWithIdentifier:(NSString *)aBundleIdentifier name:(NSString *)aNameWithDotApp creator:(NSString *)creator;
- (BOOL)launchApplicationAtPath:(NSString *)path arguments:(NSArray<NSString*> *)argv error:(NSError **)outError;

@end


