//
//  SGSScannerTests.m
//  SGSScannerTests
//
//  Created by Lee on 01/12/2017.
//  Copyright (c) 2017 Lee. All rights reserved.
//

@import XCTest;
#import "NSString+SGSRegex.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    NSString *nilStr = nil;
    XCTAssertFalse([nilStr isConsists7bitASCIICharacters], @"空字符串");
    XCTAssertFalse([@"" isConsists7bitASCIICharacters], @"空字符串");
    XCTAssertTrue([@"123abc!@#" isConsists7bitASCIICharacters], @"由ascii码组成");
    XCTAssertTrue([@"123abcABC!@#$%^&*()_+-=[]\\{}|;':\",./<>?~`" isConsists7bitASCIICharacters], @"由ascii码组成");
    XCTAssertFalse([@"123abc!@#【】" isConsists7bitASCIICharacters], @"包含非ascii码字符");
    XCTAssertFalse([@"123abc!@#😄" isConsists7bitASCIICharacters], @"包含非ascii码字符");
}

@end

