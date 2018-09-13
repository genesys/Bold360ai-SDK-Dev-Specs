//
//  BCPingChatCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/14/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCPingChatCall.h"
#import "BCPingChatCallParser.h"

@interface BCPingChatCall () <BCRESTCallDelegate>

@end

@implementation BCPingChatCall

@synthesize chatKey = _chatKey;
@synthesize closed = _closed;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"pingChat";
    self.restCall.parser = [[BCPingChatCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    paramsDictionary[@"ChatKey"] = self.chatKey;
    paramsDictionary[@"Closed"] = self.closed ? @"true" : @"false";
    
    self.restCall.params = paramsDictionary;
    
    [self.restCall start];
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcPingChatCall:self didFinishWithResult:(BCPingChatCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcPingChatCall:self didFinishWithError:error];
}

@end
