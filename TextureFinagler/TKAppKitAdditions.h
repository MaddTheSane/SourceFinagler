//
//  TKAppKitAdditions.h
//  
//
//  Created by Mark Douma on 6/4/2010.
//  Copyright (c) 2010 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TextureKit/TKFoundationAdditions.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif
	
extern NSString *NSStringFromDefaultsKeyPath(NSString *defaultsKey);

#ifdef __cplusplus
}
#endif

	
@interface NSAlert (TKAdditions)
+ (NSAlert *)alertWithMessageText:(NSString *)messageText informativeText:(NSString *)informativeText firstButton:(nullable NSString *)firstButtonTitle secondButton:(nullable NSString *)secondButtonTitle thirdButton:(nullable NSString *)thirdButtonTitle;
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
+ (NSOpenPanel *)openPanelWithTitle:(nullable NSString *)title
							message:(nullable NSString *)message
				  actionButtonTitle:(nullable NSString *)actionButtonTitle
			allowsMultipleSelection:(BOOL)allowsMultipleSelection
			   canChooseDirectories:(BOOL)canChooseDirectories
						   delegate:(nullable id <NSOpenSavePanelDelegate>)delegate;

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
- (nullable NSString *)absolutePathForAppBundleWithIdentifier:(nullable NSString *)aBundleIdentifier name:(nullable NSString *)aNameWithDotApp creator:(nullable NSString *)creator;
- (BOOL)launchApplicationAtPath:(NSString *)path arguments:(nullable NSArray<NSString*> *)argv error:(NSError *__nullable*__nullable)outError;

@end

NS_ASSUME_NONNULL_END
