//
//  HKFile.h
//  HLKit
//
//  Created by Mark Douma on 9/1/2010.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

#import <HLKit/HKItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface HKFile : HKItem

// convenience
- (BOOL)writeToFile:(NSString *)aPath assureUniqueFilename:(BOOL)assureUniqueFilename resultingPath:(NSString *__nullable*__nullable)resultingPath error:(NSError *__nullable*__nullable)outError;


- (BOOL)beginWritingToFile:(NSString *)aPath assureUniqueFilename:(BOOL)assureUniqueFilename resultingPath:(NSString *__nullable*__nullable)resultingPath error:(NSError *__nullable*__nullable)outError;
- (BOOL)continueWritingPartialBytesOfLength:(nullable NSUInteger *)partialBytesLength error:(NSError *__nullable*__nullable)outError;
- (BOOL)finishWritingWithError:(NSError *__nullable*__nullable)outError;

- (BOOL)cancelWritingAndRemovePartialFileWithError:(NSError *__nullable*__nullable)outError;



@property (readonly, copy, nullable) NSData *data;

@end

NS_ASSUME_NONNULL_END
