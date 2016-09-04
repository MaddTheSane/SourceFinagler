//
//  TKTexture.h
//  Texture Kit
//
//  Created by Mark Douma on 1/7/2011.
//  Copyright (c) 2010-2012 Mark Douma LLC. All rights reserved.
//


#import <TextureKit/TKOpenGLObject.h>



@class NSString, NSURL, NSData;


@interface TKTexture : TKOpenGLObject {
	
	GLubyte			*data;
	GLsizei			size;
	
	GLuint			width;
	GLuint			height;
	
	GLenum			pixelFormat;
	GLenum			dataType;
	
	GLuint			rowByteSize;
	
}

+ (instancetype)textureWithContentsOfFile:(NSString *)aPath;
+ (instancetype)textureWithContentsOfURL:(NSURL *)URL;
+ (instancetype)textureWithData:(NSData *)aData;

// convenience analogous to NSImage's +imageNamed:
+ (instancetype)textureNamed:(NSString *)name;

- (instancetype)initWithContentsOfFile:(NSString *)aPath;
- (instancetype)initWithContentsOfURL:(NSURL *)URL;
- (instancetype)initWithData:(NSData *)aData;


- (void)bind;


@property (readonly, nonatomic, assign) GLubyte	*data;

@property (readonly, nonatomic, assign) GLsizei size;
@property (readonly, nonatomic, assign) GLuint width;
@property (readonly, nonatomic, assign) GLuint height;

@property (readonly, nonatomic, assign) GLenum pixelFormat;
@property (readonly, nonatomic, assign) GLenum dataType;

@property (readonly, nonatomic, assign) GLuint rowByteSize;



//- (void)generateTextureName;


@end



