//
//  MDLaunchManager.h
//  Steam Example
//
//  Created by Mark Douma on 7/16/2010.
//  Copyright (c) 2010 Mark Douma LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <launch.h>

// at this time, MDLaunchManager only supports user domain
typedef NS_ENUM(NSUInteger, MDLaunchDomain) {
	MDLaunchUserDomain		= 0
};

#define NSStringFromLaunchJobKey(cString) @cString


@interface MDLaunchManager : NSObject {
	// for performance reporting
	NSDate		*agentLaunchDate;
}
+ (MDLaunchManager *)defaultManager; // singleton
#if __has_feature(objc_class_property)
@property (readonly, retain) MDLaunchManager *defaultManager;
#endif

@property (retain) NSDate *agentLaunchDate;

- (NSDictionary *)jobWithProcessIdentifier:(pid_t)pid inDomain:(MDLaunchDomain)domain;
- (NSDictionary *)jobWithLabel:(NSString *)label inDomain:(MDLaunchDomain)domain;
- (NSArray *)jobsWithLabels:(NSArray *)labels inDomain:(MDLaunchDomain)domain;

- (BOOL)submitJobWithDictionary:(NSDictionary *)launchAgentPlist inDomain:(MDLaunchDomain)domain error:(NSError **)outError;
- (BOOL)removeJobWithLabel:(NSString *)label inDomain:(MDLaunchDomain)domain error:(NSError **)outError;

- (BOOL)replaceJob:(NSDictionary *)oldJob withJob:(NSDictionary *)newJob loadNewJobBeforeUnloadingOld:(BOOL)loadNewJobBeforeUnloadingOld inDomain:(MDLaunchDomain)domain error:(NSError **)outError;
@end


