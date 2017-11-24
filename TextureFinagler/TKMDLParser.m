//
//  TKMDLParser.m
//  TextureKit
//
//  Created by C.W. Betts on 11/24/17.
//  Copyright © 2017 Mark Douma LLC. All rights reserved.
//

#import "TKMDLParser.h"
#import "TKMDLConstants.h"
#import <TextureKit/TKMath.h>

typedef struct MDLHeader {
	OSType        magic_number;
	int           mdl_version;
	int           check_sum;
	char          mdl_name[64];
	int           mdl_length;
	
	TKVector3     eye_position;
	TKVector3     illum_position;
	TKVector3     hull_min;
	TKVector3     hull_max;
	TKVector3     view_bbox_min;
	TKVector3     view_bbox_max;
	
	int           mdl_flags;
	
	int           num_bones;
	int           bone_offset;
	
	int           num_bone_controllers;
	int           bone_controller_offset;
	
	int           num_hitbox_sets;
	int           hitbox_set_offset;
	
	int           num_local_animations;
	int           local_animation_offset;
	
	int           num_local_sequences;
	int           local_sequence_offset;
	
	int           activity_list_version;
	int           events_offseted;
	
	int           num_textures;
	int           texture_offset;
	
	int           num_texture_paths;
	int           texture_path_offset;
	
	int           num_skin_refs;
	int           num_skin_families;
	int           skin_offset;
	
	int           num_body_parts;
	int           body_part_offset;
	
	int           num_local_attachments;
	int           local_attachment_offset;
	
	int           num_local_nodes;
	int           local_node_offset;
	int           local_node_name_offset;
	
	int           num_flex_desc;
	int           flex_desc_offset;
	
	int           num_flex_controllers;
	int           flex_controller_offset;
	
	int           num_flex_rules;
	int           flex_rule_offset;
	
	int           num_ik_chains;
	int           ik_chain_offset;
	
	int           num_mouths;
	int           mouth_offset;
	
	int           num_local_pose_params;
	int           local_pose_param_offset;
	
	int           surface_prop_offset;
	
	int           key_value_offset;
	int           key_value_size;
	
	int           num_local_ik_autoplay_locks;
	int           local_ik_autoplay_lock_offset;
	
	float         mdl_mass;
	int           mdl_contents;
	
	int           num_include_models;
	int           include_model_offset;
	
	// Originally a mutable void * (changed for portability)
	int           virtual_model;
	
	int           anim_block_name_offset;
	int           num_anim_blocks;
	int           anim_block_offset;
	
	// Originally a mutable void * (changed for portability)
	int           anim_block_model;
	
	int           bone_table_by_name_offset;
	
	// Originally both void * (changed for portability)
	int           vertex_base;
	int           offset_base;
	
	unsigned char const_direction_light_dot;
	unsigned char root_lod;
	unsigned char unused_byte[2];
	
	int           zero_frame_cache_offset;
	
	int           unused_fields[2];
} MDLHeader;


typedef struct MDLTexture {
	int	tex_name_offset;
	int	tex_flags;
	int	tex_used;
	
	int	unused_1;
	
	// Originally both mutable void * (changed for portability)
	int	tex_material;
	int	client_material;
	
	int	unused_array[10];
} TKMDLTexture;


typedef struct MDLModelVertexData {
	// No useful values are stored in the file for this structure, but we
	// need the size to be right so we can properly read subsequent models
	// from the file
	int    vertex_data_ptr;
	int    tangent_data_ptr;
} MDLModelVertexData;


typedef struct MDLModel {
	char                  model_name[64];
	int                   model_type;
	float                 bounding_radius;
	int                   num_meshes;
	int                   mesh_offset;
	
	int                   num_vertices;
	int                   vertex_index;
	int                   tangents_index;
	
	int                   num_attachments;
	int                   attachment_offset;
	int                   num_eyeballs;
	int                   eyeball_offset;
	
	MDLModelVertexData    vertex_data;
	
	int                   unused_array[8];
} MDLModel;

@implementation TKMDLParser

@end
