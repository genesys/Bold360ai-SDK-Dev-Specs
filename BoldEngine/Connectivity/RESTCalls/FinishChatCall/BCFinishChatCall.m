//
//  BCFinishChatCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/2/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCFinishChatCall.h"
#import "BCFinishChatCallParser.h"

@interface BCFinishChatCall () <BCRESTCallDelegate>

@end

@implementation BCFinishChatCall

@synthesize chatKey = _chatKey;
@synthesize clientId = _clientId;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"finishChat";
    self.restCall.parser = [[BCFinishChatCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    paramsDictionary[@"ChatKey"] = self.chatKey;
    paramsDictionary[@"ClientID"] = self.clientId;
    
    
    self.restCall.params = paramsDictionary;
    
    [self.restCall start];
    
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcFinishChatCall:self didFinishWithResult:(BCFinishChatCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcFinishChatCall:self didFinishWithError:error];
}

@end
