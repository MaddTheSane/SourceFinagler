//
//  MDTextFieldCell.h
//  Source Finagler
//
//  Created by Mark Douma on 1/31/2008.
//  Copyright © 2008 Mark Douma. All rights reserved.
//  


#import <Cocoa/Cocoa.h>


@interface MDTextFieldCell : NSTextFieldCell <NSCoding, NSCopying> {
	NSImage					*image;
	
	NSMutableDictionary		*highlightedActiveEnabledAttributes;
	NSMutableDictionary		*highlightedActiveDisabledAttributes;
	
	NSMutableDictionary		*highlightedInactiveEnabledAttributes;
	NSMutableDictionary		*highlightedInactiveDisabledAttributes;
	
	NSMutableDictionary		*enabledAttributes;
	NSMutableDictionary		*disabledAttributes;
	
	CGFloat					leftEdgePadding;
	BOOL					centerImageVertically;

}

- (void)drawWithFrame:(NSRect)cellFrame inImage:(NSImage *)dragImage;

- (NSArray<NSValue*> *)hitRectsForFrame:(NSRect)cellFrame isFlipped:(BOOL)isFlipped;

@property  CGFloat leftEdgePadding;
@property  BOOL centerImageVertically;


@property (nonatomic, retain) NSMutableDictionary *highlightedActiveEnabledAttributes;
@property (nonatomic, retain) NSMutableDictionary *highlightedActiveDisabledAttributes;

@property (nonatomic, retain) NSMutableDictionary *highlightedInactiveEnabledAttributes;
@property (nonatomic, retain) NSMutableDictionary *highlightedInactiveDisabledAttributes;

@property (nonatomic, retain) NSMutableDictionary *enabledAttributes;
@property (nonatomic, retain) NSMutableDictionary *disabledAttributes;

@end
