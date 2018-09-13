//
//  BCOSSAddMessageNotification.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/31/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSAddMessageNotification.h"
#import "BCMessage.h"
#import "BCPerson.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSAddMessageNotification

- (BOOL)processMessage:(NSDictionary *)message {
    if ([message[@"method"] isEqualToString:@"addMessage"]) {
        NSString *messageId = nil;
        NSString *personId = nil;
        NSString *name = nil;
        NSString *personType = nil;
        NSString *created = nil;
        NSString *text = nil;

        
        NSArray *paramsArray = message[@"params"];
        if (paramsArray.count > 0) {
            NSDictionary *paramsDict = paramsArray[0];
            if(paramsDict[@"MessageID"]) messageId = [paramsDict[@"MessageID"] bcNilOrStringValue];
            NSDictionary *values = paramsDict[@"Values"];
            if (values) {
                if (values[@"Name"]) name = [values[@"Name"] bcNilOrStringValue];
                if (values[@"PersonID"]) personId = [values[@"PersonID"] bcNilOrStringValue];
                if (values[@"PersonType"]) personType = [values[@"PersonType"] bcNilOrStringValue];
                if (values[@"Created"]) created = [values[@"Created"] bcNilOrStringValue];
                if (values[@"Text"]) text = [values[@"Text"] bcNilOrStringValue];
            }
        }
        BCPerson *person = [[BCPerson alloc] init];
        person.personId = personId;
        person.name = name;
        if ([personType isEqualToString:@"operator"]) {
            person.personType = BCPersonTypeOperator;
        } else if ([personType isEqualToString:@"visitor"]) {
            person.personType = BCPersonTypeVisitor;
        }else if ([personType isEqualToString:@"system"]) {
            person.personType = BCPersonTypeSystem;
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLenient:YES];
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [formatter setTimeZone:gmt];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        
        BCMessage *message = [[BCMessage alloc] initWithID:messageId sender:person created:[formatter dateFromString:created] updated:nil htmlText:text];
        
        [self.delegate ossAddMessageNotification:self didReceiveMessage:message];
        return YES;
    } else {
        return NO;
    }
}


@end
