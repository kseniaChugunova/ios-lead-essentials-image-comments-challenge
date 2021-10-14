//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsCommentPresenter {
	public static func map(_ comment: ImageComment) -> ImageCommentViewModel {
		let text = comment.message
		let username = comment.authorUsername

		let dateFormatter = RelativeDateTimeFormatter()
		let dateText = dateFormatter.localizedString(for: comment.createdAt, relativeTo: Date())

		return ImageCommentViewModel(id: comment.id.uuidString, text: text, dateText: dateText, username: username)
	}
}
