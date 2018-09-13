//
//  BCSendMessageCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/2/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCSendMessageCall.h"
#import "BCSendMessageCallParser.h"

@interface BCSendMessageCall () <BCRESTCallDelegate>

@end

@implementation BCSendMessageCall

@synthesize chatKey = _chatKey;
@synthesize chatMessageID = _chatMessageID;
@synthesize name = _name;
@synthesize message = _message;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"sendMessage";
    self.restCall.parser = [[BCSendMessageCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    paramsDictionary[@"ChatKey"] = self.chatKey;
    paramsDictionary[@"ChatMessageID"] = self.chatMessageID;
    if (self.name) paramsDictionary[@"Name"] = self.name;
    paramsDictionary[@"Message"] = self.message;
    
    
    self.restCall.params = paramsDictionary;
    
    [self.restCall start];
    
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcSendMessageCall:self didFinishWithResult:(BCSendMessageCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcSendMessageCall:self didFinishWithError:error];
}

@end
