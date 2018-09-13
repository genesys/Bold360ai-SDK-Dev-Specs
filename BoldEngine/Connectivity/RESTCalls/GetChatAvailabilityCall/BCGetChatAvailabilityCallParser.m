//
//  BCGetChatAvailabilityCallParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/9/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCGetChatAvailabilityCallParser.h"
#import "BCGetChatAvailabilityCallResult.h"
#import "NSObject+nilOrValue.h"

@implementation BCGetChatAvailabilityCallParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (parseError) {
        *error = parseError;
        return nil;
    }
    assert([parsedDictionary isKindOfClass:[NSDictionary class]]);
    
    BCGetChatAvailabilityCallResult *result = [[BCGetChatAvailabilityCallResult alloc] init];
    [self fillSuccessAndErrorFromDictionary:parsedDictionary forResult:result];
    result.available = [parsedDictionary[@"Available"] bcNilOrBoolValue];
    result.unavailableReason = [parsedDictionary[@"UnavailableReason"] bcNilOrStringValue];
    return result;
}

@end
