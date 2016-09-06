//
//  HKFileAdditions.h
//  HLKit
//
//  Created by Mark Douma on 9/30/2010.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

#import <HLKit/HKFile.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSSound.h>
#import <QTKit/QTMovie.h>

NS_ASSUME_NONNULL_BEGIN

@interface HKFile (HKAdditions)

@property (readonly, copy) NSString *stringValue;
- (NSString *)stringValueByExtractingToTempFile:(BOOL)shouldExtractToTempFile;

@property (readonly, copy) NSImage *image;
@property (readonly, copy, nullable) NSSound *sound;
@property (readonly, copy, nullable) QTMovie *movie;

@end

NS_ASSUME_NONNULL_END
