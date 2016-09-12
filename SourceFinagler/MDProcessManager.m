//
//  MDProcessManager.m
//  Source Finagler
//
//  Created by Mark Douma on 12/5/2006.
//  Copyright © 2006 Mark Douma. All rights reserved.
//  



#import "MDProcessManager.h"
#include <ApplicationServices/ApplicationServices.h>

#define NO_DEPRECATIONS 1

NSDictionary *MDInfoForProcessWithBundleIdentifier(NSString *aBundleIdentifier) {
#if NO_DEPRECATIONS
	NSArray *processArray = [NSRunningApplication runningApplicationsWithBundleIdentifier:aBundleIdentifier];
	NSRunningApplication *runningApp = processArray.firstObject;
	if (!runningApp) {
		return nil;
	}
	
	//NSBundle *aBund = [NSBundle bundleWithURL:runningApp.bundleURL];
	
	
	// These dictionary keys emulate the keys returned by ProcessInformationCopyDictionary
	// Although we only use kCFBundleIdentifierKey.
	NSMutableDictionary *aMut = [[NSMutableDictionary alloc] initWithCapacity:10];
	[aMut setDictionary:@{
						  @"Flavor": @3, //Cocoa Applications, making assumptions here…
						  @"pid": @(runningApp.processIdentifier),
						  @"RequiresCarbon": @YES, //As opposed to Classic, I'm guessing
						  }];
	
	if (runningApp.bundleURL) {
		aMut[@"BundlePath"] = runningApp.bundleURL.path;
	}
	
	if (runningApp.bundleIdentifier) {
		aMut[(NSString *)kCFBundleIdentifierKey] = runningApp.bundleIdentifier;
	}
	
	return [aMut copy];
#else
	ProcessSerialNumber psn;
	psn.highLongOfPSN = kNoProcess;
	psn.lowLongOfPSN  = kNoProcess;
	
	while (GetNextProcess(&psn) == noErr) {
		NSDictionary *processInfo = CFBridgingRelease(ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask));
//		NSLog(@"processInfo == %@", processInfo);
		if ([processInfo[(NSString *)kCFBundleIdentifierKey] isEqualToString:aBundleIdentifier]) {
			return processInfo;
		}
	}
	return nil;
#endif
}

