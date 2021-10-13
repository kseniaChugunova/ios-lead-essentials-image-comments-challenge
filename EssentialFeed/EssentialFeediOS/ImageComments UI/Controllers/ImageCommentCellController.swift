//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public final class ImageCommentCellController: NSObject {
	private let viewModel: ImageCommentViewModel

	public init(viewModel: ImageCommentViewModel) {
		self.viewModel = viewModel
	}
}

extension ImageCommentCellController: UITableViewDataSource, UITableViewDelegate {
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		1
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		cell.usernameLabel.text = viewModel.username
		cell.dateLabel.text = viewModel.dateText
		cell.descriptionLabel.text = viewModel.text
		return cell
	}
}
