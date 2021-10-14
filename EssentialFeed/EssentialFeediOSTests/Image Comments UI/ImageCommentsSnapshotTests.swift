//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
	func test_commentsWithContent() {
		let sut = makeSUT()

		let commentViewModels = commentsWithContent()

		let cellControllers: [CellController] = commentViewModels.map { model in
			let cellController = ImageCommentCellController(viewModel: model)
			return CellController(id: UUID(), cellController)
		}

		sut.display(cellControllers)

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "COMMENTS_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "COMMENTS_WITH_CONTENT_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "COMMENTS_WITH_CONTENT_light_extraExtraExtraLarge")
	}

	func test_commentsWithFailedImageLoading() {
		let sut = makeSUT()

		sut.display(ResourceErrorViewModel(message: "any"))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "COMMENTS_WITH_FAILED_LOADING_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "COMMENTS_WITH_FAILED_LOADING_dark")
	}

	// MARK: - Helpers

	private func makeSUT() -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ListViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}

	private func commentsWithContent() -> [ImageCommentViewModel] {
		return [
			ImageCommentViewModel(
				id: "7019D8A7-0B35-4057-B7F9-8C5471961ED0",
				text: "The gallery was seen in Wolfgang Becker's movie Goodbye, Lenin!",
				dateText: "5 days ago",
				username: "Joe"
			),
			ImageCommentViewModel(
				id: "1F4A3B22-9E6E-46FC-BB6C-48B33269951B",
				text: "It was also featured in English indie/rock band Bloc Party's single Kreuzberg taken from the album A Weekend in the City.",
				dateText: "2 weeks ago",
				username: "Meghan"
			)
		]
	}
}
