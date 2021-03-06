//
//  main.m
//  Source Finagler
//
//  Created by Mark Douma on 5/12/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#include <TargetConditionals.h>

#pragma mark -
#pragma mark PowerPC

#if TARGET_CPU_PPC || TARGET_CPU_PPC64

#import <Cocoa/Cocoa.h>
#import "TKAppKitAdditions.h"

int main(int argc, char *argv[]) {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[NSApplication sharedApplication];
	
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Source Finagler is only intended for Intel-based Macs!", @"")
								   informativeText:NSLocalizedString(@"Sorry, but you need at least Mac OS X 10.6 on an Intel-based Mac to run this application!", @"")
									   firstButton:NSLocalizedString(@"Quit", @"")
									  secondButton:nil
									   thirdButton:nil];
	
	[alert runModal];
	
	[pool release];
	return 0;
}
#endif
#pragma mark (END) PowerPC


#pragma mark -
#pragma mark Intel

#if TARGET_CPU_X86 || TARGET_CPU_X86_64 || TARGET_CPU_ARM64

#import <Cocoa/Cocoa.h>
#import "TKAppKitAdditions.h"


int main(int argc, char *argv[]) {
	return NSApplicationMain(argc, (const char **)argv);
}
#endif


