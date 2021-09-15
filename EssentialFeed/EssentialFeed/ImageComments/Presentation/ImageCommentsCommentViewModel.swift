//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsCommentViewModel {
	public let text: String?
	public let username: String?
	public let dateText: String?

	public init(text: String?, username: String?, date: Date) {
		self.text = text
		self.username = username
		let dateFormatter = RelativeDateTimeFormatter()
		self.dateText = dateFormatter.localizedString(for: date, relativeTo: Date())
	}

	public init(comment: ImageComment) {
		self.text = comment.message
		self.username = comment.author.username

		let dateFormatter = RelativeDateTimeFormatter()
		self.dateText = dateFormatter.localizedString(for: comment.createdAt, relativeTo: Date())
	}
}
