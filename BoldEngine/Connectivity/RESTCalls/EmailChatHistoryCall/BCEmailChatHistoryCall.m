//
//  BCEmailChatHistoryCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/10/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCEmailChatHistoryCall.h"
#import "BCEmailChatHistoryCallParser.h"

@interface BCEmailChatHistoryCall () <BCRESTCallDelegate>

@end


@implementation BCEmailChatHistoryCall

@synthesize chatKey = _chatKey;
@synthesize emailAddress = _emailAddress;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"emailChatHistory";
    self.restCall.parser = [[BCEmailChatHistoryCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    paramsDictionary[@"ChatKey"] = self.chatKey;
    paramsDictionary[@"EmailAddress"] = self.emailAddress;
    
    self.restCall.params = paramsDictionary;
    
    [self.restCall start];
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcEmailChatHistoryCall:self didFinishWithResult:(BCEmailChatHistoryCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcEmailChatHistoryCall:self didFinishWithError:error];
}

@end
