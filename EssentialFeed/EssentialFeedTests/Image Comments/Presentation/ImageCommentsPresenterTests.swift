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

func uniqueImageComment() -> ImageComment {
	return ImageComment(id: UUID(), message: "a message", createdAt: Date().adding(days: -5), authorUsername: "a username")
}

func uniqueImageComments() -> ([ImageComment], [ImageCommentViewModel]) {
	let comments = [uniqueImageComment(), uniqueImageComment()]

	let models = comments.map { ImageCommentsCommentPresenter.map($0) }

	return (comments, models)
}
