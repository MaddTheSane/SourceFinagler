//
//  TKGrayscaleFilter.m
//  Source Finagler
//
//  Created by Mark Douma on 10/20/2011.
//  Copyright 2011 Mark Douma LLC. All rights reserved.
//

#import "TKGrayscaleFilter.h"


#define TK_DEBUG 1


static CIKernel *TKGrayscaleFilterKernel = nil;


@implementation TKGrayscaleFilter

@synthesize redScale;
@synthesize greenScale;
@synthesize blueScale;
@synthesize alphaScale;



- (instancetype)init {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super init])) {
		if (TKGrayscaleFilterKernel == nil) {
			NSBundle *bundle = [NSBundle bundleForClass:[self class]];
			NSArray *kernels = [CIKernel kernelsWithString:[NSString stringWithContentsOfFile:[bundle pathForResource:@"TKGrayscaleFilter" ofType:@"cikernel"]
																					 encoding:NSUTF8StringEncoding
																						error:NULL]];
			if (kernels.count) {
				TKGrayscaleFilterKernel = [kernels[0] retain];
			}
		}
		self.redScale = @(1.0/3.0);
		self.greenScale = @(1.0/3.0);
		self.blueScale = @(1.0/3.0);
		self.alphaScale = @(1.0/3.0);
		
		self.name = @"grayscaleFilter";
	}
	return self;
}


- (void)dealloc {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[inputImage release];
	[redScale release];
	[greenScale release];
	[blueScale release];
	[alphaScale release];
	[super dealloc];
}


- (NSDictionary *)customAttributes {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	return @{@"redScale": @{kCIAttributeMin: @0.0,
			 kCIAttributeSliderMin: @0.0,
			 kCIAttributeSliderMax: @1.0,
			 kCIAttributeDefault: @0.333,
			 kCIAttributeIdentity: @1.0,
			 kCIAttributeType: kCIAttributeTypeScalar},
			
			@"greenScale": @{kCIAttributeMin: @0.0,
			 kCIAttributeSliderMin: @0.0,
			 kCIAttributeSliderMax: @1.0,
			 kCIAttributeDefault: @0.333,
			 kCIAttributeIdentity: @1.0,
			 kCIAttributeType: kCIAttributeTypeScalar},
			
			@"blueScale": @{kCIAttributeMin: @0.0,
			 kCIAttributeSliderMin: @0.0,
			 kCIAttributeSliderMax: @1.0,
			 kCIAttributeDefault: @0.333,
			 kCIAttributeIdentity: @1.0,
			 kCIAttributeType: kCIAttributeTypeScalar},
			
			@"alphaScale": @{kCIAttributeMin: @0.0,
			 kCIAttributeSliderMin: @0.0,
			 kCIAttributeSliderMax: @1.0,
			 kCIAttributeDefault: @0.333,
			 kCIAttributeIdentity: @1.0,
			 kCIAttributeType: kCIAttributeTypeScalar}};
	
}


// called when setting up for fragment program and also calls fragment program
- (CIImage *)outputImage {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
    
    CISampler *src = [CISampler samplerWithImage:inputImage];
	
    return [self apply:TKGrayscaleFilterKernel,
			src,
			redScale,
			greenScale,
			blueScale,
			alphaScale,
			nil];
}



@end



