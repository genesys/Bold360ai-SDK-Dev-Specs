//
//  BCPingChatCallParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/14/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCPingChatCallParser.h"
#import "BCPingChatCallResult.h"
#import "NSObject+nilOrValue.h"

@implementation BCPingChatCallParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (parseError) {
        *error = parseError;
        return nil;
    }
    assert([parsedDictionary isKindOfClass:[NSDictionary class]]);
    
    BCPingChatCallResult *result = [[BCPingChatCallResult alloc] init];
    [self fillSuccessAndErrorFromDictionary:parsedDictionary forResult:result];
    result.recapture = [parsedDictionary[@"Recapture"] bcNilOrBoolValue];
    
    return result;
}


@end
