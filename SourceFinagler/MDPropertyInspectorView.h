//
//  MDPropertyInspectorView.h
//  MDPropertyInspectorView
//
//  Created by Mark Douma on 8/14/2007.
//  Copyright © 2008 Mark Douma . All rights reserved.
//  


#import <Cocoa/Cocoa.h>


@protocol MDInspectorViewDelegate <NSObject>
@optional

/*  Notifications  */
- (void)inspectorViewWillShow:(NSNotification *)notification;
- (void)inspectorViewDidShow:(NSNotification *)notification;

- (void)inspectorViewWillHide:(NSNotification *)notification;
- (void)inspectorViewDidHide:(NSNotification *)notification;

@end


@class TKMaterialPropertyViewController;


@interface MDPropertyInspectorView : NSView <NSCoding> {
	
	NSButton								*__weak titleButton;
	NSButton								*__weak disclosureButton;
	
	__weak id <MDInspectorViewDelegate> delegate;
	
	TKMaterialPropertyViewController				*viewController;
	
	
	NSString										*autosaveName;
	
	NSArray											*hiddenSubviews;
	
    NSView											*nonretainedOriginalNextKeyView;
    NSView											*nonretainedLastChildKeyView;
	
	CGFloat											originalHeight;
	CGFloat											hiddenHeight;
	
	NSSize											sizeBeforeHidden;
	
	BOOL											isInitiallyShown;
	
	BOOL											isShown;
	
	BOOL											havePendingWindowHeightChange;
}

- (IBAction)toggleShown:(id)sender;

@property (getter=isShown) BOOL shown;


@property (nonatomic, weak) IBOutlet NSButton *titleButton;

@property (nonatomic, weak) IBOutlet NSButton *disclosureButton;

@property (nonatomic, strong) TKMaterialPropertyViewController *viewController;

@property (nonatomic, copy) NSString *autosaveName;

@property (nonatomic, assign, getter=isInitiallyShown) BOOL initiallyShown;

@property (nonatomic, weak) IBOutlet id <MDInspectorViewDelegate> delegate;


- (void)changeWindowHeightBy:(CGFloat)value;

@end



