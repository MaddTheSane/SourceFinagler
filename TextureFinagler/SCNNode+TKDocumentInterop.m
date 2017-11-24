//
//  SCNNode+TKDocumentInterop.m
//  Source Finagler
//
//  Created by C.W. Betts on 11/24/17.
//  Copyright © 2017 Mark Douma LLC. All rights reserved.
//

#import "SCNNode+TKDocumentInterop.h"

@interface TKModel (SCNGetters)

- (SCNGeometry*)scnGeometry;

@end

@implementation TKModel (SCNGetters)

- (SCNGeometry*)scnGeometry
{
	return nil;
}

@end

@implementation SCNNode (TKDocumentInterop)

+ (SCNNode*)nodeFromTKModel:(TKModel*)model
{
	return nil;
}

@end
