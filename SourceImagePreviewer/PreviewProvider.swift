//
//  PreviewProvider.swift
//  SourceImageThumbnailer
//
//  Created by C.W. Betts on 10/27/22.
//  Copyright © 2022 Mark Douma LLC. All rights reserved.
//

import Cocoa
import Quartz
import UniformTypeIdentifiers
import TextureKit

class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
		let url = request.fileURL
		let resVals = try url.resourceValues(forKeys: [.contentTypeKey])
		guard let contentType = resVals.contentType else {
			// TODO: Better error thrown
			throw CocoaError(.featureUnsupported)
		}
		
		let data = try Data(contentsOf: url, options: [.mappedIfSafe])
		
		var imageRef: CGImage? = nil
		if  contentType == UTType(TKVTFType) {
			imageRef = TKVTFImageRep(data: data)?.cgImage
		} else if contentType == UTType(TKDDSType) {
			imageRef = TKDDSImageRep(data: data)?.cgImage
		} else if contentType == UTType(TKSFTextureImageType) {
			if let tkImage = TKImage(data: data, firstRepresentationOnly: false) {
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

		let imageSize = CGSize(width: imageRef.width, height: imageRef.height)
		
		let reply = QLPreviewReply.init(contextSize: imageSize, isBitmap: true) { context, reply in
			context.saveGState()
			context.draw(imageRef, in: CGRect(origin: .zero, size: imageSize))
			context.restoreGState()
		}
        return reply
    }
}
