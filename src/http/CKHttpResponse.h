//
//  CKResponse.h
//	Based on code in ObjectiveResource
//
//  Created by Alan Johnson on 6/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CKHttpResponse : NSObject {
	NSData *body;
	NSDictionary *headers;
	NSInteger statusCode;
	NSError *error;
}

@property (nonatomic, retain) NSData *body;
@property (nonatomic, retain) NSDictionary *headers;
@property (assign, nonatomic) NSInteger statusCode;
@property (nonatomic, retain) NSError *error;

+ (id)responseFrom:(NSHTTPURLResponse *)response withBody:(NSData *)data andError:(NSError *)aError;
- (id)initFrom:(NSHTTPURLResponse *)response withBody:(NSData *)data andError:(NSError *)aError;
- (BOOL)isSuccess;
- (BOOL)isError;
- (void)log;
- (NSString *)utf8Body;

@end
