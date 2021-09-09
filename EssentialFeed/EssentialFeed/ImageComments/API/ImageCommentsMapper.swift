//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsMapper {
	public enum Error: Swift.Error {
		case invalidResponse
	}

	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Any] {
		guard response.isOK else {
			throw Error.invalidResponse
		}

		return []
	}
}
