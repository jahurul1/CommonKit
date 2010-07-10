//
//  CKConnectionDelegate.h
//	Based on code in ObjectiveResource
//
//  Created by Alan Johnson on 6/17/10.
//

#import <Foundation/Foundation.h>


@interface CKHttpConnectionDelegate : NSObject {
	NSMutableData *data;
	NSURLResponse *response;
	BOOL done;
	NSError *error;
	NSURLConnection *connection;
}

- (BOOL) isDone;
- (void) cancel;

@property(nonatomic, retain) NSURLResponse *response;
@property(nonatomic, retain) NSMutableData *data;
@property(nonatomic, retain) NSError *error;
@property(nonatomic, retain) NSURLConnection *connection;

@end
