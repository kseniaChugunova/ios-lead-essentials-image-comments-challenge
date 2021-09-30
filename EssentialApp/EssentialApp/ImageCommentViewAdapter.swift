//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class ImageCommentViewAdapter: ResourceView {
	private weak var controller: ListViewController?

	init(controller: ListViewController) {
		self.controller = controller
	}

	func display(_ viewModel: ImageCommentsViewModel) {
		controller?.display(viewModel.comments.map { model in

			let view = ImageCommentCellController(
				viewModel: ImageCommentsCommentViewModel(comment: model),
				selection: {}
			)

			return CellController(id: model, view)
		})
	}
}
