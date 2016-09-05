//
//  TKImageBrowserItem.h
//  Source Finagler
//
//  Created by Mark Douma on 10/10/2011.
//  Copyright 2011 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TKImageRep;

typedef NS_ENUM(NSUInteger, TKBrowserItemType) {
	TKFaceBrowserItemType = 0,
	TKFrameBrowserItemType,
	TKPlaceholderBrowserItemType
};


@interface TKImageBrowserItem : NSObject {
	TKImageRep			*imageRep;
	TKBrowserItemType	type;
}

+ (NSArray<TKImageBrowserItem*> *)faceBrowserItemsWithImageRepsInArray:(NSArray<TKImageRep*> *)imageReps;
+ (instancetype)faceBrowserItemWithImageRep:(TKImageRep *)anImageRep;

+ (NSArray<TKImageBrowserItem*> *)frameBrowserItemsWithImageRepsInArray:(NSArray<TKImageRep*> *)imageReps;
+ (instancetype)frameBrowserItemWithImageRep:(TKImageRep *)anImageRep;

- (instancetype)initWithImageRep:(TKImageRep *)anImageRep type:(TKBrowserItemType)aType NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (nonatomic, retain) TKImageRep *imageRep;
@property (nonatomic, assign) TKBrowserItemType type;


@property (readonly, copy) NSString *imageUID;
@property (readonly, copy) NSString *imageRepresentationType;
@property (readonly, retain) id imageRepresentation;
@property (readonly, copy) NSString *imageTitle;
@property (readonly, getter=isSelectable) BOOL selectable;



@end
