//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public final class ImageCommentCellController: NSObject {
	private let viewModel: ImageCommentsCommentViewModel
	private let selection: () -> Void
	private var cell: ImageCommentCell?

	public init(viewModel: ImageCommentsCommentViewModel, selection: @escaping () -> Void) {
		self.viewModel = viewModel
		self.selection = selection
	}
}

extension ImageCommentCellController: UITableViewDataSource, UITableViewDelegate {
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		1
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		cell?.usernameLabel.text = viewModel.username
		cell?.dateLabel.text = viewModel.dateText
		cell?.descriptionLabel.text = viewModel.text
		return cell!
	}

	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selection()
	}

	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		releaseCellForReuse()
	}

	private func releaseCellForReuse() {
		cell = nil
	}
}
