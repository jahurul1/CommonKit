//
//  CKHttp.h
//	Based on code in ObjectiveResource
//	
//
//  Created by Alan Johnson on 6/17/10.
//  Copyright 2010 Gnoso. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKHttpResponse;

@interface CKHttp : NSObject 

+ (void) setTimeout:(NSTimeInterval)timeout;
+ (NSTimeInterval) timeout;
+ (void)setUsername:(NSString *)username;
+ (NSString *)username;
+ (void)setPassword:(NSString *)password;
+ (NSString *)password;
+ (void)clearCredentials;
+ (void)setContentType:(NSString *)contentType;
+ (NSString *)contentType;
	
+ (CKHttpResponse *)sendRequest:(NSMutableURLRequest *)request;
+ (CKHttpResponse *)sendBy:(NSString *)method withBody:(NSData *)body to:(NSString *)path;

+ (CKHttpResponse *)post:(NSData *)body to:(NSString *)url;
+ (CKHttpResponse *)put:(NSData *)body to:(NSString *)url;
+ (CKHttpResponse *)get:(NSString *)url;
+ (CKHttpResponse *)delete:(NSString *)url;

@end
