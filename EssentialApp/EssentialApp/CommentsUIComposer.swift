//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

public final class CommentsUIComposer {
	private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], ImageCommentViewAdapter>

	public static func imageCommentsComposedWith(
		commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
	) -> ListViewController {
		let adapter = CommentsPresentationAdapter(loader: commentsLoader)

		let imageCommentsController = makeImageCommentsViewController(title: ImageCommentsPresenter.title)
		imageCommentsController.onRefresh = adapter.loadResource

		adapter.presenter = LoadResourcePresenter(resourceView: ImageCommentViewAdapter(controller: imageCommentsController),
		                                          loadingView: WeakRefVirtualProxy(imageCommentsController),
		                                          errorView: WeakRefVirtualProxy(imageCommentsController),
		                                          mapper: ImageCommentsPresenter.map)
		return imageCommentsController
	}

	private static func makeImageCommentsViewController(title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ListViewController
		controller.title = title
		return controller
	}
}
