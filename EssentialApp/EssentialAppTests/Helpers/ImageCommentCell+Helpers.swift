//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeediOS

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
