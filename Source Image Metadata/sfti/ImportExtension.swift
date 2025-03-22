//
//  ImportExtension.swift
//  sfti Metadata
//
//  Created by C.W. Betts on 10/30/22.
//  Copyright © 2022 Mark Douma LLC. All rights reserved.
//

import Foundation
import CoreSpotlight
import TextureKit

class ImportExtension : CSImportExtension {
	override func update(_ attributes: CSSearchableItemAttributeSet, forFileAt contentURL: URL) throws {
		let data = try Data(contentsOf: contentURL)
		
		guard let sfti = TKImage(data: data, firstRepresentationOnly: false) else {
			throw CocoaError(.fileReadCorruptFile, userInfo:
								[NSLocalizedDescriptionKey: "Failed to create a TKImage for file!",
								NSDebugDescriptionErrorKey: "Failed to create a TKImage for file!",
											 NSURLErrorKey: contentURL])
		}
		let imageSize = sfti.size
		
		attributes.hasAlphaChannel = NSNumber(value: sfti.hasAlpha)
		if let customAttrib = CSCustomAttributeKey(keyName: "com_markdouma_image_mipmaps") {
			attributes.setValue(NSNumber(value: sfti.hasMipmaps), forCustomKey: customAttrib)
		}
		if let customAttrib = CSCustomAttributeKey(keyName: "com_markdouma_image_animated") {
			attributes.setValue(NSNumber(value: sfti.isAnimated), forCustomKey: customAttrib)
		}
		
		if let customAttrib = CSCustomAttributeKey(keyName: "com_markdouma_image_environment_map") {
			attributes.setValue(NSNumber(value: sfti.isCubemap || sfti.isSpheremap), forCustomKey: customAttrib)
		}

		attributes.pixelWidth = NSNumber(value: Int(imageSize.width))
		attributes.pixelHeight = NSNumber(value: Int(imageSize.height))
		attributes.pixelCount = Int(imageSize.width * imageSize.height) as NSNumber
	}
}
