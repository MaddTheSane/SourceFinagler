//
//  TKGrayscaleFilter.h
//  Source Finagler
//
//  Created by Mark Douma on 10/20/2011.
//  Copyright 2011 Mark Douma LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


@interface TKGrayscaleFilter : CIFilter {
	CIImage			*inputImage;
	NSNumber		*redScale;
	NSNumber		*greenScale;
	NSNumber		*blueScale;
	NSNumber		*alphaScale;
}

@property (strong) NSNumber *redScale;
@property (strong) NSNumber *greenScale;
@property (strong) NSNumber *blueScale;
@property (strong) NSNumber *alphaScale;

@end
