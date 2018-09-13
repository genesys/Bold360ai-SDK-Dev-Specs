//
//  BCOSSConnectCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/31/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSConnectCall.h"
#import "NSString+RandomIdentifier.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSConnectCall

@synthesize delegate = _delegate;
@synthesize lastMessageId = _lastMessageId;

- (NSData *)requestData {
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
    paramsDict[@"LastMessageID"] = [NSString stringWithFormat:@"%lld",self.lastMessageId];
    
    NSData *jsonData = [self requestWithMethod:@"connect" params:paramsDict];
    return jsonData;
}

- (BOOL)processResponse:(NSDictionary *)response {
    if ([self.callId isEqualToString:[response[@"id"] bcNilOrStringValue]]) {
        [self.delegate ossConnectCallDidSucceed:self];
        return YES;
    }
    
    return NO;
    
}


@end
