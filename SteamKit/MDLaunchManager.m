//
//  MDLaunchManager.m
//  Steam Example
//
//  Created by Mark Douma on 7/16/2010.
//  Copyright (c) 2010 Mark Douma LLC. All rights reserved.
//

#import "MDLaunchManager.h"
#import "MDFolderManager.h"
#import <ServiceManagement/ServiceManagement.h>


#define MD_DEBUG 0

@interface MDLaunchManager (MDPrivate)
- (BOOL)loadJobWithPath:(NSString *)path inDomain:(MDLaunchDomain)domain error:(NSError **)outError;
- (BOOL)unloadJobWithLabel:(NSString *)label inDomain:(MDLaunchDomain)domain error:(NSError **)outError;
@end

static BOOL agentIsUnloadingSelf = NO;



// Creating a Singleton Instance
//
// http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html#//apple_ref/doc/uid/TP40002974-CH4-SW32
//

static MDLaunchManager *sharedManager = nil;

@implementation MDLaunchManager

@synthesize agentLaunchDate;

+ (MDLaunchManager *)defaultManager {
	if (sharedManager == nil) {
		sharedManager = [[super allocWithZone:NULL] init];
	}
	return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
	return [[self defaultManager] retain];
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax; //denotes an object that cannot be released
}

- (oneway void)release {
	// do nothing
}

- (id)autorelease {
	return self;
}


- (NSDictionary *)jobWithProcessIdentifier:(pid_t)pid inDomain:(MDLaunchDomain)domain {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSDictionary *job = nil;
	if (pid > 0 && domain == MDLaunchUserDomain) {
		
			NSArray *jobs = CFBridgingRelease(SMCopyAllJobDictionaries((domain == MDLaunchUserDomain ? kSMDomainUserLaunchd : kSMDomainSystemLaunchd)));
			if (jobs) {
				for (NSDictionary *aJob in jobs) {
					if ([aJob[NSStringFromLaunchJobKey(LAUNCH_JOBKEY_PID)] intValue] == pid) {
						job = aJob;
						break;
					}
				}
			}
	}
	return job;
}

- (NSDictionary *)jobWithLabel:(NSString *)label inDomain:(MDLaunchDomain)domain {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSDictionary *job = nil;
	
	if (label && domain == MDLaunchUserDomain) {
		job = [(NSDictionary *)SMJobCopyDictionary((domain == MDLaunchUserDomain ? kSMDomainUserLaunchd : kSMDomainSystemLaunchd), (CFStringRef)label) autorelease];
	}
	return job;
}
		

- (NSArray *)jobsWithLabels:(NSArray *)labels inDomain:(MDLaunchDomain)domain {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSMutableArray *jobs = [NSMutableArray array];
	
	if (labels && labels.count && domain == MDLaunchUserDomain) {
		for (NSString *label in labels) {
			NSDictionary *job = [self jobWithLabel:label inDomain:domain];
			if (job) [jobs addObject:job];
	}
}
	return [[jobs copy] autorelease];
}



- (BOOL)submitJobWithDictionary:(NSDictionary *)launchAgentPlist inDomain:(MDLaunchDomain)domain error:(NSError **)outError {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (launchAgentPlist == nil || domain != MDLaunchUserDomain) return NO;
	if (outError) *outError = nil;
	
	@synchronized(self) {
		
		MDFolderManager *folderManager = [MDFolderManager defaultManager];
		NSString *launchAgentDirectoryPath = [folderManager pathForDirectoryWithName:@"LaunchAgents" inDirectory:MDLibraryDirectory inDomain:MDUserDomain error:outError];
		if (launchAgentDirectoryPath == nil) return NO;
		
		NSString *label = launchAgentPlist[NSStringFromLaunchJobKey(LAUNCH_JOBKEY_LABEL)];
		NSString *jobPath = [launchAgentDirectoryPath stringByAppendingPathComponent:[label stringByAppendingPathExtension:@"plist"]];
		
		if (![launchAgentPlist writeToFile:jobPath atomically:NO]) return NO;
		
		return [self loadJobWithPath:jobPath inDomain:MDLaunchUserDomain error:outError];
	}
	return NO;
}


- (BOOL)removeJobWithLabel:(NSString *)label inDomain:(MDLaunchDomain)domain error:(NSError **)outError {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (label == nil || domain != MDLaunchUserDomain) return NO;
	
	if (outError) *outError = nil;
	
	@synchronized(self) {
		
		MDFolderManager *folderManager = [MDFolderManager defaultManager];
		NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
		
		NSString *launchAgentDirectoryPath = [folderManager pathForDirectoryWithName:@"LaunchAgents" inDirectory:MDLibraryDirectory inDomain:MDUserDomain error:outError];
		if (launchAgentDirectoryPath == nil) return NO;
		
		NSString *jobPath = [launchAgentDirectoryPath stringByAppendingPathComponent:[label stringByAppendingPathExtension:@"plist"]];
		if ([fileManager fileExistsAtPath:jobPath]) [fileManager removeItemAtPath:jobPath error:outError];
		return [self unloadJobWithLabel:label inDomain:domain error:outError];
	}
	return NO;
}


- (BOOL)replaceJob:(NSDictionary *)oldJob withJob:(NSDictionary *)newJob loadNewJobBeforeUnloadingOld:(BOOL)loadNewJobBeforeUnloadingOld inDomain:(MDLaunchDomain)domain error:(NSError **)outError {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (oldJob == nil || newJob == nil || domain != MDLaunchUserDomain) return NO;
	if (outError) *outError = nil;
	
	@synchronized(self) {
		
#if MD_DEBUG
		NSLog(@"[%@ %@] newJob == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), newJob);
#endif
		
		NSString *oldJobLabel = oldJob[NSStringFromLaunchJobKey(LAUNCH_JOBKEY_LABEL)];
		if (oldJobLabel == nil) {
			NSLog(@"[%@ %@] failed to get oldJobLabel", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
			return NO;
		}
		
		if (loadNewJobBeforeUnloadingOld) {
			agentIsUnloadingSelf = YES;
			if (![self submitJobWithDictionary:newJob inDomain:domain error:outError]) {
				return NO;
			}
			
			if (![self removeJobWithLabel:oldJobLabel inDomain:domain error:outError]) {
				return NO;
			}
			
		} else {
			if (![self removeJobWithLabel:oldJobLabel inDomain:domain error:outError]) {
				return NO;
			}
			if (![self submitJobWithDictionary:newJob inDomain:domain error:outError]) {
				return NO;
			}
		}
	}
	return YES;
}

@end


@implementation MDLaunchManager (MDPrivate)

- (BOOL)loadJobWithPath:(NSString *)path inDomain:(MDLaunchDomain)domain error:(NSError **)outError {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	BOOL success = NO;
	if (outError) *outError = nil;
	if (path && domain == MDLaunchUserDomain) {
		
		@synchronized(self) {
				NSDictionary *job = [NSDictionary dictionaryWithContentsOfFile:path];
				if (job) success = (BOOL)SMJobSubmit(kSMDomainUserLaunchd, (CFDictionaryRef)job, NULL, (CFErrorRef *)outError);
		}
	}
	return success;
}



- (BOOL)unloadJobWithLabel:(NSString *)label inDomain:(MDLaunchDomain)domain error:(NSError **)outError {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	BOOL success = NO;
	if (outError) *outError = nil;
	if (label && domain == MDLaunchUserDomain) {
		@synchronized(self) {
			if (agentIsUnloadingSelf && agentLaunchDate) {
				NSTimeInterval totalElapsedTime = fabs(agentLaunchDate.timeIntervalSinceNow);
				[agentLaunchDate release];
				agentLaunchDate = nil;
				
#if MD_DEBUG
				NSLog(@"[%@ %@] ***** TOTAL ELAPSED TIME == %.7f sec (%.4f ms) *****", NSStringFromClass([self class]), NSStringFromSelector(_cmd), totalElapsedTime, totalElapsedTime * 1000.0);
#endif
			}
			
			success = (BOOL)SMJobRemove(kSMDomainUserLaunchd, (CFStringRef)label, NULL, NO, (CFErrorRef *)outError);
		}
	}
	return success;
}

@end

