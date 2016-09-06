//
//  HKFolderAdditions.h
//  HLKit
//
//  Created by Mark Douma on 9/30/2010.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

#import <HLKit/HKFolder.h>

@class NSImage, QTMovie;

@interface HKFolder (HKAdditions)

@property (readonly, copy, nonnull) NSImage *image;
@property (readonly, copy, nullable) QTMovie *movie;

@end
