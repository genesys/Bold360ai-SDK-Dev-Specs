//
//  BCOSSConnectNotification.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/31/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSConnectNotification.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSConnectNotification

@synthesize delegate = _delegate;

- (BOOL)processMessage:(NSDictionary *)message {
    if ([message[@"method"] isEqualToString:@"connect"]) {
        [self.delegate ossConnectNotificationDidConnect:self];
        return YES;
    } else if ([message[@"method"] isEqualToString:@"redirect"]) {
        NSArray *paramsArray = message[@"params"];
        NSDictionary *paramsDict = paramsArray.count > 0 ? paramsArray[0] : nil;
        NSString *redirectUrl = nil;
        if (paramsDict) {
            redirectUrl = [paramsDict[@"WebSocketURL"] bcNilOrStringValue];
        }
        [self.delegate ossConnectNotification:self didRedirectToUrl:redirectUrl];
        return YES;
    } else if ([message[@"method"] isEqualToString:@"reconnect"]) {
        [self.delegate ossConnectNotificationDidReconnect:self];
        return YES;
    } else if ([message[@"method"] isEqualToString:@"reset"]) {
        [self.delegate ossConnectNotificationDidReset:self];
        return YES;
    } else if ([message[@"method"] isEqualToString:@"closed"]) {
        [self.delegate ossConnectNotificationDidClose:self];
        return YES;
    } else {
        return NO;
    }
}

@end
