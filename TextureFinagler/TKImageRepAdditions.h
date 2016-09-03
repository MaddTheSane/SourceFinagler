//
//  TKImageRepAdditions.h
//  Source Finagler
//
//  Created by Mark Douma on 10/6/2012.
//
//


#import <TextureKit/TextureKit.h>


@interface TKImageRep (IKImageBrowserItem)

@property (readonly, copy) NSString *imageUID;					/* required */
@property (readonly, copy) NSString *imageRepresentationType;	/* required */
@property (readonly, strong) id imageRepresentation;				/* required */

@property (readonly, copy) NSString *imageTitle;

//- (NSUInteger)imageVersion;
//- (NSString *)imageSubtitle;
//- (BOOL)isSelectable;

@property (readonly, copy) NSDictionary *imageProperties;

@end


//@interface TKImageRep (IKImageProperties)
//- (NSDictionary *)imageProperties;
//@end




