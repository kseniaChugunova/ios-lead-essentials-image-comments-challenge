//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
	func test_map_createsViewModel() {
		let comments = uniqueImageComments()

		let viewModel = ImageCommentsPresenter.map(comments)

		XCTAssertEqual(viewModel.comments, comments)
	}
}

func uniqueImageComment() -> ImageComment {
	return ImageComment(id: UUID(), message: "a message", createdAt: Date(), authorUsername: "a username")
}

func uniqueImageComments() -> [ImageComment] {
	let models = [uniqueImageComment(), uniqueImageComment()]
	return models
}
