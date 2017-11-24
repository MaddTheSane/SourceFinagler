//
//  TKMDLImporter.h
//  Source Finagler
//
//  Created by C.W. Betts on 11/24/17.
//  Copyright © 2017 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKMDLImporter : NSObject

- (nullable instancetype)initWithMDLFile:(NSURL*)mdlFile vvdFile:(NSURL*)vvdFile vtxFile:(NSURL*)vtxFile phyFile:(nullable NSURL*)phyFile error:(NSError**)error;

- (void)parseAsyncWithCompletionHandler:(void(^)(SCNNode *_Nullable parse, NSError *_Nullable err))compHandler;
- (void)parseAsyncWithQueue:(NSOperationQueue*)queue completionHandler:(void(^)(SCNNode *_Nullable parse, NSError *_Nullable err))compHandler;
- (BOOL)parseSyncWithError:(NSError**)error;
@property (readonly, strong, nullable) SCNNode *parsedNode;

@end

NS_ASSUME_NONNULL_END
