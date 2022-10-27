//
//  ThumbnailProvider.swift
//  SourceImageThumbnailer
//
//  Created by C.W. Betts on 10/27/22.
//  Copyright © 2022 Mark Douma LLC. All rights reserved.
//

import QuickLookThumbnailing
import TextureKit

class ThumbnailProvider: QLThumbnailProvider {
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
		do {
			let url = request.fileURL
			let resVals = try url.resourceValues(forKeys: [.contentTypeKey])
			guard let contentType = resVals.contentType else {
				// TODO: Better error thrown
				throw CocoaError(.featureUnsupported)
			}
			
			guard contentType == UTType(TKVTFType) || contentType == UTType(TKDDSType) || contentType == UTType(TKSFTextureImageType) else {
				let errorString = "SourceImageThumbnailer; provideThumbnail(for:_:): contentTypeUTI != VTF or DDS or SFTI; (contentTypeUTI == \(contentType.identifier)"

				throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: errorString, NSDebugDescriptionErrorKey: errorString])
			}
			
			let imageData = try Data(contentsOf: url)
			
			guard imageData.count >= 4 else {
				let errorString = "provideThumbnail(for:_:): data length < 4 for file == \(url.lastPathComponent)"
				
				throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: errorString, NSDebugDescriptionErrorKey: errorString])
			}
			
			do {
				let magic = imageData.withUnsafeBytes { urbp in
					urbp.load(as: OSType.self)
				}
				
				guard magic != TKHTMLErrorMagic else {
					let errorString = "File appears to be an ERROR 404 HTML file rather than a valid VTF"
					
					throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: errorString, NSDebugDescriptionErrorKey: errorString])
				}
			}
			
			var imageRef: CGImage? = nil
			if  contentType == UTType(TKVTFType) {
				imageRef = TKVTFImageRep(data: imageData)?.cgImage
			} else if contentType == UTType(TKDDSType) {
				imageRef = TKDDSImageRep(data: imageData)?.cgImage
			} else if contentType == UTType(TKSFTextureImageType) {
				if let tkImage = TKImage(data: imageData, firstRepresentationOnly: false) {
					var tkImageRep: TKImageRep? = nil
					if tkImage.sliceCount > 0 {
						// TODO: implement?
						
					} else if tkImage.faceCount > 0 && tkImage.frameCount > 0 {
						let aTKImageReps = tkImage.representations(forFace: tkImage.firstFaceIndexSet,
																   frameIndexes: tkImage.firstFrameIndexSet,
																   mipmapIndexes: tkImage.firstMipmapIndexSet)
						
						tkImageRep = aTKImageReps.first
					} else if tkImage.faceCount > 0 {
						let aTKImageReps = tkImage.representations(forFace: tkImage.firstFaceIndexSet,
																   mipmapIndexes: tkImage.firstMipmapIndexSet)
						
						tkImageRep = aTKImageReps.first
					} else if tkImage.frameCount > 0 {
						let aTKImageReps = tkImage.representations(forFrameIndexes: tkImage.firstFrameIndexSet,
																   mipmapIndexes: tkImage.firstMipmapIndexSet)
						
						tkImageRep = aTKImageReps.first
					} else {
						if tkImage.mipmapCount > 0 {
							tkImageRep = tkImage.representation(forMipmapIndex: 0)
						}
					}
					
					imageRef = tkImageRep?.cgImage
				}
			}

			guard let imageRef else {
				// TODO: Better error thrown
				throw CocoaError(.fileReadCorruptFile)
			}
			
			let theMaxImageSize = request.maximumSize
			var newSize = theMaxImageSize

			if CGFloat(imageRef.width) > theMaxImageSize.width || CGFloat(imageRef.height) > theMaxImageSize.height {
				if (newSize.width < newSize.height) {
					newSize.height = newSize.width
				} else {
					newSize.width = newSize.height
				}
				
				newSize.height = newSize.width * CGFloat(imageRef.height) / CGFloat(imageRef.width)
			}
			
			let reply = QLThumbnailReply(contextSize: newSize, drawing: { (context) -> Bool in
				var newImage = imageRef
				if theMaxImageSize != newSize, let a = MDCGImageCreateCopyWithSize(imageRef, newSize) {
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
