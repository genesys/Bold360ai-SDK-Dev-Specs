//
//  BCOSSUpdateChatNotification.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/31/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSUpdateChatNotification.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSUpdateChatNotification

@synthesize delegate = _delegate;

- (BOOL)processMessage:(NSDictionary *)message {
    if ([message[@"method"] isEqualToString:@"updateChat"]) {
        NSString *chatId = nil;
        NSDate *endDate = nil;
        NSString *endReason = nil;
        NSString *answered = nil;
        
        NSArray *paramsArray = message[@"params"];
        if (paramsArray.count > 0) {
            NSDictionary *paramsDict = paramsArray[0];
            chatId = [paramsDict[@"ChatID"] bcNilOrStringValue];
            NSDictionary *values = paramsDict[@"Values"];
            if (values) {
                endReason = [values[@"EndedReason"] bcNilOrStringValue];
                answered = [values[@"Answered"] bcNilOrStringValue];
                
                NSString *endedValue = [values[@"Ended"] bcNilOrStringValue];
                if (endedValue) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setLenient:YES];
                    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                    [formatter setTimeZone:gmt];
                    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
                    
                    endDate = [formatter dateFromString:endedValue];
                }
            }
            
            [self.delegate ossUpdateChatNotification:self
                                              chatId:chatId
                                            answered:answered
                                             endedAt:endDate
                                              reason:endReason];
        }
        return YES;
    } else {
        return NO;
    }
}


@end
