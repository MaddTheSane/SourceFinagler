//
//  MDResource.h
//  Font Finagler
//
//  Created by Mark Douma on 11/17/2008.
//  Copyright © 2008 Mark Douma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

/* Resource Attribute Masks*/
typedef NS_OPTIONS(ResAttributes, MDResourceAttributes) {
	MDResourceAttributeSystemHeap                 = 64,   /**<System or application heap?*/
	MDResourceAttributePurgeable                  = 32,   /**<Purgeable resource?*/
	MDResourceAttributeLocked                     = 16,   /**<Load it in locked?*/
	MDResourceAttributeProtected                  = 8,    /**<Protected?*/
	MDResourceAttributePreload                    = 4,    /**<Load in on OpenResFile?*/
	MDResourceAttributeChanged                    = 2     /**<Resource changed?*/
};


@interface MDResource : NSObject {
	NSString			*resourceName;
	NSData				*resourceData;
	long				resourceSize;
	ResType				resourceType;
	ResourceIndex		resourceIndex;
	ResID				resourceID;
	MDResourceAttributes resourceAttributes;
	BOOL				resChanged;
	
}

+ (MDResource*)resourceWithType:(ResType)aType index:(ResourceIndex)anIndex error:(NSError **)outError;

- (instancetype)initWithType:(ResType)aType index:(ResourceIndex)anIndex error:(NSError **)outError;

- (instancetype)initWithType:(ResType)aType resourceData:(NSData *)aData resourceID:(ResID)anID resourceName:(NSString *)aName resourceIndex:(ResourceIndex)anIndex resourceAttributes:(ResAttributes)anAttributes resChanged:(BOOL)aResChanged copy:(BOOL)shouldCopy error:(NSError **)outError;


- (BOOL)getResourceInfo:(NSError **)outError;
- (BOOL)parseResourceData:(NSError **)outError;


@property (nonatomic) ResType resourceType;
@property (nonatomic) ResID resourceID;
@property (nonatomic, copy) NSString *resourceName;
@property (nonatomic, copy) NSData *resourceData;
@property (nonatomic) long resourceSize;
@property (nonatomic) ResourceIndex resourceIndex;
@property (nonatomic) MDResourceAttributes resourceAttributes;
@property BOOL resChanged;
@end
