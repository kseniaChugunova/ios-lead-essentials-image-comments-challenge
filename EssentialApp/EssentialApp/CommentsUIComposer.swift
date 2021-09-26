//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import Foundation
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
	public static func imageCommentsComposedWith() -> ListViewController {
		let imageCommentsController = makeImageCommentsViewController(title: ImageCommentsPresenter.title)
		return imageCommentsController
	}

	private static func makeImageCommentsViewController(title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ListViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		controller.title = title
		return controller
	}
}
