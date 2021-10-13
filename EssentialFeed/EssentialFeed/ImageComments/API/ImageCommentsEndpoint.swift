//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public enum ImageCommentsEndpoint {
	case imageComments(imageId: String)

	public func url(baseURL: URL) -> URL {
		switch self {
		case .imageComments(let imageId):
			return baseURL.appendingPathComponent("/v1/image/\(imageId)/comments")
		}
	}
}
