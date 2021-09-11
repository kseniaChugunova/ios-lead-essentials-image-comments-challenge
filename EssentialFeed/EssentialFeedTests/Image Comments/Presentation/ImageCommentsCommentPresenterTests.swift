//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

@testable import EssentialFeed

class ImageCommentsCommentPresenterTests: XCTestCase {
	func test_map_createsViewModel() {
		let comment = uniqueImageComment()

		let viewModel = ImageCommentsCommentPresenter.map(comment)

		XCTAssertEqual(viewModel.text, comment.message)
		XCTAssertEqual(viewModel.dateText, "5 days ago")
		XCTAssertEqual(viewModel.username, comment.author.username)
	}
}
