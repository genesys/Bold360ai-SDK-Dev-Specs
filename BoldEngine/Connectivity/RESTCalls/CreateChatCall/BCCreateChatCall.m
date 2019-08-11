//
//  BCCreateChatCall.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/28/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCCreateChatCall.h"
#import "BCCreateChatCallParser.h"
#import "BCAccount.h"

@interface BCCreateChatCall () <BCRESTCallDelegate>

@end

@implementation BCCreateChatCall

@synthesize visitorId = _visitorId;
@synthesize language = _language;
@synthesize includeBrandingValues = _includeBrandingValues;
@synthesize includeChatWindowSettingsValues = _includeChatWindowSettingsValues;
@synthesize skipPreChat = _skipPreChat;
@synthesize secured = _secured;
@synthesize data = _data;
@synthesize delegate = _delegate;

- (void)start {
    self.restCall.delegate = self;
    self.restCall.methodName = @"createChat";
    self.restCall.parser = [[BCCreateChatCallParser alloc] init];
    
    //TODO:: get it as dictionary on session creation.
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    paramsDictionary[@"VisitorID"] = self.visitorId ? self.visitorId : @"";
    paramsDictionary[@"Language"] = self.language ? self.language : @"en-US";
    paramsDictionary[@"IncludeBrandingValues"] = self.includeBrandingValues ? @"true" : @"false";
    paramsDictionary[@"SkipPreChat"] = self.skipPreChat ? @"true" : @"false";
    paramsDictionary[@"IncludeChatWindowSettings"] = self.includeChatWindowSettingsValues ? @"true" : @"false";
    paramsDictionary[@"IncludeLayeredBrandingValues"] = @"true";
    
    if (self.secured) paramsDictionary[@"Secured"] = self.secured;
    NSString *customUrl = self.data[BCFormFieldCustomUrl];
    //Custom URL is sent in a separate parameter
    if (customUrl.length) {
        paramsDictionary[@"CustomUrl"] = customUrl;
        
        NSMutableDictionary *mutableData = [NSMutableDictionary dictionaryWithDictionary:self.data];
        [mutableData removeObjectForKey:BCFormFieldCustomUrl];
        self.data = mutableData;
    }
    
    if (self.data.count) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.data options:0 error:&error];
        
        if (!error) {
            paramsDictionary[@"Data"] = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    
    self.restCall.params = paramsDictionary;
    [self.restCall start];
}

#pragma mark -
#pragma mark BCRESTCallDelegate
- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithResult:(NSObject *)result {
    [self.delegate bcCreateChatCall:self didFinishWithResult:(BCCreateChatCallResult *)result];
}

- (void)bcRestCall:(BCRESTCall *)restCall didFinishWithError:(NSError *)error {
    [self.delegate bcCreateChatCall:self didFinishWithError:error];
}

@end
