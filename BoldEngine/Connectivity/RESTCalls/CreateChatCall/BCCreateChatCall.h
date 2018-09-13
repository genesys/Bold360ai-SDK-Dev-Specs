//
//  BCCreateChatCall.h
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/28/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCCall.h"
#import "BCCreateChatCallResult.h"

@class BCCreateChatCall;

@protocol BCCreateChatCallDelegate <NSObject>
- (void)bcCreateChatCall:(BCCreateChatCall *)createChatCall didFinishWithResult:(BCCreateChatCallResult *)result;
- (void)bcCreateChatCall:(BCCreateChatCall *)createChatCall didFinishWithError:(NSError *)error;
@end

@interface BCCreateChatCall : BCCall

@property(nonatomic, copy)NSString *visitorId;
@property(nonatomic, copy)NSString *language;
@property(nonatomic, assign)BOOL includeBrandingValues;
@property(nonatomic, assign)BOOL skipPreChat;
@property(nonatomic, strong)NSDictionary *data;
@property(nonatomic, assign)id<BCCreateChatCallDelegate> delegate;

@end
