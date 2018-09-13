//
//  BCOSSCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/31/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSCall.h"
#import "NSString+RandomIdentifier.h"

@implementation BCOSSCall

@synthesize callId = _callId;

- (NSData *)requestData {
    return nil;
}

- (BOOL)waitsForResponse {
    return YES;
}

- (BOOL)processResponse:(NSDictionary *)response {
    return NO;
}

- (NSData *)requestWithMethod:(NSString *)method params:(NSDictionary *)paramsDict {
    NSMutableDictionary *sendDictionary = [NSMutableDictionary dictionary];
    sendDictionary[@"method"] = method;
    sendDictionary[@"id"] = self.callId = [NSString bcRandomIdentifier];
    NSMutableArray *params = [NSMutableArray array];
    
    [params addObject:paramsDict];
    sendDictionary[@"params"] = params;
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDictionary options:0 error:&error];
    
    return jsonData;
}

@end
