
#if !os(watchOS)
import XCTest
#endif

import EinsteinTests

var tests = [XCTestCaseEntry]()
tests += EinsteinTests.allTests()
XCTMain(tests)
