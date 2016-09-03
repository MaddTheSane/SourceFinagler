//
//  MDInspectorController.m
//  Source Finagler
//
//  Created by Mark Douma on 1/28/2008.
//  Copyright © 2008 Mark Douma. All rights reserved.
//



#import "MDInspectorController.h"
#import "TKAppController.h"

#import "MDHLDocument.h"

#import "TKAppKitAdditions.h"

#import <HLKit/HLKit.h>


//#define MD_DEBUG 1
#define MD_DEBUG 0


@implementation MDInspectorController


- (instancetype)init {
	if ((self = [super initWithWindowNibName:@"MDInspector"])) {
		
	} else {
		[NSBundle runFailedNibLoadAlert:@"MDInspector"];
	}
	return self;
}


- (void)dealloc {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}



- (void)awakeFromNib {
	[(NSPanel *)self.window setBecomesKeyOnlyIfNeeded:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedItemsDidChange:) name:MDSelectedItemsDidChangeNotification object:nil];
}


- (void)selectedItemsDidChange:(NSNotification *)notification {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	NSArray *newSelectedItems = notification.userInfo[MDSelectedItemsKey];
	MDHLDocument *newDocument = notification.userInfo[MDSelectedItemsDocumentKey];
	
	if (newDocument && newSelectedItems) {
		
		if (newSelectedItems.count == 0) {
			self.window.representedFilename = newDocument.fileURL.path;
			self.window.title = [newDocument.displayName stringByAppendingString:NSLocalizedString(@" Info", @"")];
			
			previewViewController.representedObject = newDocument;
			
			nameField.stringValue = newDocument.displayName;
			whereField.stringValue = newDocument.fileURL.path;
			
			NSImage *fileIcon = [[NSWorkspace sharedWorkspace] iconForFile:newDocument.fileURL.path];
			iconImageView.image = fileIcon;
			
			headerSizeField.objectValue = [newDocument fileSize];
			dateModifiedField.objectValue = newDocument.fileModificationDate;
			
			
			kindField.stringValue = newDocument.kind;
			sizeField.objectValue = [newDocument fileSize];
			
			
		} else if (newSelectedItems.count == 1) {
			
			HKItem *item = newSelectedItems[0];
			
			self.window.representedFilename = @"";
			self.window.title = [item.name stringByAppendingString:NSLocalizedString(@" Info", @"")];
			
			previewViewController.representedObject = item;
			
			kindField.stringValue = item.kind;
			
			NSImage *image = [HKItem copiedImageForItem:item];

			image.size = NSMakeSize(32.0, 32.0);
			iconImageView.image = image;
			
			nameField.stringValue = item.name;
//			NSString *path = [[[newDocument fileURL] path] stringByAppendingPathComponent:[[item path] stringByDeletingLastPathComponent]]
			whereField.stringValue = [newDocument.fileURL.path stringByAppendingPathComponent:item.path.stringByDeletingLastPathComponent];
			
			headerSizeField.objectValue = item.size;
			dateModifiedField.objectValue = newDocument.fileModificationDate;
			sizeField.objectValue = item.size;
			
		} else if (newSelectedItems.count > 1) {
			
			self.window.representedFilename = @"";
			[self.window setTitle:NSLocalizedString(@"Multiple Item Info", @"")];
			
			[previewViewController setRepresentedObject:nil];
			
			whereField.stringValue = newDocument.fileURL.path;
						
			nameField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"%lu items", @""), (unsigned long)newSelectedItems.count];
			
			unsigned long long totalSize = 0;
			
			for (HKItem *item in newSelectedItems) {
				if (item.leaf) {
					totalSize += item.size.unsignedLongLongValue;
				}
			}
			
			sizeField.objectValue = @(totalSize);
			headerSizeField.objectValue = @(totalSize);
			
			kindField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"%lu documents", @""), (unsigned long)newSelectedItems.count];
			
			iconImageView.image = [NSImage imageNamed:@"multipleItems"];
			
			dateModifiedField.objectValue = newDocument.fileModificationDate;
			
		}
		
	} else {
		/* a document is being closed, so set stuff to an intermediary "--" */
		
		self.window.representedFilename = @"";
		
		[self.window setTitle:NSLocalizedString(@"Info", @"")];
		
		[previewViewController setRepresentedObject:nil];
		
		iconImageView.image = [NSImage imageNamed:@"genericDocument32"];
		
		[nameField setStringValue:NSLocalizedString(@"--", @"")];
		[headerSizeField setStringValue:NSLocalizedString(@"--", @"")];
		[dateModifiedField setStringValue:NSLocalizedString(@"--", @"")];
		
		[kindField setStringValue:NSLocalizedString(@"--", @"")];
		[sizeField setStringValue:NSLocalizedString(@"--", @"")];
		[whereField setStringValue:NSLocalizedString(@"--", @"")];
		
		
	}
	
}


- (IBAction)showWindow:(id)sender {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	MDShouldShowInspector = YES;
	[self.window orderFront:nil];
	[[NSUserDefaults standardUserDefaults] setObject:@(MDShouldShowInspector) forKey:MDShouldShowInspectorKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:MDShouldShowInspectorDidChangeNotification object:self userInfo:nil];
}


- (void)windowWillClose:(NSNotification *)notification {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	if (notification.object == self.window) {
		MDShouldShowInspector = NO;
		[[NSUserDefaults standardUserDefaults] setObject:@(MDShouldShowInspector) forKey:MDShouldShowInspectorKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:MDShouldShowInspectorDidChangeNotification object:self userInfo:nil];
	}
}



@end


