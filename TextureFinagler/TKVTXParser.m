//
//  TKVTXParser.m
//  TextureKit
//
//  Created by C.W. Betts on 11/24/17.
//  Copyright © 2017 Mark Douma LLC. All rights reserved.
//

#import "TKVTXParser.h"
#import "TKMDLConstants.h"
#import <TextureKit/TKMath.h>

typedef struct VTXHeader {
	int              vtx_version;
	int              vertex_cache_size;
	unsigned short   max_bones_per_strip;
	unsigned short   max_bones_per_tri;
	int              max_bones_per_vertex;
	
	int              check_sum;
	int              num_lods;
	
	int              mtl_replace_list_offset;
	
	int              num_body_parts;
	int              body_part_offset;
} VTXHeader;


typedef struct VTXMaterialReplacementList {
	int   num_replacements;
	int   replacement_offset;
} VTXMaterialReplacementList;


typedef struct VTXMaterialReplacment {
	short   material_id;
	int     replacement_material_name_offset;
} VTXMaterialReplacment;


typedef struct VTXBodyPart {
	int   num_models;
	int   model_offset;
} VTXBodyPart;


typedef struct VTXModel {
	int   num_lods;
	int   lod_offset;
} VTXModel;


typedef struct VTXModelLOD {
	int     num_meshes;
	int     mesh_offset;
	float   switch_point;
} VTXModelLOD;


typedef NS_OPTIONS(unsigned char, VTXMeshFlags) {
	VTXMeshIsTeeth  = 0x01,
	VTXMeshIsEyes   = 0x02
};

typedef struct VTXMesh {
	int             num_strip_groups;
	int             strip_group_offset;
	
	VTXMeshFlags    mesh_flags;
} VTXMesh;

//! Can't rely on sizeof() because Valve explicitly packs these structures to
//! 1-byte alignment in the file, which isn't portable
const int VTX_MESH_SIZE = 9;


typedef NS_OPTIONS(unsigned char, VTXStripGroupFlags) {
	VTXStripGroupIsFlexed			= 0x01,
	VTXStripGroupHardwareSkinned	= 0x02,
	VTXStripGroupDeltaFlexed		= 0x04
};


typedef struct VTXStripGroup {
	int		num_vertices;
	int		vertex_offset;
	
	int		num_indices;
	int		index_offset;
	
	int		num_strips;
	int		strip_offset;
	
	VTXStripGroupFlags	strip_group_flags;
} __attribute__((packed)) VTXStripGroup;

//! Can't rely on sizeof() because Valve explicitly packs these structures to
//! 1-byte alignment in the file, which isn't portable
const int VTX_STRIP_GROUP_SIZE = 25;


typedef NS_OPTIONS(unsigned char, VTXStripFlags) {
	VTXStripIsTriList	= 0x01,
	VTXStripIsTriStrip	= 0x02,
};

typedef struct VTXStrip {
	int             num_indices;
	int             index_offset;
	
	int             num_vertices;
	int             vertex_offset;
	
	short           num_bones;
	
	VTXStripFlags   strip_flags;
	
	int             num_bone_state_changes;
	int             bone_state_change_offset;
} __attribute__((packed)) VTXStrip;


//! Can't rely on sizeof() because Valve explicitly packs these structures to
//! 1-byte alignment in the .vtx file, which isn't portable
const int VTX_STRIP_SIZE = 27;


typedef struct VTXVertex {
	unsigned char   bone_weight_index[MAX_BONES_PER_VERTEX];
	unsigned char   num_bones;
	
	short           orig_mesh_vertex_id;
	
	char            bone_id[MAX_BONES_PER_VERTEX];
} __attribute__((packed)) VTXVertex;


//! Can't rely on sizeof() because Valve explicitly packs these structures to
//! 1-byte alignment in the .vtx file, which isn't portable
const int VTX_VERTEX_SIZE = 9;


typedef struct VTXBoneStateChange {
	int   hardware_id;
	int   new_bone_id;
} VTXBoneStateChange;

static const VTXMeshFlags MESH_IS_TEETH API_DEPRECATED_WITH_REPLACEMENT("VTXMeshIsTeeth", macosx(10.0, 10.2)) __unused = VTXMeshIsTeeth;
static const VTXMeshFlags MESH_IS_EYES API_DEPRECATED_WITH_REPLACEMENT("VTXMeshIsEyes", macosx(10.0, 10.2)) __unused = VTXMeshIsEyes;
static const VTXStripGroupFlags STRIP_GROUP_IS_FLEXED API_DEPRECATED_WITH_REPLACEMENT("VTXStripGroupIsFlexed", macosx(10.0, 10.2)) __unused = VTXStripGroupIsFlexed;
static const VTXStripGroupFlags STRIP_GROUP_IS_HW_SKINNED API_DEPRECATED_WITH_REPLACEMENT("VTXStripGroupHardwareSkinned", macosx(10.0, 10.2)) __unused = VTXStripGroupHardwareSkinned;
static const VTXStripGroupFlags STRIP_GROUP_IS_DELTA_FLEXED API_DEPRECATED_WITH_REPLACEMENT("VTXStripGroupDeltaFlexed", macosx(10.0, 10.2)) __unused = VTXStripGroupDeltaFlexed;
static const VTXStripFlags STRIP_IS_TRI_LIST API_DEPRECATED_WITH_REPLACEMENT("VTXStripIsTriList", macosx(10.0, 10.2)) __unused = VTXStripIsTriList;
static const VTXStripFlags STRIP_IS_TRI_STRIP API_DEPRECATED_WITH_REPLACEMENT("VTXStripIsTriStrip", macosx(10.0, 10.2)) __unused = VTXStripIsTriStrip;


@implementation TKVTXParser

@end
