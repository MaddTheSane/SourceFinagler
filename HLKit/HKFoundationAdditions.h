//
//  HKFoundationAdditions.h
//  HKFoundationAdditions
//
//  Created by Mark Douma on 12/03/2007.
//  Copyright (c) 2007-2012 Mark Douma LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>
#import <HLKit/HLKitDefines.h>

@interface NSString (HKAdditions)

+ (NSString *)stringWithFSRef:(const FSRef *)anFSRef;
- (BOOL)getFSRef:(FSRef *)anFSRef error:(NSError **)anError;

@property (readonly, copy) NSString *stringByAssuringUniqueFilename;


- (NSComparisonResult)caseInsensitiveNumericalCompare:(NSString *)string;
- (NSComparisonResult)localizedCaseInsensitiveNumericalCompare:(NSString *)string;


- (NSString *)stringByReplacing:(NSString *)value with:(NSString *)newValue;
@property (readonly, copy) NSString *slashToColon;
@property (readonly, copy) NSString *colonToSlash;


@end



@interface NSMutableArray<ObjectType> (HKAdditions)
- (void)insertObjectsFromArray:(NSArray<ObjectType> *)array atIndex:(NSUInteger)anIndex;
@end

