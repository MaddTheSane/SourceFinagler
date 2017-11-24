//
//  TKVVDModel.m
//  TextureKit
//
//  Created by C.W. Betts on 11/24/17.
//  Copyright © 2017 Mark Douma LLC. All rights reserved.
//

#import "TKMDLModel.h"
#import <TextureKit/TKMath.h>
#import "TKMDLConstants.h"



@implementation TKMDLModel
{
	NSURL *mdlLocation;
	NSURL *vtxLocation;
	NSURL *vvdLocation;
}

- (instancetype)initWithContentsOfURL:(NSURL *)URL
{
	if (self = [super initWithContentsOfURL:URL]) {
		mdlLocation = URL;
		NSURL *baseName = URL.URLByDeletingPathExtension;
		vvdLocation = [baseName URLByAppendingPathExtension:@"vvd"];
		// VTX could be in a couple of files. Try looking in this order: dx90, dx80, sw
		NSURL *tmpVTX;
		for (NSString *extension in @[@"dx90.vtx", @"dx80.vtx", @"sw.vtx"]) {
			tmpVTX = [baseName URLByAppendingPathExtension:extension];
			if ([tmpVTX checkResourceIsReachableAndReturnError:NULL]) {
				break;
			} else {
				tmpVTX = nil;
			}
		}
		vtxLocation = tmpVTX;
		
		if (![self delayedParse]) {
			return nil;
		}
	}
	return self;
}

- (BOOL)parseModelData:(NSData *)data
{
	return YES;
}

- (BOOL)delayedParse
{
	return NO;
}

@end
