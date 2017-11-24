//
//  TKVVDParser.m
//  TextureKit
//
//  Created by C.W. Betts on 11/24/17.
//  Copyright © 2017 Mark Douma LLC. All rights reserved.
//

#import "TKVVDParser.h"
#import "TKMDLConstants.h"
#import <TextureKit/TKMath.h>


typedef struct VVDHeader {
	OSType magic_number;
	int    vvd_version;
	int    check_sum;
	
	int    num_lods;
	int    num_lod_verts[MAX_LODS];
	
	int    num_fixups;
	int    fixup_table_offset;
	
	int    vertex_data_offset;
	
	int    tangent_data_offset;
} VVDHeader;


typedef struct VVDFixupEntry {
	int   lod_number;
	
	int   source_vertex_id;
	int   num_vertices;
} VVDFixupEntry;

typedef struct VVDBoneWeight {
	float           weight[MAX_BONES_PER_VERTEX];
	char            bone[MAX_BONES_PER_VERTEX];
	unsigned char   num_bones;
} VVDBoneWeight;


typedef struct VVDVertex {
	VVDBoneWeight   bone_weights;
	TKVector3       vertex_position;
	TKVector3       vertex_normal;
	TKVector2       vertex_texcoord;
} VVDVertex;


@implementation TKVVDParser

@end
