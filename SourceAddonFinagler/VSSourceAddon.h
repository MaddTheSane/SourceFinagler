//
//  VSSourceAddon.h
//  Source Finagler
//
//  Created by Mark Douma on 11/15/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VSGame;

@interface VSSourceAddon : NSObject {
	NSString		*path;
	NSString		*fileName;
	NSImage			*fileIcon;
	NSString		*gameName;
	NSImage			*gameIcon;
	NSString		*problem;
}
+ (instancetype)sourceAddonWithPath:(NSString *)aPath game:(VSGame *)aGame error:(NSError *)inError;
- (instancetype)initWithPath:(NSString *)aPath game:(VSGame *)game error:(NSError *)inError;

@property (copy) NSString *path;
@property (copy) NSString *fileName;
@property (retain) NSImage *fileIcon;
@property (copy) NSString *gameName;
@property (retain) NSImage *gameIcon;
@property (copy) NSString *problem;

@end
