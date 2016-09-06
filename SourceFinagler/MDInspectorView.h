//
//  MDInspectorView.h
//  MDInspectorView
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

extern NSString * const MDInspectorViewWillShowNotification;
extern NSString * const MDInspectorViewDidShowNotification;

extern NSString * const MDInspectorViewWillHideNotification;
extern NSString * const MDInspectorViewDidHideNotification;



@interface MDInspectorView : NSView <NSCoding> {
	
	__weak NSButton						*titleButton;
	__weak NSButton						*disclosureButton;
	
	__weak id <MDInspectorViewDelegate>	delegate;
	
	NSString								*autosaveName;
	
	NSArray									*hiddenSubviews;
	
    NSView									*nonretainedOriginalNextKeyView;
    NSView									*nonretainedLastChildKeyView;
	
	CGFloat									originalHeight;
	CGFloat									hiddenHeight;
	
	NSSize									sizeBeforeHidden;
	
	BOOL									isInitiallyShown;
	
	BOOL									isShown;
	
	BOOL									havePendingWindowHeightChange;
}

- (IBAction)toggleShown:(id)sender;
//- (IBAction)show:(id)sender;
//- (IBAction)hide:(id)sender;

@property (getter=isShown) BOOL shown;


@property (weak) IBOutlet NSButton *titleButton;

@property (weak) IBOutlet NSButton *disclosureButton;

@property (copy) NSString *autosaveName;

@property (getter=isInitiallyShown) BOOL initiallyShown;

@property (weak) IBOutlet id<MDInspectorViewDelegate> delegate;


//@property (assign) IBOutlet NSButton	*titleButton;
//@property (assign) IBOutlet NSButton	*disclosureButton;
//@property (copy)			NSString	*autosaveName;
//@property (assign, setter=setInitiallyShown:) BOOL isInitiallyShown;


//- (NSString *)identifier						DEPRECATED_ATTRIBUTE;
//- (void)setIdentifier:(NSString *)anIdentifier	DEPRECATED_ATTRIBUTE;

- (void)changeWindowHeightBy:(CGFloat)value;

@end



