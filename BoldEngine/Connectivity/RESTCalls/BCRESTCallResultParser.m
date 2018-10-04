//
//  BCRestCallResultParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/28/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCRESTCallResultParser.h"
#import "NSObject+nilOrValue.h"

@implementation BCRESTCallResultParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    return nil;
}

- (void)fillSuccessAndErrorFromDictionary:(NSDictionary *)dictionary forResult:(BCRESTCallResult *)result {
    result.status = [dictionary[@"Status"] bcNilOrStringValue];
    if ([[((NSString *)result.status) lowercaseString] isEqualToString:@"success"]) {
        result.statusSuccess = YES;
    }
    result.errorMessage = [dictionary[@"Message"] bcNilOrStringValue];
}

- (NSString *)stringValueOfObject:(NSObject *)object {
    if ([object isKindOfClass:[NSString class]]) {
        return (NSString *)object;
    } else if ([object respondsToSelector:@selector(stringValue)]) {
        return [((id)object) stringValue];
    } else {
        return @"";
    }
}

@end
