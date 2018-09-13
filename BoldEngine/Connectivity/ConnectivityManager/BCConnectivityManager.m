//
//  BCURLConnectionManager.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/27/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCConnectivityManager.h"
#import "BCHTTPConnection_URLConnection.h"
#import "BCHTTPConnection_URLSession.h"
#import "BCCreateChatCall.h"
#import "BCStartChatCall.h"
#import "BCFinishChatCall.h"
#import "BCOSSCommunicator.h"
#import "BCLongPollCall.h"
#import "BCSendMessageCall.h"
#import "BCVisitorTypingCall.h"
#import "BCGetChatAvailabilityCall.h"
#import "BCSubmitUnavailableEmailCall.h"
#import "BCSubmitPreChatCall.h"
#import "BCSubmitPostChatCall.h"
#import "BCEmailChatHistoryCall.h"
#import "BCPingChatCall.h"
#import "BCGetUnavailableFormCall.h"
#import "BCChangeLanguageCall.h"

/**
 BCConnectivityManager private interface.
 @since Version 1.0
 */
@interface BCConnectivityManager ()

/** 
 Tests if NSURLSession can be used. A way of testing if the OS is iOS 7 or above.
 @since Version 1.0
*/
- (BOOL)urlSessionIsEnabled;

/**
 Creates and preconfigures an empty REST call.
 @returns A preconfigured empty REST call.
 @since Version 1.0
 */
- (BCRESTCall *)emptyRestCall;
@end

@implementation BCConnectivityManager

@synthesize networkOperationQueue = _networkOperationQueue;
@synthesize urlSession = _urlSession;
@synthesize accountId = _accountId;
@synthesize accessKey = _accessKey;

@synthesize serverSet = _serverSet;


- (id)init {
    if ((self = [super init])) {
        self.networkOperationQueue = [[NSOperationQueue alloc] init];
        if ([self urlSessionIsEnabled]) {
            self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:self.networkOperationQueue];
        }
    }
    
    return self;
}

- (BCCreateChatCall *)createChatCall {
    BCCreateChatCall *createChatCall = [[BCCreateChatCall alloc] initWithRESTCall:[self emptyRestCall]];
    return createChatCall;
}

- (BCStartChatCall *)startChatCall {
    BCStartChatCall *startChatCall = [[BCStartChatCall alloc] initWithRESTCall:[self emptyRestCall]];
    return startChatCall;
}

- (BCFinishChatCall *)finishChatCall {
    BCFinishChatCall *finishChatCall = [[BCFinishChatCall alloc] initWithRESTCall:[self emptyRestCall]];
    return finishChatCall;
}

- (BCLongPollCall *)longPollCall {
    BCLongPollCall *longPollCall = [[BCLongPollCall alloc] initWithRESTCall:[self emptyRestCall]];
    return longPollCall;
}

- (BCSendMessageCall *)sendMessageCall {
    BCSendMessageCall *sendMessageCall = [[BCSendMessageCall alloc] initWithRESTCall:[self emptyRestCall]];
    return sendMessageCall;
}

- (BCVisitorTypingCall *)visitorTypingCall {
    BCVisitorTypingCall *visitorTypingCall = [[BCVisitorTypingCall alloc] initWithRESTCall:[self emptyRestCall]];
    return visitorTypingCall;
}

- (BCGetChatAvailabilityCall *)getChatAvailabilityCall {
    BCGetChatAvailabilityCall *getChatAvailabilityCall = [[BCGetChatAvailabilityCall alloc] initWithRESTCall:[self emptyRestCall]];
    return getChatAvailabilityCall;
}

- (BCSubmitUnavailableEmailCall *)submitUnavailableEmailCall {
    BCSubmitUnavailableEmailCall *submitUnavailableEmailCall = [[BCSubmitUnavailableEmailCall alloc]  initWithRESTCall:[self emptyRestCall]];
    return submitUnavailableEmailCall;
}

- (BCSubmitPreChatCall *)submitPreChatCall {
    BCSubmitPreChatCall *submitPreChatCall = [[BCSubmitPreChatCall alloc] initWithRESTCall:[self emptyRestCall]];
    return submitPreChatCall;
}

- (BCSubmitPostChatCall *)submitPostChatCall {
    BCSubmitPostChatCall *submitPostChatCall = [[BCSubmitPostChatCall alloc] initWithRESTCall:[self emptyRestCall]];
    return submitPostChatCall;
}

- (BCEmailChatHistoryCall *)emailChatHistoryCall {
    BCEmailChatHistoryCall *emailChatHistoryCall = [[BCEmailChatHistoryCall alloc] initWithRESTCall:[self emptyRestCall]];
    return emailChatHistoryCall;
}

- (BCPingChatCall *)pingChatCall {
    BCPingChatCall *pingChatCall = [[BCPingChatCall alloc] initWithRESTCall:[self emptyRestCall]];
    return pingChatCall;
}

- (BCGetUnavailableFormCall *)getUnavailableFormCall {
    BCGetUnavailableFormCall *getUnavailableFormCall = [[BCGetUnavailableFormCall alloc] initWithRESTCall:[self emptyRestCall]];
    return getUnavailableFormCall;
}

- (BCChangeLanguageCall *)changeLanguageCall {
    BCChangeLanguageCall *changeLanguageCall = [[BCChangeLanguageCall alloc] initWithRESTCall:[self emptyRestCall]];
    return changeLanguageCall;
}

- (BCOSSCommunicator *)ossCommunicator {
    BCOSSCommunicator *ossCommunicator = [[BCOSSCommunicator alloc] init];
    ossCommunicator.connectivityManager = self;
    ossCommunicator.urlSession = self.urlSession;
    return ossCommunicator;
}

- (BOOL)urlSessionIsEnabled {
    return NSClassFromString(@"NSURLSession") != nil;
}

- (BCRESTCall *)emptyRestCall {
    BCHTTPConnection *httpConnection = nil;
    if ([self urlSessionIsEnabled]) {
        httpConnection = [[BCHTTPConnection_URLSession alloc] init];
        ((BCHTTPConnection_URLSession *)httpConnection).urlSession = self.urlSession;
    } else {
        httpConnection = [[BCHTTPConnection_URLConnection alloc] init];
    }
    httpConnection.operationQueue = self.networkOperationQueue;
    
    BCRESTCall *restCall = [BCRESTCall restCallWithHttpConnection:httpConnection];
    restCall.accountId = self.accountId;
    restCall.accessKey = self.accessKey;
    restCall.serverSet = self.serverSet;
    
    return restCall;
}

@end
