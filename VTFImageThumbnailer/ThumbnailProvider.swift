//
//  ThumbnailProvider.swift
//  SourceImageThumbnailer
//
//  Created by C.W. Betts on 10/27/22.
//  Copyright © 2022 Mark Douma LLC. All rights reserved.
//

import QuickLookThumbnailing
import TextureKit

public class ThumbnailProvider: QLThumbnailProvider {
    public override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
		do {
			let url = request.fileURL
			let imageData = try Data(contentsOf: url)
			
			guard imageData.count >= 4 else {
				let errorString = "provideThumbnail(for:_:): data length < 4 for file == \(url.lastPathComponent)"
				
				throw CocoaError(.fileReadCorruptFile, userInfo:
									[NSLocalizedDescriptionKey: errorString,
									NSDebugDescriptionErrorKey: errorString,
												 NSURLErrorKey: url])
			}
			
			do {
				let magic = imageData.withUnsafeBytes { urbp in
					urbp.load(as: OSType.self).bigEndian
				}
				
				guard magic != TKHTMLErrorMagic else {
					let errorString = "File appears to be an ERROR 404 HTML file rather than a valid VTF"
					
					throw CocoaError(.fileReadCorruptFile, userInfo:
										[NSLocalizedDescriptionKey: errorString,
										NSDebugDescriptionErrorKey: errorString,
													 NSURLErrorKey: url])
				}
			}
			
			guard let imageRef = TKVTFImageRep(data: imageData)?.cgImage else {
				// TODO: Better error thrown
				throw CocoaError(.fileReadCorruptFile)
			}
			
			let theMaxImageSize = request.maximumSize
			var newSize = theMaxImageSize

			if CGFloat(imageRef.width) > theMaxImageSize.width || CGFloat(imageRef.height) > theMaxImageSize.height {
				if newSize.width < newSize.height {
					newSize.height = newSize.width
				} else {
					newSize.width = newSize.height
				}
				
				newSize.height = newSize.width * CGFloat(imageRef.height) / CGFloat(imageRef.width)
			}
			
			let reply = QLThumbnailReply(contextSize: newSize, drawing: { (context) -> Bool in
				var newImage = imageRef
				if theMaxImageSize != newSize,
				   let a = MDCGImageCreateCopyWithSize(imageRef, newSize) {
					newImage = a
				}
				context.draw(newImage, in: CGRect(origin: .zero, size: newSize))
				
				// Return true if the thumbnail was successfully drawn inside this block.
				return true
			})
			handler(reply, nil)
		} catch {
			handler(nil, error)
		}
    }
}
