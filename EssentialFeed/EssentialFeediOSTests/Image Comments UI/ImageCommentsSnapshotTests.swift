//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
	func test_commentsWithContent() {
		let sut = makeSUT()

		sut.display(commentsWithContent())

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

	private func commentsWithContent() -> [ImageCommentStub] {
		return [
			ImageCommentStub(
				description: "The gallery was seen in Wolfgang Becker's movie Goodbye, Lenin!",
				username: "Joe",
				date: Date().adding(days: -5)
			),
			ImageCommentStub(
				description: "It was also featured in English indie/rock band Bloc Party's single Kreuzberg taken from the album A Weekend in the City.",
				username: "Meghan",
				date: Date().adding(days: -14)
			)
		]
	}
}

private extension ListViewController {
	func display(_ stubs: [ImageCommentStub]) {
		let cells: [CellController] = stubs.map { stub in
			let cellController = ImageCommentCellController(viewModel: stub.viewModel, selection: {})
			stub.controller = cellController
			return CellController(id: UUID(), cellController)
		}

		display(cells)
	}
}

private class ImageCommentStub {
	let viewModel: ImageCommentsCommentViewModel
	weak var controller: ImageCommentCellController?

	init(description: String?, username: String?, date: Date) {
		self.viewModel = ImageCommentsCommentViewModel(text: description, username: username, date: date)
	}
}
