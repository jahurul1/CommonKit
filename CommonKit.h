/*
 *  CommonKit.h
 *
 *  Created by Alan Johnson on 7/4/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

// DLog and ALog from http://iphoneincubator.com/blog/debugging/the-evolution-of-a-replacement-for-nslog

// DLog is almost a drop-in replacement for NSLog
// DLog();
// DLog(@"here");
// DLog(@"value: %d", x);
// Unfortunately this doesn't work DLog(aStringVariable); you have to do this instead DLog(@"%@", aStringVariable);
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


// Imports for all of CommonKit

// categories
#import "NSData+Base64.h"

// http stuff
#import "CKHttpConnectionDelegate.h"
#import "CKHttp.h"
#import "CKHttpResponse.h"
