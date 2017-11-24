//
//  SCNNode+TKDocumentInterop.h
//  Source Finagler
//
//  Created by C.W. Betts on 11/24/17.
//  Copyright © 2017 Mark Douma LLC. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <TextureKit/TKModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCNNode (TKDocumentInterop)

+ (nullable SCNNode*)nodeFromTKModel:(nonnull TKModel*)model;

@end

NS_ASSUME_NONNULL_END
