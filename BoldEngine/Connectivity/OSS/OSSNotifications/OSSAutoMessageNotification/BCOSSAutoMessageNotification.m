//
//  BCOSSAutoMessageNotification.m
//  VisitorSDK
//
//  Created by vfabian on 04/06/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSAutoMessageNotification.h"
#import "NSObject+nilOrValue.h"

@implementation BCOSSAutoMessageNotification

@synthesize delegate = _delegate;

- (BOOL)processMessage:(NSDictionary *)message {
    if ([message[@"method"] isEqualToString:@"autoMessage"]) {
        NSString *text = nil;
        
        NSArray *paramsArray = message[@"params"];
        if (paramsArray.count > 0) {
            NSDictionary *paramsDict = paramsArray[0];
            
            if (paramsDict) {
                if (paramsDict[@"Text"]) text = [paramsDict[@"Text"] bcNilOrStringValue];
            }
        }
        [self.delegate ossAutoMessageNotification:self text:text];
        return YES;
    } else {
        return NO;
    }
}


@end
