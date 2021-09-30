//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension ImageCommentsUIIntegrationTests {
	func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()

		guard sut.numberOfRenderedCellViews() == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedCellViews()) instead.", file: file, line: line)
		}

		comments.enumerated().forEach { index, image in
			assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
		}

		executeRunLoopToCleanUpReferences()
	}

	func assertThat(_ sut: ListViewController, hasViewConfiguredFor comment: ImageComment, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.cellView(at: index)
		let viewModel = ImageCommentsCommentViewModel(comment: comment)

		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.messageText, viewModel.text, "Expected comment text to be \(String(describing: viewModel.text)) for comment view at index (\(index))", file: file, line: line)

		XCTAssertEqual(cell.usernameText, viewModel.username, "Expected username text to be \(String(describing: viewModel.username)) for comment view at index (\(index)", file: file, line: line)
		XCTAssertEqual(cell.dateText, viewModel.dateText, "Expected date text to be \(String(describing: viewModel.dateText)) for comment view at index (\(index)", file: file, line: line)
	}

	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
}
