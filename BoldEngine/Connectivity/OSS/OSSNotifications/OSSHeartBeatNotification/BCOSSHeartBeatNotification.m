//
//  BCOSSHeartBeatNotification.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/31/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSHeartBeatNotification.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSHeartBeatNotification

@synthesize delegate = _delegate;

- (BOOL)processMessage:(NSDictionary *)message {
    if ([message[@"method"] isEqualToString:@"heartbeat"]) {
        
        NSString *messageId = [message[@"id"] bcNilOrStringValue];
        if (messageId) {
            [self.delegate ossHeartBeatNotification:self didReceiveWithId:messageId];
        } else {
            [self.delegate ossHeartBeatNotification:self didReceiveWithId:@"0"];
        }
        return YES;
    } else {
        return NO;
    }
}

@end
