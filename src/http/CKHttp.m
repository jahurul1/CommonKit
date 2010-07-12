//
//  CKHttp.m
//	Shamelessly ripped from ObjectiveResource
//
//  Created by Alan Johnson on 6/17/10.
//  Copyright 2010 Gnoso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonKit.h"
#import "CKHttp.h"
#import "CKHttpConnectionDelegate.h"
#import "CKHttpResponse.h"
#import "NSData+Base64.h"

@implementation CKHttp

static NSTimeInterval timeoutInterval = 5.0;
static NSString *user;
static NSString *pass;
static NSString *contentTypeValue;
static NSMutableArray *activeDelegates;

+ (NSMutableArray *)activeDelegates {
	if (nil == activeDelegates) {
		activeDelegates = [NSMutableArray array];
		[activeDelegates retain];
	}
	return activeDelegates;
}

+ (void)setTimeout:(NSTimeInterval)timeOut {
	timeoutInterval = timeOut;
}
+ (NSTimeInterval)timeout {
	return timeoutInterval;
}

+ (void)setUsername:(NSString *)username {
	user = username;
}
+ (NSString *)username {
	return user;
}
+ (void)setPassword:(NSString *)password {
	pass = password;
}
+ (NSString *)password {
	return pass;
}
+ (void)clearCredentials {
	user = nil;
	pass = nil;
}
+ (void)setContentType:(NSString *)contentType {
	contentTypeValue = contentType;
}
+ (NSString *)contentType {
	return contentTypeValue;
}


+ (void)logRequest:(NSURLRequest *)request to:(NSString *)url {
	DLog(@"%@ -> %@", [request HTTPMethod], url);
	if([request HTTPBody]) {
		DLog(@"%@", [[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] autorelease]);
	}
}

+ (CKHttpResponse *)sendRequest:(NSMutableURLRequest *)request {
	
	NSURL *url = [request URL];
	
	DLog(@"%@", url);
	
	[self logRequest:request to:[url absoluteString]];
	
	CKHttpConnectionDelegate *connectionDelegate = [[[CKHttpConnectionDelegate alloc] init] autorelease];
	
	[[self activeDelegates] addObject:connectionDelegate];
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate startImmediately:NO] autorelease];
	connectionDelegate.connection = connection;
	
	[[UIApplication sharedApplication]	setNetworkActivityIndicatorVisible:YES];
	
	//use a custom runloop
	static NSString *runLoopMode = @"net.commondream.commonkit.http.connectionLoop";
	[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:runLoopMode];
	[connection start];
	while (![connectionDelegate isDone]) {
		[[NSRunLoop currentRunLoop] runMode:runLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.3]];
	}
	CKHttpResponse *resp = [CKHttpResponse responseFrom:(NSHTTPURLResponse *)connectionDelegate.response 
									   withBody:connectionDelegate.data 
									   andError:connectionDelegate.error];
	[resp log];
	
	[[UIApplication sharedApplication]	setNetworkActivityIndicatorVisible:NO];
	
	[activeDelegates removeObject:connectionDelegate];
	
	//if there are no more active delegates release the array
	if (0 == [activeDelegates count]) {
		NSMutableArray *tempDelegates = activeDelegates;
		activeDelegates = nil;
		[tempDelegates release];
	}
	
	return resp;
}

+ (CKHttpResponse *)sendBy:(NSString *)method withBody:(NSData *)body to:(NSString *)path {
	NSMutableURLRequest * request;
	NSURL * url;
	
	url = [NSURL URLWithString:path];
	
	NSString *authString = [[[NSString stringWithFormat:@"%@:%@",[self username], [self password]] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
	NSString *escapedUser = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																				(CFStringRef)[self username], NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
	NSString *escapedPassword = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																					(CFStringRef)[self password], NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@://%@:%@@%@",[url scheme],escapedUser,escapedPassword,[url host],nil];
	if([url port]) {
		[urlString appendFormat:@":%@",[url port],nil];
	}
	[urlString appendString:[url path]];
	if([url query]){
		[urlString appendFormat:@"?%@",[url query],nil];
	}
	
	request = [[NSMutableURLRequest alloc] init];
	[request setTimeoutInterval:[self timeout]];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:method];
	[request addValue:[NSString stringWithFormat:@"Basic %@", authString] forHTTPHeaderField:@"Authorization"]; 

	[escapedUser release];
	[escapedPassword release];
	
	
	if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) {
		[request setHTTPBody:body];
		[request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
	}
	
	if ([self contentType] != nil) {
		[request setValue:[self contentType] forHTTPHeaderField:@"Content-Type"];
	}
	
	return [self sendRequest:request];
}

+ (CKHttpResponse *)post:(NSData *)body to:(NSString *)url {
	return [self sendBy:@"POST" withBody:body to:url];
}

+ (CKHttpResponse *)put:(NSData *)body to:(NSString *)url {
	return [self sendBy:@"PUT" withBody:body to:url];
}

+ (CKHttpResponse *)get:(NSString *)url {
	return [self sendBy:@"GET" withBody:nil to:url];
}

+ (CKHttpResponse*)delete:(NSString *)url {
	return [self sendBy:@"DELETE" withBody:nil to:url];
}

@end
