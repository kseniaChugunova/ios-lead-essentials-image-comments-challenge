//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsMapper {
	private struct Root: Decodable {
		private let items: [RemoteImageCommentItem]

		private struct RemoteImageCommentItem: Decodable {
			let id: UUID
			let message: String
			let created_at: Date
			let author: Author

			struct Author: Decodable {
				let username: String
			}
		}

		var images: [ImageComment] {
			items.map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, authorUsername: $0.author.username) }
		}
	}

	public enum Error: Swift.Error {
		case invalidData
	}

	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		guard let root = try? decoder.decode(Root.self, from: data), isOk(response) else {
			throw Error.invalidData
		}

		return root.images
	}

	private static func isOk(_ response: HTTPURLResponse) -> Bool {
		(200 ... 299).contains(response.statusCode)
	}
}
