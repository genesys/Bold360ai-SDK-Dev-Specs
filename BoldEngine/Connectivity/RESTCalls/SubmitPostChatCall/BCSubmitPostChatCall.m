//
//  BCSubmitPostChatCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/10/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCSubmitPostChatCall.h"
#import "BCSubmitPostChatCallParser.h"

@interface BCSubmitPostChatCall () <BCRESTCallDelegate>

@end

@implementation BCSubmitPostChatCall

@synthesize chatKey = _chatKey;
@synthesize data = _data;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"submitPostChat";
    self.restCall.parser = [[BCSubmitPostChatCallParser alloc] init];
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    paramsDictionary[@"ChatKey"] = self.chatKey;
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.data options:0 error:&error];
    
    if (!error) {
        paramsDictionary[@"Data"] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    self.restCall.params = paramsDictionary;
    
    [self.restCall start];
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcSubmitPostChatCall:self didFinishWithResult:(BCSubmitPostChatCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcSubmitPostChatCall:self didFinishWithError:error];
}

@end
