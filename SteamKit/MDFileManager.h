//
//  MDFileManager.h
//  Font Finagler
//
//  Created by Mark Douma on 11/20/2006.
//  Copyright © 2006 Mark Douma. All rights reserved.
//  


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_ENUM(NSInteger) {
	MDFileLabelNone				= 0,
	MDFileLabelGray				= 1,
	MDFileLabelGreen			= 2,
	MDFileLabelPurple			= 3,
	MDFileLabelBlue				= 4,
	MDFileLabelYellow			= 5,
	MDFileLabelRed				= 6,
	MDFileLabelOrange			= 7,
	MDFileLabelUnsupported		= NSNotFound
};

typedef NSString *MDFileProperty NS_STRING_ENUM;

@interface MDFileManager : NSObject {
	NSFileManager	*fileManager;

}
@property (class, readonly, retain) MDFileManager *defaultManager;

/// returns all HFS+ info as well as resource fork sizes
- (nullable NSDictionary<MDFileProperty,id> *)attributesOfItemAtPath:(NSString *)path error:(NSError **)outError;
- (BOOL)setAttributes:(NSDictionary<MDFileProperty,id> *)attributes ofItemAtPath:(NSString *)path error:(NSError **)error;

/// returns resource fork sizes only
- (nullable NSDictionary<MDFileProperty,id> *)fileAttributesAtPath:(NSString *)path traverseLink:(BOOL)yorn;

- (BOOL)isDeletableFileAtPath:(NSString *)path;

@end

extern MDFileProperty const MDFileLabelNumber;
extern MDFileProperty const MDFileHasCustomIcon;
extern MDFileProperty const MDFileIsStationery;
extern MDFileProperty const MDFileNameLocked;
extern MDFileProperty const MDFileIsPackage;
extern MDFileProperty const MDFileIsInvisible;
extern MDFileProperty const MDFileIsAliasFile;

@interface NSDictionary (MDFileAttributes)
- (NSInteger)fileLabelColor;	/**< files & folders	*/
- (BOOL)fileHasCustomIcon;		/**< files & folders	*/
- (BOOL)fileIsStationery;		/**< files only		*/
- (BOOL)fileNameLocked;			/**< files & folders	(value isn't used or respected by OS X) */
- (BOOL)fileIsPackage;			/**< folders only  (NOTE: maps to kHasBundle, which for files, means a 'BNDL' resource. As such, this is pretty much obsolete for files Mac in OS X) */
- (BOOL)fileIsInvisible;		/**< files & folders */
- (BOOL)fileIsAlias;			/**< files only		*/

@end

NS_ASSUME_NONNULL_END
