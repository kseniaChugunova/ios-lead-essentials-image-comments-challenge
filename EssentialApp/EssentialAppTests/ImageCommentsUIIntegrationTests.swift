//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialApp
import EssentialFeediOS
import EssentialFeed
import Combine

class ImageCommentsUIIntegrationTests: XCTestCase {
	func test_commentsiew_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, imageCommentsTitle)
	}

	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let comment0 = makeComment(message: "a message", createdAt: Date(), authorUsername: "a username")
		let comment1 = makeComment(message: "another message", createdAt: Date(), authorUsername: "a long username")
		let comment2 = makeComment(message: "yet another long message", createdAt: Date(), authorUsername: "another username")
		let comment3 = makeComment(message: "a long message", createdAt: Date(), authorUsername: "yet another long username")

		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		loader.completeCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [comment0, comment1, comment2, comment3], at: 1)
		assertThat(sut, isRendering: [comment0, comment1, comment2, comment3])
	}

	func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment0 = makeComment(message: "a message", createdAt: Date(), authorUsername: "a username")
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment0])
	}

	// MARK: - Helpers

	private func makeSUT(
		selection: @escaping (ImageComment) -> Void = { _ in },
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: ListViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()

		let sut = CommentsUIComposer.imageCommentsComposedWith(commentsLoader: loader.loadPublisher)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	private func makeComment(message: String, createdAt: Date, authorUsername: String) -> ImageComment {
		return ImageComment(id: UUID(), message: message, createdAt: createdAt, authorUsername: authorUsername)
	}

	class LoaderSpy: ImageCommentsDataLoader {
		private struct TaskSpy: ImageCommentsDataLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}

		func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
			let publisher = PassthroughSubject<[ImageComment], Error>()
			commentsRequests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}

		private var commentsRequests = [PassthroughSubject<[ImageComment], Error>]()

		func loadImageCommentData(from url: URL, completion: @escaping (ImageCommentsDataLoader.Result) -> Void) -> ImageCommentsDataLoaderTask {
			return TaskSpy(cancelCallback: {})
		}

		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			commentsRequests[index].send(comments)
		}

		func completeCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			commentsRequests[index].send(completion: .failure(error))
		}
	}
}

extension ImageCommentCell {
	var messageText: String? {
		descriptionLabel.text
	}

	var usernameText: String? {
		return usernameLabel.text
	}

	var dateText: String? {
		return dateLabel.text
	}
}
