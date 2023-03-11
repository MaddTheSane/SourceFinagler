//
//  MDFolderManager.h
//  Font Finagler
//
//  Created by Mark Douma on 11/16/2006.
//  Copyright © 2006-2011 Mark Douma. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

#ifndef _CS_DARWIN_USER_CACHE_DIR	/* provided so compiler doesn't balk when using 10.3.9 or 10.4u SDKs */
#define	_CS_DARWIN_USER_CACHE_DIR		65538
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(FSVolumeRefNum, MDSearchPathDomain) {
	/** ~/ */
	MDUserDomain NS_SWIFT_NAME(user)		=	kUserDomain,
	/** /Library/ */
	MDLocalDomain NS_SWIFT_NAME(local)		=	kLocalDomain,
	/** /Network/ */
	MDNetworkDomain NS_SWIFT_NAME(network)	=	kNetworkDomain,
	/** /System/ */
	MDSystemDomain NS_SWIFT_NAME(system)	=	kSystemDomain,
	/** /System Folder/ (no longer applicable) */
	MDClassicDomain NS_SWIFT_NAME(classic)	=	kClassicDomain,
	/** varies */
	MDAllDomains NS_SWIFT_NAME(all)			=	kOnAppropriateDisk
};

typedef NS_ENUM(OSType, MDSearchPathDirectory) {
	MDApplicationsDirectory				=	kApplicationsFolderType,
	MDApplicationSupportDirectory		=	kApplicationSupportFolderType,
	MDCachesDirectory					=	kCachedDataFolderType,
	MDDesktopDirectory					=	kDesktopFolderType,
	MDDocumentsDirectory				=	kDocumentsFolderType,
	MDDownloadsDirectory				=	kDownloadsFolderType,
	MDFontCollectionsDirectory			=	kFontCollectionsFolderType,
	MDFontsDirectory					=	kFontsFolderType,
	MDFontsDisabledDirectory			=	'MDfD',
	MDHomeDirectory						=	kCurrentUserFolderType,
	MDLibraryDirectory					=	kDomainLibraryFolderType,
	MDLogsDirectory						=	kLogsFolderType,
	MDMoviesDirectory					=	kMovieDocumentsFolderType,
	MDMusicDirectory					=	kMusicDocumentsFolderType,
	MDPicturesDirectory					=	kPictureDocumentsFolderType,
	MDPreferencesDirectory				=	kPreferencesFolderType,
	MDQuickTimeComponentsDirectory		=	kQuickTimeComponentsFolderType,
	MDSoundsDirectory					=	kSystemSoundsFolderType,
	MDTemporaryDirectory				=	kTemporaryFolderType,
	MDTrashDirectory					=	kTrashFolderType,
	MDUsersDirectory					=	kUsersFolderType,
	MDDarwinUserCachesDirectory			=	'MDdc',
	MDQuickLookDirectory				=	kQuickLookFolderType,
	MDServicesDirectory					=	kServicesFolderType,
	MDColorSyncProfileDirectory			=	kColorSyncProfilesFolderType,
	MDScreenSaversDirectory				=	kScreenSaversFolderType,
	MDPreferencePanesDirectory			=	kPreferencePanesFolderType,
};


@interface MDFolderManager : NSObject {
	NSMutableArray	*tempDirectories;
}
@property (class, readonly, retain) MDFolderManager *defaultManager;
+ (nullable NSString *)tempDirectoryWithIdentifier:(nullable NSString *)aName;
+ (nullable NSString *)tempDirectoryWithIdentifier:(nullable NSString *)aName assureUniqueFilename:(BOOL)flag;
+ (BOOL)cleanupTempDirectoryAtPath:(NSString *)aPath error:(NSError *__nullable*__nullable)outError;

- (nullable NSString *)tempDirectoryWithIdentifier:(nullable NSString *)aName;
- (nullable NSString *)tempDirectoryWithIdentifier:(nullable NSString *)aName assureUniqueFilename:(BOOL)flag;
- (BOOL)cleanupTempDirectoryAtPath:(NSString *)aPath error:(NSError *__nullable*__nullable)outError;

- (nullable NSString *)pathForDirectory:(MDSearchPathDirectory)aDirectory inDomain:(MDSearchPathDomain)aDomain error:(NSError *__nullable*__nullable)outError;
- (nullable NSString *)pathForDirectory:(MDSearchPathDirectory)aDirectory inDomain:(MDSearchPathDomain)aDomain create:(BOOL)create error:(NSError *__nullable*__nullable)outError;

- (nullable NSURL *)URLForDirectory:(MDSearchPathDirectory)aDirectory inDomain:(MDSearchPathDomain)aDomain error:(NSError *__nullable*__nullable)outError;
- (nullable NSURL *)URLForDirectory:(MDSearchPathDirectory)aDirectory inDomain:(MDSearchPathDomain)aDomain create:(BOOL)create error:(NSError *__nullable*__nullable)outError;

- (nullable NSString *)pathForDirectory:(MDSearchPathDirectory)aDirectory forItemAtPath:(NSString *)aPath error:(NSError *__nullable*__nullable)outError;
- (nullable NSString *)pathForDirectory:(MDSearchPathDirectory)aDirectory forItemAtPath:(NSString *)aPath create:(BOOL)create error:(NSError *__nullable*__nullable)outError;

- (nullable NSString *)pathForDirectoryWithName:(NSString *)aName inDirectory:(MDSearchPathDirectory)aDirectory inDomain:(MDSearchPathDomain)aDomain error:(NSError *__nullable*__nullable)outError;
- (nullable NSString *)pathForDirectoryWithName:(NSString *)aName inDirectory:(MDSearchPathDirectory)aDirectory inDomain:(MDSearchPathDomain)aDomain create:(BOOL)create error:(NSError *__nullable*__nullable)outError;

@end

NS_ASSUME_NONNULL_END

