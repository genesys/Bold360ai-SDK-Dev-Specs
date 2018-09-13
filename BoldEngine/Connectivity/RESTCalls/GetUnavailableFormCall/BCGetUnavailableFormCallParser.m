//
//  BCGetUnavailableFormCallParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/10/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCGetUnavailableFormCallParser.h"
#import "BCGetUnavailableFormCallResult.h"
#import "BCFormFieldParser.h"

@implementation BCGetUnavailableFormCallParser

- (NSObject *)parse:(NSData *)data error:(__autoreleasing NSError**)error {
    NSError *parseError = nil;
    NSDictionary *parsedDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    
    if (parseError) {
        *error = parseError;
        return nil;
    }
    assert([parsedDictionary isKindOfClass:[NSDictionary class]]);
    
    BCGetUnavailableFormCallResult *result = [[BCGetUnavailableFormCallResult alloc] init];
    [self fillSuccessAndErrorFromDictionary:parsedDictionary forResult:result];
    
    NSDictionary *unavailableFormDict = parsedDictionary[@"UnavailableForm"];
    if (unavailableFormDict) {
        NSArray *fields = unavailableFormDict[@"Fields"];
        result.unavailableForm = [BCFormFieldParser formFields:fields];
    }
    
    return result;
}

@end
