//
//  CKHttpTests.m
//  CommonKit
//
//  Created by Alan Johnson on 7/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CKHttpTests.h"
#import "CKHttp.h"
#import "CKHttpResponse.h"

@implementation CKHttpTests

static NSString *testUrl = @"http://localhost:4567";

- (void) testGet {
	CKHttpResponse *response = [CKHttp get:[testUrl stringByAppendingString:@"/get"]];
	STAssertTrue([@"This is a test get." isEqual:[response utf8Body]], nil);
}

- (void) testPost {
	CKHttpResponse *response = [CKHttp post:[@"Alan" dataUsingEncoding:NSUTF8StringEncoding] 
										 to:[testUrl stringByAppendingString:@"/post"]];
	STAssertTrue([@"Post Alan!" isEqual:[response utf8Body]], nil);
}

- (void) testPut {
	CKHttpResponse *response = [CKHttp put:[@"Alan" dataUsingEncoding:NSUTF8StringEncoding] 
										 to:[testUrl stringByAppendingString:@"/put"]];
	STAssertTrue([@"Put Alan!" isEqual:[response utf8Body]], nil);
}

- (void) testDelete {
	CKHttpResponse *response = [CKHttp delete:[testUrl stringByAppendingString:@"/delete"]];
	STAssertTrue([@"Deleted!" isEqual:[response utf8Body]], nil);
}

@end
