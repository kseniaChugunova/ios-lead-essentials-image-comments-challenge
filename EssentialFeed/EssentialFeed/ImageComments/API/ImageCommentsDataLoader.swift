//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsDataLoaderTask {
	func cancel()
}

public protocol ImageCommentsDataLoader {
	typealias Result = Swift.Result<Data, Error>
}
