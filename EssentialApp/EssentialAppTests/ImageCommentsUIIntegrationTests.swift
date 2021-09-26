//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialApp
import EssentialFeediOS
import EssentialFeed

class ImageCommentsUIIntegrationTests: XCTestCase {
	func test_commentsiew_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, imageCommentsTitle)
	}

	// MARK: - Helpers

	private func makeSUT(
		selection: @escaping (ImageComment) -> Void = { _ in },
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: ListViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()

		let sut = CommentsUIComposer.imageCommentsComposedWith()
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	class LoaderSpy: ImageCommentsDataLoader {
		private struct TaskSpy: ImageCommentsDataLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}

		func loadImageData(from url: URL, completion: @escaping (ImageCommentsDataLoader.Result) -> Void) -> ImageCommentsDataLoaderTask {
			return TaskSpy(cancelCallback: {})
		}
	}
}
