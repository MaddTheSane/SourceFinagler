//
//  TKMDLImporter.m
//  Source Finagler
//
//  Created by C.W. Betts on 11/24/17.
//  Copyright © 2017 Mark Douma LLC. All rights reserved.
//

#import "TKMDLImporter.h"

@implementation TKMDLImporter
{
	NSOperationQueue *tmpQueue;
	NSURL *mdlFile, *vvdFile, *vtxFile, *phyFile;
	NSError *errorEncountered;
}

- (nullable instancetype)initWithMDLFile:(NSURL*)mdlFile1 vvdFile:(NSURL*)vvdFile1 vtxFile:(NSURL*)vtxFile1 phyFile:(NSURL*)phyFile1 error:(NSError**)error
{
	if (self = [super init]) {
		mdlFile = mdlFile1;
		vvdFile = vvdFile1;
		vtxFile = vtxFile1;
		phyFile = phyFile1;
	}
	return self;
}

- (void)parseAsyncWithQueue:(NSOperationQueue *)queue completionHandler:(void (^)(SCNNode * _Nullable, NSError * _Nullable))compHandler
{
	NSBlockOperation *finalParse = [NSBlockOperation blockOperationWithBlock:^{
		
	}];
	NSBlockOperation *parseVVD = [NSBlockOperation blockOperationWithBlock:^{
		
	}];
	NSBlockOperation *parseMDL = [NSBlockOperation blockOperationWithBlock:^{
		
	}];
	NSBlockOperation *parseVTX = [NSBlockOperation blockOperationWithBlock:^{
		
	}];
	
	[finalParse setCompletionBlock:^{
		
	}];
	[finalParse addDependency:parseVVD];
	[finalParse addDependency:parseMDL];
	[finalParse addDependency:parseVTX];
	[queue addOperations:@[finalParse, parseVTX, parseVVD, parseMDL] waitUntilFinished:NO];
}

- (void)parseAsyncWithCompletionHandler:(void(^)(SCNNode *_Nullable parse, NSError *_Nullable err))compHandler
{
	tmpQueue = [NSOperationQueue new];
	[self parseAsyncWithQueue:tmpQueue completionHandler:compHandler];
}

- (BOOL)parseSyncWithError:(NSError**)error
{
	return NO;
}


@end
