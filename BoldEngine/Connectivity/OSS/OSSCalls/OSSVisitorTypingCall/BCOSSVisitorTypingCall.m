//
//  BCOSSVisitorTypingCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/1/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSVisitorTypingCall.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSVisitorTypingCall

@synthesize delegate = _delegate;
@synthesize chatKey = _chatKey;
@synthesize typing = _typing;

- (NSData *)requestData {
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
    paramsDict[@"ChatKey"] = self.chatKey;
    paramsDict[@"IsTyping"] = @(self.typing);
    
    NSData *jsonData = [self requestWithMethod:@"visitorTyping" params:paramsDict];
    return jsonData;
}

- (BOOL)processResponse:(NSDictionary *)response {
    if ([self.callId isEqualToString:[response[@"id"] bcNilOrStringValue]]) {
        [self.delegate ossVisitorTypingCallDidSucceed:self];
        return YES;
    }
    
    return NO;
    
}

@end
