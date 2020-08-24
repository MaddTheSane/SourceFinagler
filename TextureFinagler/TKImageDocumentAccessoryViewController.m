//
//  TKImageDocumentAccessoryViewController.m
//  Texture Kit
//
//  Created by Mark Douma on 1/5/2011.
//  Copyright (c) 2010-2012 Mark Douma LLC. All rights reserved.
//

#import "TKImageDocumentAccessoryViewController.h"
#import "TKImageDocument.h"

#import <TextureKit/TextureKit.h>

#import "TKAppKitAdditions.h"



static NSString * const kTKUTTypeTGA = @"com.truevision.tga-image";
static NSString * const kTKUTTypePSD = @"com.adobe.photoshop-image";
static NSString * const kTKUTTypeOpenEXR = @"com.ilm.openexr-image";
static NSString * const kTKUTTypeSGI = @"com.sgi.sgi-image";


static NSString * const TKImageDocumentLastSavedFormatTypeKey		= @"TKImageDocumentLastSavedFormatType";

static NSString * const TKImageDocumentVTFFormatKey					= @"TKImageDocumentVTFFormat";
static NSString * const TKImageDocumentDDSFormatKey					= @"TKImageDocumentDDSFormat";
static NSString * const TKImageDocumentGenerateMipmapsKey			= @"TKImageDocumentGenerateMipmaps";

static NSString * const TKImageDocumentTIFFCompressionKey			= @"TKImageDocumentTIFFCompression";

static NSString * const TKImageDocumentJPEGQualityKey				= @"TKImageDocumentJPEGQuality";
static NSString * const TKImageDocumentJPEG2000QualityKey			= @"TKImageDocumentJPEG2000Quality";

static NSString * const TKImageDocumentSaveAlphaKey					= @"TKImageDocumentSaveAlpha";


static NSMutableDictionary<NSString*,NSString*> *displayNameAndUTITypes = nil;



#define TK_DEBUG 1



@implementation TKImageDocumentAccessoryViewController
@synthesize document;
@synthesize savePanel;
@synthesize image;
@synthesize imageUTType;
@synthesize vtfFormat;
@synthesize ddsFormat;
@synthesize compressionQuality;
@synthesize tiffCompression;
@synthesize jpegQuality;
@synthesize jpeg2000Quality;
@synthesize saveAlpha;
@synthesize generateMipmaps;


+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
		defaultValues[TKImageDocumentLastSavedFormatTypeKey] = TKSFTextureImageType;
		defaultValues[TKImageDocumentVTFFormatKey] = @([TKVTFImageRep defaultFormat]);
		defaultValues[TKImageDocumentDDSFormatKey] = @([TKDDSImageRep defaultFormat]);
		defaultValues[TKImageDocumentJPEGQualityKey] = @0.8;
		defaultValues[TKImageDocumentJPEG2000QualityKey] = @0.8;
		defaultValues[TKImageDocumentTIFFCompressionKey] = @(NSTIFFCompressionNone);
		defaultValues[TKImageDocumentSaveAlphaKey] = @YES;
		defaultValues[TKImageDocumentGenerateMipmapsKey] = @YES;
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	});
}

- (instancetype)init {
	return [self initWithImageDocument:nil];
}

- (instancetype)initWithImageDocument:(TKImageDocument *)aDocument {
	if ((self = [super initWithNibName:self.nibName bundle:nil])) {
		document = aDocument;
		self.image = document.image;
		
		self.imageUTType = [[NSUserDefaults standardUserDefaults] stringForKey:TKImageDocumentLastSavedFormatTypeKey];
		
		if (imageUTTypes == nil) imageUTTypes = [[document class] writableTypes];
		
		vtfFormat = [[NSUserDefaults standardUserDefaults] integerForKey:TKImageDocumentVTFFormatKey];
		ddsFormat = [[NSUserDefaults standardUserDefaults] integerForKey:TKImageDocumentDDSFormatKey];
		
		tiffCompression = [[NSUserDefaults standardUserDefaults] integerForKey:TKImageDocumentTIFFCompressionKey];
		
		jpegQuality = [[NSUserDefaults standardUserDefaults] doubleForKey:TKImageDocumentJPEGQualityKey];
		jpeg2000Quality = [[NSUserDefaults standardUserDefaults] doubleForKey:TKImageDocumentJPEG2000QualityKey];
		
		saveAlpha = [[NSUserDefaults standardUserDefaults] boolForKey:TKImageDocumentSaveAlphaKey];
		
		generateMipmaps = [[NSUserDefaults standardUserDefaults] boolForKey:TKImageDocumentGenerateMipmapsKey];
	}
	return self;
}


//- (void)dealloc {
////	document = nil;
////	savePanel = nil;
////	[imageUTType release];
////	[imageUTTypes release];
//	[super dealloc];
//}


- (void)cleanup {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	[mediator unbind:@"contentObject"];
	[mediator setContent:nil];
	
	document = nil;
	savePanel = nil;
}

- (NSString *)nibName {
	return @"TKImageDocumentAccessoryView";
}

- (void)awakeFromNib {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	@synchronized([self class]) {
		if (displayNameAndUTITypes == nil) {
			displayNameAndUTITypes = [[NSMutableDictionary alloc] init];
			
			for (NSString *aSaveType in imageUTTypes) {
				NSString *displayName = [[NSDocumentController sharedDocumentController] displayNameForType:aSaveType];
				if (displayName) displayNameAndUTITypes[displayName] = aSaveType;
			}
		}
	}
	
	
	NSArray *sortedDisplayNames = [displayNameAndUTITypes.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSMutableArray *menuItems = [NSMutableArray array];
	
	for (NSString *displayName in sortedDisplayNames) {
		NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:displayName action:NULL keyEquivalent:@""];
		if (menuItem) {
			[menuItems addObject:menuItem];
		}
	}
	[formatPopUpButton setItemArray:menuItems];
}

- (BOOL)prepareSavePanel:(NSSavePanel *)aSavePanel {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	self.savePanel = aSavePanel;
	savePanel.accessoryView = self.view;
	[self changeFormat:self];
	
	return YES;
}

// save accessory panel
- (IBAction)changeFormat:(id)sender {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	if (sender == self) {
		// if it's us, then we need to set the selected item to type saved in user defaults
		NSArray *keys = [displayNameAndUTITypes allKeysForObject:imageUTType];
		if (keys.count) {
			NSString *displayName = keys[0];
			[formatPopUpButton selectItemWithTitle:displayName];
		}
		[self setImageUTType:nil];
	}
	
	NSString *title = formatPopUpButton.titleOfSelectedItem;
	NSString *utiType = displayNameAndUTITypes[title];
	self.imageUTType = utiType;
	
	NSArray *filenameExtensions = [[NSDocumentController sharedDocumentController] fileExtensionsFromType:imageUTType];
	NSString *filenameExtension = nil;
	
	if (filenameExtensions.count) {
		filenameExtension = filenameExtensions[0];
		if (filenameExtension) savePanel.allowedFileTypes = @[filenameExtension, utiType];
	}
	
	if ([imageUTType isEqual:TKDDSType] ||
		[imageUTType isEqual:TKVTFType]) {
		
		
		if ([imageUTType isEqual:TKDDSType]) {
			
			compressionPopUpButton.menu = ddsMenu;
			[compressionPopUpButton selectItemWithTag:[compressionPopUpButton indexOfItemWithTag:ddsFormat]];
			
		} else {
			compressionPopUpButton.menu = vtfMenu;
			[compressionPopUpButton selectItemWithTag:[compressionPopUpButton indexOfItemWithTag:vtfFormat]];
		}
		
		compressionBox.contentView = compressionView;
		
	} else if ([imageUTType isEqual:(NSString *)kUTTypeJPEG]) {
		
		compressionBox.contentView = jpegQualityView;
		
	} else if ([imageUTType isEqual:(NSString *)kUTTypeJPEG2000]) {
		
		compressionBox.contentView = jpeg2000QualityView;
	
	} else if ([imageUTType isEqual:(NSString *)kUTTypeTIFF]) {

		compressionBox.contentView = tiffCompressionView;
		
	} else if ([imageUTType isEqual:(NSString *)kUTTypeBMP] ||
			   [imageUTType isEqual:(NSString *)kUTTypeAppleICNS] ||
			   [imageUTType isEqual:(NSString *)kUTTypeICO] ||
			   [imageUTType isEqual:kTKUTTypePSD] ||
			   [imageUTType isEqual:kTKUTTypeTGA] ||
			   [imageUTType isEqual:kTKUTTypeOpenEXR] ||
			   [imageUTType isEqual:(NSString *)kUTTypeGIF] ||
			   [imageUTType isEqual:(NSString *)kUTTypePDF] ||
			   [imageUTType isEqual:(NSString *)kUTTypePNG]) {
		
		compressionBox.contentView = alphaView;
	} else {
		compressionBox.contentView = blankView;
	}
}


- (IBAction)changeCompression:(id)sender {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	if ([imageUTType isEqual:TKDDSType]) {
		self.ddsFormat = compressionPopUpButton.selectedItem.tag;
	} else if ([imageUTType isEqual:TKVTFType]) {
		self.vtfFormat = compressionPopUpButton.selectedItem.tag;
	}
}

- (void)setNilValueForKey:(NSString *)key {
	if ([key isEqual:@"vtfFormat"]) {
		vtfFormat = [TKVTFImageRep defaultFormat];
		
	} else if ([key isEqual:@"ddsFormat"]) {
		ddsFormat = [TKDDSImageRep defaultFormat];
		
	} else if ([key isEqual:@"compressionQuality"]) {
		compressionQuality = [TKImageRep defaultDXTCompressionQuality];
		
	} else if ([key isEqual:@"tiffCompression"]) {
		tiffCompression = NSTIFFCompressionNone;
		
	} else if ([key isEqual:@"jpegQuality"]) {
		jpegQuality = 0.0;
		
	} else if ([key isEqual:@"jpeg2000Quality"]) {
		jpeg2000Quality = 0.0;
		
	} else if ([key isEqual:@"saveAlpha"]) {
		saveAlpha = NO;
		
	} else if ([key isEqual:@"generateMipmaps"]) {
		generateMipmaps = NO;
		
	} else if ([super respondsToSelector:@selector(setNilValueForKey:)]) {
		[super setNilValueForKey:key];
	}
}


- (void)saveDefaults {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:imageUTType forKey:TKImageDocumentLastSavedFormatTypeKey];
	[userDefaults setInteger:vtfFormat forKey:TKImageDocumentVTFFormatKey];
	[userDefaults setInteger:ddsFormat forKey:TKImageDocumentDDSFormatKey];
	[userDefaults setDouble:jpegQuality forKey:TKImageDocumentJPEGQualityKey];
	[userDefaults setDouble:jpeg2000Quality forKey:TKImageDocumentJPEG2000QualityKey];
	[userDefaults setInteger:tiffCompression forKey:TKImageDocumentTIFFCompressionKey];
	[userDefaults setBool:saveAlpha forKey:TKImageDocumentSaveAlphaKey];
	[userDefaults setBool:generateMipmaps forKey:TKImageDocumentGenerateMipmapsKey];
}


- (NSDictionary *)imageProperties {
#if TK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSMutableDictionary *imgProperties = [NSMutableDictionary dictionaryWithCapacity:3];
	
	BOOL imageHasAlpha = image.hasAlpha;
	
	if ([imageUTType isEqual:TKDDSType] || [imageUTType isEqual:TKVTFType]) {
		
		
	} else if ([imageUTType isEqual:(NSString *)kUTTypeJPEG]) {
		
		imgProperties[(id)kCGImageDestinationLossyCompressionQuality] = @(jpegQuality);
		if (imageHasAlpha && saveAlpha) imgProperties[(id)kCGImagePropertyHasAlpha] = @YES;
		
	} else if ([imageUTType isEqual:(NSString *)kUTTypeJPEG2000]) {
		
		imgProperties[(id)kCGImageDestinationLossyCompressionQuality] = @(jpeg2000Quality);
		if (imageHasAlpha && saveAlpha) imgProperties[(id)kCGImagePropertyHasAlpha] = @YES;
		
	} else if ([imageUTType isEqual:(NSString *)kUTTypeTIFF]) {
		
		imgProperties[(id)kCGImagePropertyTIFFDictionary] = [NSMutableDictionary dictionaryWithObjectsAndKeys:@(tiffCompression),(id)kCGImagePropertyTIFFCompression, nil];
		
		
	} else if ([imageUTType isEqual:(NSString *)kUTTypeBMP] ||
			   [imageUTType isEqual:(NSString *)kUTTypeAppleICNS] ||
			   [imageUTType isEqual:(NSString *)kUTTypeICO] ||
			   [imageUTType isEqual:(NSString *)kTKUTTypeTGA] ||
			   [imageUTType isEqual:(NSString *)kTKUTTypePSD] ||
			   [imageUTType isEqual:(NSString *)kTKUTTypeOpenEXR] ||
			   [imageUTType isEqual:(NSString *)kUTTypeGIF] ||
			   [imageUTType isEqual:(NSString *)kUTTypePDF] ||
			   [imageUTType isEqual:(NSString *)kUTTypePNG]) {
		
		if (imageHasAlpha && saveAlpha) imgProperties[(id)kCGImagePropertyHasAlpha] = @YES;
	}
	
	[self saveDefaults];
	
	return imgProperties;
}

@end
