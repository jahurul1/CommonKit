//
//  CKConnectionDelegate.m
//	Based on code in ObjectiveResource
//
//  Created by Alan Johnson on 6/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CKHttpConnectionDelegate.h"

@implementation CKHttpConnectionDelegate

@synthesize response, data, error, connection;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.data = [NSMutableData data];
		done = NO;
	}
	return self;
}

- (BOOL) isDone {
	return done;
}

- (void) cancel {
	[connection cancel];
	self.response = nil;
	self.data = nil;
	self.error = nil;
	done = YES;
}

#pragma mark NSURLConnectionDelegate methods
- (NSURLRequest *)connection:(NSURLConnection *)aConnection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([challenge previousFailureCount] > 0) {
		[[challenge sender] cancelAuthenticationChallenge:challenge];
	}
	else {
		[[challenge sender] useCredential:[challenge proposedCredential] forAuthenticationChallenge:challenge];
	}
}
- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	done = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse {
	self.response = aResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)someData {
	[data appendData:someData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	done = YES;
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)aError {
	self.error = aError;
	done = YES;
}

//don't cache resources for now
- (NSCachedURLResponse *)connection:(NSURLConnection *)aConnection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}


#pragma mark cleanup
- (void) dealloc
{
	[data release];
	[response release];
	[error release];
	[connection release];
	[super dealloc];
}

@end
