//
//  NSValue+TKValueAdditions.h
//  Source Finagler
//
//  Created by C.W. Betts on 9/3/16.
//
//

#import <Foundation/Foundation.h>
#import <TextureKit/TKMath.h>

@interface NSValue (TKValueAdditions)

+ (NSValue*)valueWithMatrix4:(TKMatrix4)mat;
- (TKMatrix4)matrix4;


@end
