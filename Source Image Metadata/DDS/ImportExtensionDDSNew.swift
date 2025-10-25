//
//  ImportExtensionDDSNew.swift
//  Source Finagler
//
//  Created by C.W. Betts on 10/25/25.
//  Copyright © 2025 Mark Douma LLC. All rights reserved.
//

import CoreSpotlight
import TextureKit.TKDDSImageRep
import NVCore.Stream
import NVImage.DirectDrawSurface

public class ImportExtensionDDSNew : CSImportExtension {
	
	public override func update(_ attributes: CSSearchableItemAttributeSet, forFileAt contentURL: URL) throws {
		let handle = try FileHandle(forReadingFrom: contentURL)
		guard let data = try handle.read(upToCount: 4) else {
			throw CocoaError(.fileReadCorruptFile, userInfo:
								[NSLocalizedDescriptionKey: NSLocalizedString("File is too small", comment: "File is too small"),
								NSDebugDescriptionErrorKey: "[data length] < 4 for file",
											 NSURLErrorKey: contentURL])
		}
		guard data.count >= 4 else {
			throw CocoaError(.fileReadCorruptFile, userInfo:
								[NSLocalizedDescriptionKey: NSLocalizedString("File is too small", comment: "File is too small"),
								NSDebugDescriptionErrorKey: "[data length] < 4 for file",
											 NSURLErrorKey: contentURL])
		}
		
		let magic: OSType = data.withUnsafeBytes { ptr in
			return ptr.load(as: OSType.self).bigEndian
		}
		guard magic == TKDDSMagic else {
			throw CocoaError(.fileReadCorruptFile, userInfo:
								[NSLocalizedDescriptionKey: String.localizedStringWithFormat(NSLocalizedString("file does not appear to be a valid DDS; magic == 0x%x, %@", comment: "file does not appear to be a valid DDS; magic == 0x%x, %@"), magic, NSFileTypeForHFSTypeCode(magic)),
								NSDebugDescriptionErrorKey: String(format: "file does not appear to be a valid DDS; magic == 0x%x, %@", magic, NSFileTypeForHFSTypeCode(magic)),
											 NSURLErrorKey: contentURL])
		}
		
		var dds = nv.DirectDrawSurface()
		_=contentURL.withUnsafeFileSystemRepresentation { ubp in
			dds.load(ubp)
		}
		try? handle.close()
		
		if !dds.isValid() || !dds.isSupported() || (dds.width() > 65535 || (dds.height() > 65535)) {
			if (!dds.isValid()) {
//				dds.printInfo()
				throw CocoaError(.fileReadCorruptFile, userInfo:
									[NSLocalizedDescriptionKey: NSLocalizedString("dds image is not valid", comment: "dds image is not valid"),
									NSDebugDescriptionErrorKey: "dds image is not valid",
												 NSURLErrorKey: contentURL])
				
			} else if (!dds.isSupported()) {
//				dds.printInfo()
				throw CocoaError(.fileReadCorruptFile, userInfo:
									[NSLocalizedDescriptionKey: NSLocalizedString("dds image format is not supported", comment: "dds image format is not supported"),
									NSDebugDescriptionErrorKey: "dds image format is not supported",
												 NSURLErrorKey: contentURL])
			} else {
//				dds.printInfo()
				throw CocoaError(.fileReadTooLarge, userInfo:
									[NSLocalizedDescriptionKey: NSLocalizedString("dds image dimensions are too large", comment: "dds image dimensions are too large"),
									NSDebugDescriptionErrorKey: "dds image dimensions are too large",
												 NSURLErrorKey: contentURL])
			}
		}
		
#if MD_DEBUG
		dds.printInfo()
#endif
		
		let hasAlphaChannel: Bool = dds.hasAlpha()
		let hasMipmaps: Bool = (dds.mipmapCount() > 1)
		let isEnvironmentMap: Bool = dds.isTextureCube()

		
		var theCompression: String? = nil
		if let compression = dds.header.d3d9FormatString() {
			theCompression = String(cString: compression)
		}
		
		let theWidth = dds.width()
		let theHeight = dds.height()
		
		attributes.hasAlphaChannel = NSNumber(value: hasAlphaChannel)
		if let customKey = CSCustomAttributeKey(keyName: "com_markdouma_image_mipmaps") {
			attributes.setValue(NSNumber(value: hasMipmaps), forCustomKey: customKey)
		}
		
		// only set environment mask if it's true?
		if let customKey = CSCustomAttributeKey(keyName: "com_markdouma_image_environment_map") {
			attributes.setValue(NSNumber(value: isEnvironmentMap), forCustomKey: customKey)
		}

		attributes.pixelWidth = NSNumber(value: theWidth)
		attributes.pixelHeight = NSNumber(value: theHeight)
		attributes.pixelCount = NSNumber(value: Int64(theWidth * theHeight))
		if let theCompression,
		   let customKey = CSCustomAttributeKey(keyName: "com_markdouma_image_compression") {
			attributes.setValue(theCompression as NSString, forCustomKey: customKey)
		}
	}
}
