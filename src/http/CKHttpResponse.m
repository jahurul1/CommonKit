//
//  CKResponse.m
//	Based on code in ObjectiveResource
//
//  Created by Alan Johnson on 6/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommonKit.h"

@implementation CKHttpResponse

@synthesize body, headers, statusCode, error;

+ (id)responseFrom:(NSHTTPURLResponse *)response withBody:(NSData *)data andError:(NSError *)aError {
	return [[[self alloc] initFrom:response withBody:data andError:aError] autorelease];
}

- (void)normalizeError:(NSError *)aError withBody:(NSData *)data{
	switch ([aError code]) {
		case NSURLErrorUserCancelledAuthentication:
			self.statusCode = 401;
			//self.error = [NSHTTPURLResponse buildResponseError:401 withBody:data];
			break;
		default:
			self.error = aError;
			break;
	}
}

- (id)initFrom:(NSHTTPURLResponse *)response withBody:(NSData *)data andError:(NSError *)aError {
	[self init];
	self.body = data;
	if(response) {
		self.statusCode = [response statusCode];
		self.headers = [response allHeaderFields];
		//self.error = [response errorWithBody:data];
	}
	else {
		[self normalizeError:aError withBody:data];
	}
	return self;
}

- (BOOL)isSuccess {
	return statusCode >= 200 && statusCode < 400;
}

- (BOOL)isError {
	return ![self isSuccess];
}

- (void)log {
	if ([self isSuccess]) {
		DLog(@"%d <= %@", statusCode, [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease]);
	}
	else {
		DLog(@"%d <= %@", statusCode, [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease]);
	}
}

- (NSString *)utf8Body {
	return [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
}

#pragma mark cleanup

- (void) dealloc
{
	[body release];
	[headers release];
	[super dealloc];
}

@end
