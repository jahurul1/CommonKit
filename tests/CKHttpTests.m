//
//  CKHttpTests.m
//  CommonKit
//
//  Created by Alan Johnson on 7/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommonKit.h"
#import "CKHttpTests.h"
#import "CKHttp.h"
#import "CKHttpResponse.h"

@implementation CKHttpTests

static NSString *testUrl = @"http://localhost:4567";

- (void) testGet {
	CKHttpResponse *response = [CKHttp get:[testUrl stringByAppendingString:@"/get"]];
	STAssertTrue([@"This is a test get." isEqual:[response utf8Body]], nil);
}

- (void) testGetWithParams {
	CKHttpResponse *response = [CKHttp get:[testUrl stringByAppendingString:@"/get?name=Alan"]];
	STAssertTrue([@"Hello Alan!" isEqual:[response utf8Body]], nil);
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

- (void) testRequestTimeout {
	[CKHttp setTimeout:1];
	CKHttpResponse *response = [CKHttp get:[testUrl stringByAppendingString:@"/slow"]];
	STAssertTrue([response isError], @"Didn't time out like it should have.");
	[CKHttp setTimeout:5];
}

- (void) testBasicAuth {
	[CKHttp setUsername:@"alan"];
	[CKHttp setPassword:@"so rad!"];
	CKHttpResponse *response = [CKHttp get:[testUrl stringByAppendingString:@"/basicauth"]];
	STAssertTrue([@"alan => so rad!" isEqual:[response utf8Body]], nil);
	[CKHttp clearCredentials];
}

- (void) testSettingContentType {
	[CKHttp setContentType:@"application/json"];
	CKHttpResponse *response = [CKHttp get:[testUrl stringByAppendingString:@"/contenttype"]];
	STAssertEquals(200, [response statusCode], nil);
	STAssertTrue([@"application/json" isEqual:[response utf8Body]], nil);
	[CKHttp setContentType:nil];
}

@end
