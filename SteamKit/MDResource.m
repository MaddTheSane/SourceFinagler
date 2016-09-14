//
//  MDResource.m
//  Font Finagler
//
//  Created by Mark Douma on 11/17/2008.
//  Copyright © 2008 Mark Douma. All rights reserved.
//


#import "MDResource.h"
#import "TKFoundationAdditions.h"


#define MD_DEBUG 0

@implementation MDResource
@synthesize resourceType;
@synthesize resourceID;
@synthesize resourceName;
@synthesize resourceData;
@synthesize resourceSize;
@synthesize resourceIndex;
@synthesize resourceAttributes;
@synthesize resChanged;

+ (id)resourceWithType:(ResType)aType index:(ResourceIndex)anIndex error:(NSError **)outError {
	return [[[self class] alloc] initWithType:aType index:anIndex error:outError];
}


- (id)initWithType:(ResType)aType index:(ResourceIndex)anIndex error:(NSError **)outError {
	if ((self = [super init])) {
		if (outError) *outError = nil;
		resourceType		= aType;
		resourceIndex		= anIndex;
		if (![self getResourceInfo:outError]) {
			NSLog(@"[%@ %@] *** ERROR: [self getResourceInfo:] failed!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
			return nil;
		}
		if (![self parseResourceData:outError]) {
			NSLog(@"[%@ %@] *** ERROR: [self parseResourceData:] failed!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
			return nil;
		}
	}
	return self;
}

- (id)initWithType:(ResType)aType resourceData:(NSData *)aData resourceID:(ResID)anID resourceName:(NSString *)aName resourceIndex:(ResourceIndex)anIndex resourceAttributes:(ResAttributes)anAttributes resChanged:(BOOL)aResChanged copy:(BOOL)shouldCopy error:(NSError **)outError {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super init])) {
		if (outError) *outError = nil;
		resourceType		= aType;
		resourceIndex		= anIndex;
		resourceID			= anID;
		
		if (shouldCopy) {
			resourceName	= [aName copy];
			resourceData	= [aData copy];
		} else {
			resourceName	= aName;
			resourceData	= aData;
		}

		resourceSize		= resourceData.length;
		resourceAttributes	= anAttributes;
		resChanged			= aResChanged;
		
		if (![self parseResourceData:outError]) {
			NSLog(@"[%@ %@] *** ERROR: [self parseResourceData:] failed!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
			return nil;
		}
	}
	return self;
}


- (void)setResourceType:(ResType)value {
	resourceType = value;
	[self setResChanged:YES];
}

- (void)setResourceID:(ResID)value {
	resourceID = value;
	resChanged = YES;
}

- (void)setResourceName:(NSString *)value {
	resourceName = [value copy];
	resChanged = YES;
}

- (void)setResourceData:(NSData *)value {
	resourceData = [value copy];
	resourceSize = (SInt32)resourceData.length;
	resChanged = YES;
}


- (void)setResourceSize:(long)value {
	resourceSize = value;
	[self setResChanged:YES];
}


- (void)setResourceIndex:(ResourceIndex)value {
	resourceIndex = value;
	[self setResChanged:YES];
}


- (void)setResourceAttributes:(MDResourceAttributes)value {
	resourceAttributes = value;
	[self setResChanged:YES];
}


- (BOOL)getResourceInfo:(NSError **)outError {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	ResID resID = 0;
	ResType resType;
	Str255 resName;
	
	Handle resHandle = Get1IndResource(resourceType, resourceIndex);
	OSErr err = ResError();
	if ( !(err == noErr && resHandle)) {
		NSLog(@"[%@ %@] ERROR: Get1IndResource() returned %hi", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
		if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
		return NO;
	}
	
	GetResInfo(resHandle, &resID, &resType, resName);
	err = ResError();
	if (err != noErr) {
		NSLog(@"[%@ %@] ERROR: GetResInfo() returned %hi", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
		if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
		ReleaseResource(resHandle);
		return NO;
	}
	
	resourceID = resID;
	resourceName = [NSString stringWithPascalString:resName];
	
	resourceSize = GetResourceSizeOnDisk(resHandle);
	err = ResError();
	if (err != noErr) {
		NSLog(@"[%@ %@] ERROR: ResError() for GetResourceSizeOnDisk() returned %hi", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
		if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
		ReleaseResource(resHandle);
		return NO;
	}
	
	HLock(resHandle);
	resourceData = [[NSData alloc] initWithBytes:*resHandle length:GetHandleSize(resHandle)];
	HUnlock(resHandle);
	
	resourceAttributes = GetResAttrs(resHandle);
	err = ResError();
	if (err != noErr) {
		NSLog(@"[%@ %@] ERROR: ResError() for GetResAttrs() returned %hi", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
		if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
		ReleaseResource(resHandle);
		return NO;
	}
	
	ReleaseResource(resHandle);
	err = ResError();
	if (err != noErr) {
		NSLog(@"[%@ %@] ERROR: ResError() for ReleaseResource() returned %hi", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
		if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
		return NO;
	}
	return YES;
}


/*	subclasses should override */

- (BOOL)parseResourceData:(NSError **)outError {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return YES;
}

@end
