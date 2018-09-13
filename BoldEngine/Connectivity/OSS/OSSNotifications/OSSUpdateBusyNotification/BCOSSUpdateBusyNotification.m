//
//  BCOSSUpdateBusyNotification.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/31/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSUpdateBusyNotification.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSUpdateBusyNotification

- (BOOL)processMessage:(NSDictionary *)message {
    if ([message[@"method"] isEqualToString:@"updateBusy"]) {
        NSInteger position = -1;
        BOOL unavailableFormEnabled = NO;
        
        
        NSArray *paramsArray = message[@"params"];
        if (paramsArray.count > 0) {
            NSDictionary *paramsDict = paramsArray[0];
            
            if (paramsDict) {
                if (paramsDict[@"Position"]) position = [paramsDict[@"Position"] bcNilOrIntegerValue];
                if (paramsDict[@"UnavailableFormEnabled"]) unavailableFormEnabled = [paramsDict[@"UnavailableFormEnabled"] bcNilOrBoolValue];
            }
        }
        [self.delegate ossUpdateBusyNotification:self position:position unavailableFormEnabled:unavailableFormEnabled];
        return YES;
    } else {
        return NO;
    }
}


@end
