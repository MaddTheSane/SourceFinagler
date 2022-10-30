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
		
		attributes.hasAlphaChannel = NSNumber(booleanLiteral: sfti.hasAlpha)
		if let customAttrib = CSCustomAttributeKey(keyName: "com_markdouma_image_mipmaps") {
			attributes.setValue(NSNumber(booleanLiteral: sfti.hasMipmaps), forCustomKey: customAttrib)
		}
		if let customAttrib = CSCustomAttributeKey(keyName: "com_markdouma_image_animated") {
			attributes.setValue(NSNumber(booleanLiteral: sfti.isAnimated), forCustomKey: customAttrib)
		}
		
		if let customAttrib = CSCustomAttributeKey(keyName: "com_markdouma_image_environment_map") {
			attributes.setValue(NSNumber(booleanLiteral: sfti.isCubemap || sfti.isSpheremap), forCustomKey: customAttrib)
		}

		attributes.pixelWidth = Int(imageSize.width) as NSNumber
		attributes.pixelHeight = Int(imageSize.height) as NSNumber
		attributes.pixelCount = Int(imageSize.width * imageSize.height) as NSNumber
	}
}
