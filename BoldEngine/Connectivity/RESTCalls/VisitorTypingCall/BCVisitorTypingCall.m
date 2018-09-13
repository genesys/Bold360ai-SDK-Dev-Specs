//
//  BCVisitorTypingCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/2/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCVisitorTypingCall.h"
#import "BCVisitorTypingCallParser.h"

@interface BCVisitorTypingCall () <BCRESTCallDelegate>

@end

@implementation BCVisitorTypingCall

@synthesize chatKey = _chatKey;
@synthesize isTyping = _isTyping;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"visitorTyping";
    self.restCall.parser = [[BCVisitorTypingCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    paramsDictionary[@"ChatKey"] = self.chatKey;
    paramsDictionary[@"IsTyping"] = self.isTyping ? @"true" : @"false";
    
    self.restCall.params = paramsDictionary;
    
    [self.restCall start];
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcVisitorTypingCall:self didFinishWithResult:(BCVisitorTypingCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcVisitorTypingCall:self didFinishWithError:error];
}

@end
