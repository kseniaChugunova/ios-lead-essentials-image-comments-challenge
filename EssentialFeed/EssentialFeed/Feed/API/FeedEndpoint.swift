//
// Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public enum FeedEndpoint {
	case get
	case imageComments(imageId: String)

	public func url(baseURL: URL) -> URL {
		switch self {
		case .get:
			return baseURL.appendingPathComponent("/v1/feed")
		case .imageComments(let imageId):
			return baseURL.appendingPathComponent("/v1/image/\(imageId)/comments")
		}
	}
}
