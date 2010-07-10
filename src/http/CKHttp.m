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

static float timeoutInterval = 5.0;
static NSMutableArray *activeDelegates;

+ (NSMutableArray *)activeDelegates {
	if (nil == activeDelegates) {
		activeDelegates = [NSMutableArray array];
		[activeDelegates retain];
	}
	return activeDelegates;
}

+ (void)setTimeout:(float)timeOut {
	timeoutInterval = timeOut;
}
+ (float)timeout {
	return timeoutInterval;
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

+ (CKHttpResponse *)sendBy:(NSString *)method withBody:(NSData *)body to:(NSString *)path withParameters:(NSDictionary *)parameters {
	NSMutableURLRequest * request;
	NSURL * url;
	
	url = [NSURL URLWithString:path];
	
	NSString * user = @"";
	NSString * password = @"";
	NSString *authString = [[[NSString stringWithFormat:@"%@:%@",user, password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
	NSString *escapedUser = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																				(CFStringRef)user, NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
	NSString *escapedPassword = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																					(CFStringRef)password, NULL, (CFStringRef)@"@.:", kCFStringEncodingUTF8);
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@://%@:%@@%@",[url scheme],escapedUser,escapedPassword,[url host],nil];
	if([url port]) {
		[urlString appendFormat:@":%@",[url port],nil];
	}
	[urlString appendString:[url path]];
	if([url query]){
		[urlString appendFormat:@"?%@",[url query],nil];
	}
	
	request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:method];
	[request addValue:[NSString stringWithFormat:@"Basic %@", authString] forHTTPHeaderField:@"Authorization"]; 

	[escapedUser release];
	[escapedPassword release];
	
	
	if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) {
		[request setHTTPBody:body];
		[request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
        [request setValue:[NSString stringWithFormat:@"application/%@", @"json"] forHTTPHeaderField:@"Content-Type"];
	}
	return [self sendRequest:request];
}

+ (CKHttpResponse *)post:(NSData *)body to:(NSString *)url {
	return [self sendBy:@"POST" withBody:body to:url withParameters:nil];
}

+ (CKHttpResponse *)put:(NSData *)body to:(NSString *)url {
	return [self sendBy:@"PUT" withBody:body to:url withParameters:nil];
}

+ (CKHttpResponse *)get:(NSString *)url {
	return [self sendBy:@"GET" withBody:nil to:url withParameters:nil];
}

+ (CKHttpResponse *)get:(NSString *)url withParameters:(NSDictionary *)parameters {
	return [self sendBy:@"GET" withBody:nil to:url withParameters:parameters];
}

+ (CKHttpResponse*)delete:(NSString *)url {
	return [self sendBy:@"DELETE" withBody:nil to:url withParameters:nil];
}

@end
