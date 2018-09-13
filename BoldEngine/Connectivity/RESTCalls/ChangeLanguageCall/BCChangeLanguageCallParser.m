//
//  BCChangeLanguageCallParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/17/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCChangeLanguageCallParser.h"
#import "BCChangeLanguageCallResult.h"
#import "NSObject+nilOrValue.h"

@implementation BCChangeLanguageCallParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (parseError) {
        *error = parseError;
        return nil;
    }
    assert([parsedDictionary isKindOfClass:[NSDictionary class]]);
    
    BCChangeLanguageCallResult *result = [[BCChangeLanguageCallResult alloc] init];
    [self fillSuccessAndErrorFromDictionary:parsedDictionary forResult:result];
    
    result.language = [parsedDictionary[@"Language"] bcNilOrStringValue];
    result.brandings = parsedDictionary[@"Brandings"];
    
    return result;
}

@end
