//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsCommentPresenter {
	public static func map(_ comment: ImageComment) -> ImageCommentsCommentViewModel {
		ImageCommentsCommentViewModel(comment: comment)
	}
}
