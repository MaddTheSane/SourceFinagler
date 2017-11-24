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
}

- (nullable instancetype)initWithMDLFile:(NSURL*)mdlFile vvdFile:(NSURL*)vvdFile vtxFile:(NSURL*)vtxFile phyFile:(NSURL*)phyFile error:(NSError**)error
{
	if (self = [super init]) {
		
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
