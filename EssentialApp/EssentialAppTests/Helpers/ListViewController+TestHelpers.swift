//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
	public override func loadViewIfNeeded() {
		super.loadViewIfNeeded()

		tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
	}

	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}

	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}

	func simulateErrorViewTap() {
		errorView.simulateTap()
	}

	var errorMessage: String? {
		return errorView.message
	}

	func numberOfRows(in section: Int) -> Int {
		tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
	}

	func cell(row: Int, section: Int) -> UITableViewCell? {
		guard numberOfRows(in: section) > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: section)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
}

extension ListViewController {
	@discardableResult
	func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
		return cellView(at: index) as? FeedImageCell
	}

	@discardableResult
	func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
		let view = simulateFeedImageViewVisible(at: row)

		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: cellsSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

		return view
	}

	func simulateTapOnFeedImage(at row: Int) {
		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: cellsSection)
		delegate?.tableView?(tableView, didSelectRowAt: index)
	}

	func simulateFeedImageViewNearVisible(at row: Int) {
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: cellsSection)
		ds?.tableView(tableView, prefetchRowsAt: [index])
	}

	func simulateFeedImageViewNotNearVisible(at row: Int) {
		simulateFeedImageViewNearVisible(at: row)

		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: cellsSection)
		ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
	}

	func renderedFeedImageData(at index: Int) -> Data? {
		return simulateFeedImageViewVisible(at: index)?.renderedImage
	}

	func numberOfRenderedCellViews() -> Int {
		numberOfRows(in: cellsSection)
	}

	func cellView(at row: Int) -> UITableViewCell? {
		cell(row: row, section: cellsSection)
	}

	func currentViewController() -> ListViewController {
		let nav = navigationController
		return nav?.topViewController as! ListViewController
	}

	private var cellsSection: Int { 0 }
}
