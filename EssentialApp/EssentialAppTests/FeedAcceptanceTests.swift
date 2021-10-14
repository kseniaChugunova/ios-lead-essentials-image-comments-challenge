//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedAcceptanceTests: XCTestCase {
	func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
		let feed = launch(httpClient: .online(response), store: .empty)

		XCTAssertEqual(feed.numberOfRenderedCellViews(), 2)
		XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
	}

	func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
		let sharedStore = InMemoryFeedStore.empty
		let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
		onlineFeed.simulateFeedImageViewVisible(at: 0)
		onlineFeed.simulateFeedImageViewVisible(at: 1)

		let offlineFeed = launch(httpClient: .offline, store: sharedStore)

		XCTAssertEqual(offlineFeed.numberOfRenderedCellViews(), 2)
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
	}

	func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
		let feed = launch(httpClient: .offline, store: .empty)

		XCTAssertEqual(feed.numberOfRenderedCellViews(), 0)
	}

	func test_onEnteringBackground_deletesExpiredFeedCache() {
		let store = InMemoryFeedStore.withExpiredFeedCache

		enterBackground(with: store)

		XCTAssertNil(store.feedCache, "Expected to delete expired cache")
	}

	func test_onEnteringBackground_keepsNonExpiredFeedCache() {
		let store = InMemoryFeedStore.withNonExpiredFeedCache

		enterBackground(with: store)

		XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
	}

	func test_onSelectionFeedItem_displaysListOfCommentsWhenCustomerHasConnectivity() {
		let feed = launch(httpClient: .online(response), store: .empty)

		feed.simulateTapOnFeedImage(at: 0)

		RunLoop.current.run(until: Date())

		let commentsVC = feed.currentViewController()

		XCTAssertEqual(commentsVC.numberOfRenderedCellViews(), 2)

		let helper = ImageCommentsUIIntegrationTestsHelpers()
		helper.assertThat(commentsVC, isRendering: commentEntities)
	}

	// MARK: - Helpers

	private func launch(
		httpClient: HTTPClientStub = .offline,
		store: InMemoryFeedStore = .empty
	) -> ListViewController {
		let sut = SceneDelegate(httpClient: httpClient, store: store)
		sut.window = UIWindow()
		sut.configureWindow()

		let nav = sut.window?.rootViewController as? UINavigationController
		return nav?.topViewController as! ListViewController
	}

	private func enterBackground(with store: InMemoryFeedStore) {
		let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
		sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
	}

	private func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeData(for: url), response)
	}

	private func makeData(for url: URL) -> Data {
		switch url.path {
		case "/essential-feed/v1/image/2AB2AE66-A4B7-4A16-B374-51BBAC8DB086/comments":
			return makeCommentsResponse()

		case "/image-1", "/image-2":
			return makeImageData()

		case "/essential-feed/v1/feed":
			return makeFeedData()

		default:
			return Data()
		}
	}

	private lazy var date = Date()

	private lazy var commentEntities: [ImageComment] = {
		let message = "a message"
		let username = "a username"

		return [
			ImageComment(id: UUID(uuidString: "7019D8A7-0B35-4057-B7F9-8C5471961ED0")!,
			             message: message,
			             createdAt: date,
			             authorUsername: username),
			ImageComment(id: UUID(uuidString: "1F4A3B22-9E6E-46FC-BB6C-48B33269951B")!,
			             message: message,
			             createdAt: date,
			             authorUsername: username)
		]
	}()

	private func makeCommentsResponse() -> Data {
		let dateFormatter = ISO8601DateFormatter()
		let stringDate = dateFormatter.string(from: date)

		let comment1 = makeComment(uuid: "7019D8A7-0B35-4057-B7F9-8C5471961ED0", createdAt: stringDate)
		let comment2 = makeComment(uuid: "1F4A3B22-9E6E-46FC-BB6C-48B33269951B", createdAt: stringDate)

		return try! JSONSerialization.data(withJSONObject: ["items": [comment1, comment2]])
	}

	private func makeComment(uuid: String,
	                         message: String = "a message",
	                         createdAt: String,
	                         username: String = "a username") -> [String: Any] {
		return [
			"id": uuid,
			"message": message,
			"created_at": createdAt,
			"author": ["username": username]
		]
	}

	private func makeImageData() -> Data {
		return UIImage.make(withColor: .red).pngData()!
	}

	private func makeFeedData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086", "image": "http://feed.com/image-1"],
			["id": "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A", "image": "http://feed.com/image-2"]
		]])
	}
}
