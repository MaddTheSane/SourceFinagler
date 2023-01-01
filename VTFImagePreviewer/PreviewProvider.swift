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
		
		let data = try Data(contentsOf: url, options: [.mappedIfSafe])
		
		guard let imageRef = TKVTFImageRep(data: data)?.cgImage else {
			throw CocoaError(.fileReadCorruptFile, userInfo: [NSURLErrorKey: url])
		}

		let imageSize = CGSize(width: imageRef.width, height: imageRef.height)
		
		let reply = QLPreviewReply(contextSize: imageSize, isBitmap: true) { context, reply in
			context.saveGState()
			context.draw(imageRef, in: CGRect(origin: .zero, size: imageSize))
			context.restoreGState()
		}
        return reply
    }
}
