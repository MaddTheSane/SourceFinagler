//
//  MDLaunchManager.h
//  Steam Example
//
//  Created by Mark Douma on 7/16/2010.
//  Copyright (c) 2010 Mark Douma LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <launch.h>

/// at this time, \c MDLaunchManager only supports user domain
typedef NS_ENUM(NSUInteger, MDLaunchDomain) {
	MDLaunchDomainUser		= 0,
	
};

#define NSStringFromLaunchJobKey(cString) @cString


NS_ASSUME_NONNULL_BEGIN

@interface MDLaunchManager : NSObject {
	// for performance reporting
	NSDate		*agentLaunchDate;
}
@property (class, readonly, retain) MDLaunchManager *defaultManager;

@property (retain) NSDate *agentLaunchDate;

- (nullable NSDictionary<NSString*,id> *)jobWithProcessIdentifier:(pid_t)pid inDomain:(MDLaunchDomain)domain;
- (nullable NSDictionary<NSString*,id> *)jobWithLabel:(NSString *)label inDomain:(MDLaunchDomain)domain;
- (nullable NSArray<NSDictionary<NSString*,id>*> *)jobsWithLabels:(NSArray<NSString*> *)labels inDomain:(MDLaunchDomain)domain;

- (BOOL)submitJobWithDictionary:(NSDictionary<NSString*,id> *)launchAgentPlist inDomain:(MDLaunchDomain)domain error:(NSError *__nullable*__nullable)outError;
- (BOOL)removeJobWithLabel:(NSString *)label inDomain:(MDLaunchDomain)domain error:(NSError *__nullable*__nullable)outError;

- (BOOL)replaceJob:(NSDictionary<NSString*,id> *)oldJob withJob:(NSDictionary<NSString*,id> *)newJob loadNewJobBeforeUnloadingOld:(BOOL)loadNewJobBeforeUnloadingOld inDomain:(MDLaunchDomain)domain error:(NSError *__nullable*__nullable)outError;
@end

static const MDLaunchDomain MDLaunchUserDomain NS_DEPRECATED_WITH_REPLACEMENT_MAC("MDLaunchDomainUser", 10.5, 10.11) = MDLaunchDomainUser;

NS_ASSUME_NONNULL_END
