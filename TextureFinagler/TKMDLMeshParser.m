//
//  TKMDLMeshParser.m
//  TextureKit
//
//  Created by C.W. Betts on 11/24/17.
//  Copyright © 2017 Mark Douma LLC. All rights reserved.
//

#import "TKMDLMeshParser.h"
#import "TKMDLConstants.h"
#import <TextureKit/TKMath.h>

typedef struct MDLMeshVertexData {
	//! Used by the Source engine for cache purposes.  This value is allocated
	//! in the file, but no meaningful data is stored there
	int    model_vertex_data_ptr;
	
	//! Indicates the number of vertices used by each LOD of this mesh
	int    num_lod_vertices[MAX_LODS];
} MDLMeshVertexData;


typedef struct MDLMesh {
	int                  material_index;
	int                  model_index;
	
	int                  num_vertices;
	int                  vertex_offset;
	
	int                  num_flexes;
	int                  flex_offset;
	
	int                  material_type;
	int                  material_param;
	
	int                  mesh_id;
	
	TKVector3            mesh_center;
	
	MDLMeshVertexData    vertex_data;
	
	int                  unused_array[8];
} TKMDLMesh;


@implementation TKMDLMeshParser

@end
