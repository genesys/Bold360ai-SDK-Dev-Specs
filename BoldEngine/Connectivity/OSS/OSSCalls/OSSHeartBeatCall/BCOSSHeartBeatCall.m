//
//  BCOSSHeartBeatCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/31/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSHeartBeatCall.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSHeartBeatCall

@synthesize ID = _ID;

- (NSData *)requestData {
    NSDictionary *paramsDict = @{
                @"result":@{@"Response" : @"ack"},
                @"error": [NSNull null],
                @"id": self.ID};
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramsDict options:0 error:&error];
    return jsonData;
}

- (BOOL)waitsForResponse {
    return NO;
}

- (BOOL)processResponse:(NSDictionary *)response {
    return NO;
}

@end
