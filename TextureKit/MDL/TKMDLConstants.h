//
//  TKMDLConstants.h
//  TextureKit
//
//  Created by C.W. Betts on 11/24/17.
//  Copyright © 2017 Mark Douma LLC. All rights reserved.
//

#ifndef TKMDLConstants_h
#define TKMDLConstants_h

#import <Foundation/Foundation.h>

NS_ENUM(OSType) {
	//! The magic number for a Valve VVD file is 'IDSV' in little-endian
	//! order
	VVD_MAGIC_NUMBER = (('V'<<24)+('S'<<16)+('D'<<8)+'I'),
	//! The magic number for a Valve MDL file is 'IDST' in little-endian
	//! order
	MDL_MAGIC_NUMBER = (('T'<<24)+('S'<<16)+('D'<<8)+'I'),
	};
#if 0 //Because Xcode is being a dumb-dumb about indentation.
}
#endif

//! Maximum number of LODs per model
#define MAX_LODS 8

//! Maximum number of bones per vertex
#define MAX_BONES_PER_VERTEX 3

#endif /* TKMDLConstants_h */
