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

	func test_loadCommentsAction_requestDataFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a reload")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}

	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let comment0 = makeComment(message: "a message", authorUsername: "a username")
		let comment1 = makeComment(message: "another message", authorUsername: "a long username")
		let comment2 = makeComment(message: "yet another long message", authorUsername: "another username")
		let comment3 = makeComment(message: "a long message", authorUsername: "yet another long username")

		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		let helper = ImageCommentsUIIntegrationTestsHelpers()

		helper.assertThat(sut, isRendering: [])
		loader.completeCommentsLoading(with: [comment0], at: 0)
		helper.assertThat(sut, isRendering: [comment0])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [comment0, comment1, comment2, comment3], at: 1)
		helper.assertThat(sut, isRendering: [comment0, comment1, comment2, comment3])
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

	func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyScreenAfterNonEmptyScreen() {
		let comment0 = makeComment()
		let comment1 = makeComment()
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		let helper = ImageCommentsUIIntegrationTestsHelpers()
		loader.completeCommentsLoading(with: [comment0, comment1], at: 0)
		helper.assertThat(sut, isRendering: [comment0, comment1])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [], at: 1)
		helper.assertThat(sut, isRendering: [])
	}

	func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment0 = makeComment()
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		let helper = ImageCommentsUIIntegrationTestsHelpers()
		loader.completeCommentsLoading(with: [comment0], at: 0)
		helper.assertThat(sut, isRendering: [comment0])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoadingWithError(at: 1)
		helper.assertThat(sut, isRendering: [comment0])
	}

	func test_tapOnErrorView_hidesErrorMessage() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)

		sut.simulateErrorViewTap()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	func test_loadingIndicator_isVisibleWhileLoading() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

		loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

		loader.completeCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	}

	func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()

		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeCommentsLoading(at: 0)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	func test_deinit_cancelsRunningRequests() {
		var cancelCallCount = 0
		var sut: ListViewController?

		autoreleasepool {
			sut = CommentsUIComposer.imageCommentsComposedWith(commentsLoader: {
				PassthroughSubject<[ImageComment], Error>()
					.handleEvents(receiveCancel: {
						cancelCallCount += 1
					}).eraseToAnyPublisher()
			})

			sut?.loadViewIfNeeded()
		}

		XCTAssertEqual(cancelCallCount, 0)

		sut = nil

		XCTAssertEqual(cancelCallCount, 1)
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

	private func makeComment(message: String = "message", authorUsername: String = "authorUsername") -> ImageComment {
		return ImageComment(id: UUID(), message: message, createdAt: Date(), authorUsername: authorUsername)
	}

	class LoaderSpy {
		var loadCommentsCallCount: Int {
			return commentsRequests.count
		}

		private var commentsRequests = [PassthroughSubject<[ImageComment], Error>]()

		func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
			let publisher = PassthroughSubject<[ImageComment], Error>()
			commentsRequests.append(publisher)
			return publisher.eraseToAnyPublisher()
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
