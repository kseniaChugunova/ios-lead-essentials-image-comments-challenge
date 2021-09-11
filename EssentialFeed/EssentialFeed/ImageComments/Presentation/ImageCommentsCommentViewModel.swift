//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsCommentViewModel {
	public let text: String?
	public let username: String?
	public let dateText: String?

	init(comment: ImageComment) {
		self.text = comment.message
		self.username = comment.author.username

		let dateFormatter = RelativeDateTimeFormatter()
		self.dateText = dateFormatter.localizedString(for: comment.createdAt, relativeTo: Date())
	}
}
