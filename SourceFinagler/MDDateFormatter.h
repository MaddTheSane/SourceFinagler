//
//  MDDateFormatter.h
//  Font Finagler
//
//  Created by Mark Douma on 6/19/2009.
//  Copyright © 2009 - 2010 Mark Douma. All rights reserved.
//  


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**********************************************************************

	MDDateFormatterFullStyle	==	Monday, January 29, 2007, 12:43 AM
	MDDateFormatterLongStyle	==	January 29, 2007, 12:43 AM	
	MDDateFormatterMediumStyle	==	Jan 29, 2007, 12:43 AM
	MDDateFormatterShortStyle	==	1/29/2007, 12:43 AM
	MDDateFormatterNoStyle		==	1/29/2007

**********************************************************************/


typedef NS_ENUM(NSInteger, MDDateFormatterStyle) {    // date and time format styles
    MDDateFormatterNoStyle		=	kCFDateFormatterNoStyle,
    MDDateFormatterShortStyle	=	kCFDateFormatterShortStyle,
    MDDateFormatterMediumStyle	=	kCFDateFormatterMediumStyle,
    MDDateFormatterLongStyle	=	kCFDateFormatterLongStyle,
    MDDateFormatterFullStyle	=	kCFDateFormatterFullStyle
};

IB_DESIGNABLE
@interface MDDateFormatter : NSFormatter <NSCoding, NSCopying>

- (instancetype)init;
- (instancetype)initWithStyle:(MDDateFormatterStyle)aStyle isRelative:(BOOL)value;

IBInspectable
@property (nonatomic) MDDateFormatterStyle style;

IBInspectable
@property (getter=isRelative) BOOL relative;

@end

NS_ASSUME_NONNULL_END
