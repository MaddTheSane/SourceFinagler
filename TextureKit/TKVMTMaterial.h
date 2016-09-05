//
//  TKVMTMaterial.h
//  Texture Kit
//
//  Created by Mark Douma on 1/17/2011.
//  Copyright (c) 2010-2012 Mark Douma LLC. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <TextureKit/TextureKitDefines.h>


@class TKVMTNode;


@interface TKVMTMaterial : NSObject <NSCopying> {
	TKVMTNode		*rootNode;
}

+ (instancetype)materialWithContentsOfFile:(NSString *)aPath error:(NSError **)outError;
+ (instancetype)materialWithContentsOfURL:(NSURL *)URL error:(NSError **)outError;
+ (instancetype)materialWithData:(NSData *)aData error:(NSError **)outError;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithContentsOfFile:(NSString *)aPath error:(NSError **)outError;
- (instancetype)initWithContentsOfURL:(NSURL *)URL error:(NSError **)outError;
- (instancetype)initWithData:(NSData *)aData error:(NSError **)outError NS_DESIGNATED_INITIALIZER;


- (NSDictionary<NSString*,id> *)dictionaryRepresentation;

@property (readonly, copy) NSString *stringRepresentation;


@property (nonatomic, retain) TKVMTNode *rootNode;


@end


