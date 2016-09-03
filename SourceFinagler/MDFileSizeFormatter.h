//
//  MDFileSizeFormatter.h
//  Font Finagler
//
//  Created by Mark Douma on 6/19/2009.
//  Copyright © 2009 - 2010 Mark Douma. All rights reserved.
//  


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MDFileSizeFormatterUnitsType) {
	MDFileSizeFormatterAutomaticUnitsType		= 1,
	MDFileSizeFormatter1000BytesInKBUnitsType	= 2,
	MDFileSizeFormatter1024BytesInKBUnitsType	= 3
};

typedef NS_ENUM(NSUInteger, MDFileSizeFormatterStyle) {
	MDFileSizeFormatterLogicalStyle		= 0,	///< 19,088 bytes
	MDFileSizeFormatterPhysicalStyle	= 1,	///< 20 KB
	MDFileSizeFormatterFullStyle		= 2		///< 20 KB on disk (19,088 bytes)
};


@interface MDFileSizeFormatter : NSFormatter <NSCopying, NSCoding> {
	MDFileSizeFormatterUnitsType	unitsType;
	MDFileSizeFormatterStyle		style;
	NSNumberFormatter				*numberFormatter;
	NSNumberFormatter				*bytesFormatter;
}
- (instancetype)initWithUnitsType:(MDFileSizeFormatterUnitsType)aUnitsType style:(MDFileSizeFormatterStyle)aStyle;

@property MDFileSizeFormatterUnitsType unitsType;

@property MDFileSizeFormatterStyle style;

@end

