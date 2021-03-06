//
//  TKVMTNode.h
//  Texture Kit
//
//  Created by Mark Douma on 11/22/2011.
//  Copyright (c) 2010-2013 Mark Douma LLC. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <TextureKit/TextureKitDefines.h>


typedef NS_ENUM(NSUInteger, TKVMTNodeKind) {
	TKVMTNodeKindInvalid	= 0,
	TKVMTNodeKindGroup,
	TKVMTNodeKindComment,
	TKVMTNodeKindString,
	TKVMTNodeKindInteger,
	TKVMTNodeKindFloat,
//	TKVMTNodeKindRoot
};


@interface TKVMTNode : NSObject <NSCopying> {
	__weak TKVMTNode	*rootNode;		// non-retained
	__weak TKVMTNode	*parent;		// non-retained
	
	NSMutableArray		*children;
	
	NSString			*name;
	id					objectValue;
	
	TKVMTNodeKind		kind;
	
	NSUInteger			index;
	NSUInteger			level;
	BOOL				leaf;
}

+ (instancetype)nodeWithName:(NSString *)aName kind:(TKVMTNodeKind)aKind objectValue:(id)anObjectValue;
- (instancetype)initWithName:(NSString *)aName kind:(TKVMTNodeKind)aKind objectValue:(id)anObjectValue NS_DESIGNATED_INITIALIZER;
-(instancetype)init UNAVAILABLE_ATTRIBUTE;

+ (instancetype)groupNodeWithName:(NSString *)aName;
+ (instancetype)commentNodeWithStringValue:(NSString *)stringValue;
+ (instancetype)stringNodeWithName:(NSString *)aName stringValue:(NSString *)stringValue;
+ (instancetype)integerNodeWithName:(NSString *)aName integerValue:(NSInteger)anInteger;
+ (instancetype)floatNodeWithName:(NSString *)aName floatValue:(CGFloat)aFloat;


@property (readonly, nonatomic, weak) TKVMTNode *rootNode;
@property (readonly, nonatomic, weak) TKVMTNode *parent;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) id objectValue;

@property (nonatomic, assign) TKVMTNodeKind kind;

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger level;

@property (readonly, nonatomic, assign, getter=isLeaf) BOOL leaf;


@property (readonly, copy) NSArray<TKVMTNode*> *children;
@property (readonly) NSUInteger countOfChildren;
- (TKVMTNode *)childAtIndex:(NSUInteger)anIndex;
- (void)insertChild:(TKVMTNode *)aChild atIndex:(NSUInteger)anIndex;
- (void)addChild:(TKVMTNode *)aChild;
- (void)removeChild:(TKVMTNode *)aChild;
- (void)removeAllChildren;


@property (readonly, copy) NSString *stringRepresentation;
@property (readonly, copy) NSString *stringValue;
@property (readonly) NSInteger integerValue;
@property (readonly) CGFloat floatValue;

@end
