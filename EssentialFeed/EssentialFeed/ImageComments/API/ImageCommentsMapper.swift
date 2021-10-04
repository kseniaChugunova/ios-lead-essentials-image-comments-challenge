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
			let createdAt: Date
			let author: Author

			struct Author: Decodable {
				let username: String
			}
		}

		var images: [ImageComment] {
			items.map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.createdAt, authorUsername: $0.author.username) }
		}
	}

	public enum Error: Swift.Error {
		case invalidResponse
		case invalidData
	}

	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
		guard response.isOK else {
			throw Error.invalidResponse
		}

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		guard let root = try? decoder.decode(Root.self, from: data) else {
			throw Error.invalidResponse
		}

		return root.images
	}
}
