//
//  HKGCFFile.h
//  HLKit
//
//  Created by Mark Douma on 10/27/2010.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

#import <HLKit/HKArchiveFile.h>


@interface HKGCFFile : HKArchiveFile

@property (nonatomic, readonly, assign) NSUInteger packageID;

@property (nonatomic, readonly, assign) NSUInteger blockSize;
@property (nonatomic, readonly, assign) NSUInteger totalBlockCount;
@property (nonatomic, readonly, assign) NSUInteger usedBlockCount;
@property (nonatomic, readonly, assign) NSUInteger freeBlockCount;

@property (nonatomic, readonly, assign) NSUInteger lastVersionPlayed;

@end
