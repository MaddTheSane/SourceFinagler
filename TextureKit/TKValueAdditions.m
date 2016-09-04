//
//  NSValue+TKValueAdditions.m
//  Source Finagler
//
//  Created by C.W. Betts on 9/3/16.
//
//

#import "TKValueAdditions.h"
#import <GLKit/GLKit.h>

@implementation NSValue (TKValueAdditions)

+ (NSValue*)valueWithMatrix4:(TKMatrix4)mat
{
	return [NSValue value:&mat withObjCType:@encode(TKMatrix4)];
}

- (TKMatrix4)matrix4
{
	TKMatrix4 mat = {0};
	[self getValue:&mat];
	return mat;
}

@end
