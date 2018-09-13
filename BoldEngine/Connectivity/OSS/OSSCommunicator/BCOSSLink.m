//
//  BCOSSLink.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/28/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCOSSLink.h"

@implementation BCOSSLink

@synthesize delegate = _delegate;
@synthesize responsePreProcessor = _responsePreProcessor;
@synthesize operationQueue = _operationQueue;
@synthesize chatKey = _chatKey;
@synthesize lastMessageId = _lastMessageId;
@synthesize clientId = _clientId;
@synthesize timeoutInSeconds = _timeoutInSeconds;
@synthesize connectivityManager = _connectivityManager;
@synthesize lastMessageTime = _lastMessageTime;

- (void)start {
    
}

- (void)close {
    
}

- (void)sendMessage:(BCMessage *)message {
    
}

- (void)sendTyping:(BOOL)typing {
    
}

- (void)suspend {
    
}

- (void)resume {
    
}



@end
