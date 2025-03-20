//
//  ImportExtensionVTFNew.swift
//  Source Finagler
//
//  Created by C.W. Betts on 3/17/25.
//  Copyright © 2025 Mark Douma LLC. All rights reserved.
//

import Foundation
import CoreSpotlight
import VTF
import TextureKit.TKVTFImageRep

public class ImportExtensionVTFNew: CSImportExtension {
	public override func update(_ attributes: CSSearchableItemAttributeSet, forFileAt contentURL: URL) throws {
		let data = try Data(contentsOf: contentURL)
		
		guard data.count > MemoryLayout<OSType>.size else {
			throw CocoaError(.fileReadCorruptFile,
							 userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The file too small", comment: "[data length] < 4 for file"),
									   NSDebugDescriptionErrorKey: "[data length] < 4 for file",
													NSURLErrorKey: contentURL])
		}
		
		var magic: OSType = 0
		data.withUnsafeBytes { ptr in
			magic = ptr.load(as: OSType.self).bigEndian
		}
		
		guard magic != TKHTMLErrorMagic else {
			throw CocoaError(.fileReadCorruptFile, userInfo:
								[NSLocalizedDescriptionKey: NSLocalizedString("file appears to be an ERROR 404 HTML file rather than a valid VTF", comment: "file appears to be an ERROR 404 HTML file rather than a valid VTF"),
								NSDebugDescriptionErrorKey: "file appears to be an ERROR 404 HTML file rather than a valid VTF",
											 NSURLErrorKey: contentURL])
		}
		
		var file = VTFLib.CVTFFile()
		
		let success = data.withUnsafeBytes { urbp in
			file.Load(urbp.baseAddress!, vlUInt(urbp.count), true)
		}
		
		guard success else {
			if magic == TKVTFMagic {
				throw CocoaError(.fileReadCorruptFile, userInfo:
									[NSLocalizedDescriptionKey: NSLocalizedString("file->Load() failed!", comment: "file->Load() failed!"),
									NSDebugDescriptionErrorKey: "file->Load() failed!",
												 NSURLErrorKey: contentURL])
			} else {
				throw CocoaError(.fileReadCorruptFile, userInfo:
									[NSLocalizedDescriptionKey: String.localizedStringWithFormat(NSLocalizedString("file->Load() failed! (does not appear to be a valid VTF; magic == 0x%x, %@)", comment: "file->Load() failed! (does not appear to be a valid VTF;"), magic, NSFileTypeForHFSTypeCode(magic)),
									NSDebugDescriptionErrorKey: String(format: "file->Load() failed! (does not appear to be a valid VTF; magic == 0x%x, %@)", arguments: [magic, NSFileTypeForHFSTypeCode(magic)]),
												 NSURLErrorKey: contentURL])
			}
		}
		
		let isEnvironmentMap: Bool = (file.GetFaceCount() > 1)
		let hasAlphaChannel = VTFImageFlag(rawValue: file.GetFlags()).contains([.TEXTUREFLAGS_ONEBITALPHA, .TEXTUREFLAGS_EIGHTBITALPHA])
		let hasMipmaps: Bool = (file.GetMipmapCount() > 1)
		let isAnimated: Bool = (file.GetFrameCount() > 1)
		var compression: String? = nil
		let imageFormatInfo = VTFLib.CVTFFile.GetImageFormatInfo(file.GetFormat())
		if let imageFormatName = imageFormatInfo.pointee.lpName {
			compression = String(cString: imageFormatName)
		}
		
		let theWidth = file.GetWidth()
		let theHeight = file.GetHeight()
		let theVersion = "\(file.GetMajorVersion()).\(file.GetMinorVersion())"
		
		attributes.hasAlphaChannel = NSNumber(value: hasAlphaChannel)
		if let attrib = CSCustomAttributeKey(keyName: "com_markdouma_image_mipmaps") {
			attributes.setValue(NSNumber(value: hasMipmaps), forCustomKey: attrib)
		}
		if let attrib = CSCustomAttributeKey(keyName: "com_markdouma_image_animated") {
			attributes.setValue(NSNumber(value: isAnimated), forCustomKey: attrib)
		}
		
		if let attrib = CSCustomAttributeKey(keyName: "com_markdouma_image_environment_map") {
			attributes.setValue(NSNumber(value: isEnvironmentMap), forCustomKey: attrib)
		}

		attributes.pixelWidth = NSNumber(value: theWidth)
		attributes.pixelHeight = NSNumber(value: theHeight)
		if !theVersion.isEmpty {
			attributes.version = theVersion
		}
		if let compression = compression,
		   let attrib = CSCustomAttributeKey(keyName: "com_markdouma_image_compression") {
				attributes.setValue(compression as NSString, forCustomKey: attrib)
		}
	}
}
