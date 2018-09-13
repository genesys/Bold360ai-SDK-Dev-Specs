//
//  BCStartChatCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/28/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCStartChatCall.h"
#import "BCStartChatCallParser.h"

@interface BCStartChatCall () <BCRESTCallDelegate>

@end


@implementation BCStartChatCall

@synthesize chatKey = _chatKey;
@synthesize lastChatMessageId = _lastChatMessageId;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"startChat";
    self.restCall.parser = [[BCStartChatCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    /*if( self.chatKey )*/ paramsDictionary[@"ChatKey"] = self.chatKey ? self.chatKey : @"";
    paramsDictionary[@"LastChatMessageID"] = [NSString stringWithFormat:@"%lld",self.lastChatMessageId];
    self.restCall.params = paramsDictionary;
    [self.restCall start];
    
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcStartChatCall:self didFinishWithResult:(BCStartChatCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcStartChatCall:self didFinishWithError:error];
}

@end
