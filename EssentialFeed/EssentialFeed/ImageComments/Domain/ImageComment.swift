//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Hashable {
	public struct Author: Hashable {
		let username: String
	}

	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let author: Author

	public init(id: UUID, message: String, createdAt: Date, authorUsername: String) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = Author(username: authorUsername)
	}
}
