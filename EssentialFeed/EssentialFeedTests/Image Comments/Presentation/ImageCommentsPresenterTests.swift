//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("COMMENTS_VIEW_TITLE"))
	}

	func test_map_createsViewModel() {
		let comments = uniqueImageComments()

		let viewModel = ImageCommentsPresenter.map(comments.0)

		XCTAssertEqual(viewModel.comments, comments.1)
	}

	// MARK: - Helpers

	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}

func uniqueImageComment(id: UUID) -> ImageComment {
	return ImageComment(id: id, message: "a message", createdAt: Date().adding(days: -5), authorUsername: "a username")
}

func uniqueImageComments() -> ([ImageComment], [ImageCommentViewModel]) {
	let id1 = UUID(uuidString: "7019D8A7-0B35-4057-B7F9-8C5471961ED0")!
	let id2 = UUID(uuidString: "1F4A3B22-9E6E-46FC-BB6C-48B33269951B")!

	let comments = [uniqueImageComment(id: id1), uniqueImageComment(id: id2)]

	let models = [
		ImageCommentViewModel(
			id: id1.uuidString,
			text: "a message",
			dateText: "5 days ago",
			username: "a username"
		),
		ImageCommentViewModel(
			id: id2.uuidString,
			text: "a message",
			dateText: "5 days ago",
			username: "a username"
		)
	]

	return (comments, models)
}
