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

	func test_onTapOnFeedItem_displaysListOfCommentsWhenCustomerHasConnectivity() {
		let feed = launch(httpClient: .online(response), store: .empty)

		feed.simulateTapOnFeedImage(at: 0)

		let nav = feed.navigationController
		let comments = nav?.topViewController as! ListViewController

		XCTAssertEqual(comments.numberOfRenderedCellViews(), 2)
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
		case "/essential-feed/v1/image/11E123D5-1272-4F17-9B91-F3D0FFEC895A/comments":
			return makeComments()
            
		case "/image-1", "/image-2":
			return makeImageData()

		case "/essential-feed/v1/feed":
			return makeFeedData()

		default:
			return Data()
		}
	}

	private func makeComments() -> Data {
		let comm1 = makeComment(uuid: UUID().uuidString,
		                        message: "a message",
		                        createdAt: Date(),
		                        username: "a username")
		let comment1 = makeComment(uuid: UUID().uuidString,
		                           message: "another message",
		                           createdAt: Date(),
		                           username: "a long username")

		return try! JSONSerialization.data(withJSONObject: ["items": [comment1, comm1]])
	}

	private func makeComment(uuid: String, message: String, createdAt: Date, username: String) -> [String: Any] {
		let dateFormatter = ISO8601DateFormatter()
		let stringDate = dateFormatter.string(from: createdAt)
		return [
			"id": uuid,
			"message": message,
			"created_at": stringDate,
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
