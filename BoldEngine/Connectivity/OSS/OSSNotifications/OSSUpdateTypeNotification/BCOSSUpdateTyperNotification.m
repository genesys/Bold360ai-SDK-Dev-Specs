//
//  BCOSSUpdateTyperNotification.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/31/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSUpdateTyperNotification.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSUpdateTyperNotification

- (BOOL)processMessage:(NSDictionary *)message {
    if ([message[@"method"] isEqualToString:@"updateTyper"]) {
        NSString *personId = nil;
        NSString *name = nil;
        NSString *personType = nil;
        NSString *imageUrl = nil;
        BOOL isTyping = NO;
        
        NSArray *paramsArray = message[@"params"];
        if (paramsArray.count > 0) {
            NSDictionary *paramsDict = paramsArray[0];
            if(paramsDict[@"PersonID"]) personId = [paramsDict[@"PersonID"] bcNilOrStringValue];
            NSDictionary *values = paramsDict[@"Values"];
            if (values) {
                if (values[@"Name"]) name = [values[@"Name"] bcNilOrStringValue];
                if (values[@"PersonType"]) personType = [values[@"PersonType"] bcNilOrStringValue];
                if (values[@"ImageURL"]) imageUrl = [values[@"ImageURL"] bcNilOrStringValue];
                if (values[@"IsTyping"]) {
                    isTyping = [values[@"IsTyping"] bcNilOrBoolValue];
                }
            }
        }
        BCPerson *person = [[BCPerson alloc] init];
        person.personId = personId;
        person.name = name;
        person.imageUrl = imageUrl;
        if ([personType isEqualToString:@"operator"]) {
            person.personType = BCPersonTypeOperator;
        } else if ([personType isEqualToString:@"visitor"]) {
            person.personType = BCPersonTypeVisitor;
        }else if ([personType isEqualToString:@"system"]) {
            person.personType = BCPersonTypeSystem;
        }
        
        [self.delegate ossUpdateTyperNotification:self didReceivePerson:person typing:isTyping];
        return YES;
    } else {
        return NO;
    }
}


@end
