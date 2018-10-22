//
//  BCChatSessionImpl.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 3/27/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCChatSessionImpl.h"

#import "BCConnectivityManager.h"
#import "BCCreateChatCall.h"
#import "BCForm.h"
#import <BoldEngine/BCFormField.h>
#import "BCChatImpl.h"
#import "BCSubmitUnavailableEmailCall.h"
#import "BCSubmitPreChatCall.h"
#import "BCSubmitPostChatCall.h"
#import "BCEmailChatHistoryCall.h"
#import "BCGetChatAvailabilityCall.h"
#import "BCChangeLanguageCall.h"
#import "BCChatRecovery.h"
#import "BCAccount.h"
#import <BoldEngine/NSString+BCValidation.h>
#import "BCCancelableImpl.h"

/** @file */
/**
 The inner state of the BCChatSessionImpl.
 @since Version 1.0
 */
typedef enum {
    BCChatSessionStateIdle, /**< The starting state @since Version 1.0*/
    BCChatSessionStateCreatingChat, /**< The createChat is being called @since Version 1.0*/
    BCChatSessionStatePreChatForm, /**< The createChat returned pre-chat information is being gathered from the visitor. @since Version 1.0*/
    BCChatSessionStateSendingPreChatInfo, /**< The submitPreChatAnswers is being called. @since Version 1.0*/
    BCChatSessionStateChatting, /**< There is an ongoing chat. @since Version 1.0*/
    BCChatSessionStatePostChatForm, /**< The chat ended, the post-chat form information is being gathered from the visitor. @since Version 1.0*/
    BCChatSessionStateSendingPostChatInfo,/**< The sumbitPostChatAnswers is being called. @since Version 1.0*/
    BCChatSessionStateUnavailableForm, /**< The unavailable form info is being gathered from the visitor. @since Version 1.0*/
    BCChatSessionStateSendingUnavailableInfo, /**< The submitUnavailable is being called @since Version 1.0*/
    BCChatSessionStateFinished /**< The session finished. @since Version 1.0*/
}BCChatSessionState;

/**
 BCChatSessionImpl private interface.
 @since Version 1.0
 */
@interface BCChatSessionImpl () <BCCreateChatCallDelegate, BCSubmitUnavailableEmailCallDelegate, BCSubmitPreChatCallDelegate, BCSubmitPostChatCallDelegate, BCEmailChatHistoryCallDelegate, BCChatRecoveryDelegate, BCChangeLanguageCallDelegate, BCCancelableImplDelegate, BCChatStateDelegate>

/**
 The inner state of the current session.
 @since Version 1.0
 */
@property (nonatomic, assign) BCChatSessionState state;

/**
 The suspended state.
 @since Version 1.0
 */
@property (nonatomic, assign) BOOL suspended;

/**
 The account ID.
 @since Version 1.0
 */
@property (nonatomic, copy) NSString *accountId;

/**
 The access key.
 @since Version 1.0
 */
@property (nonatomic, copy) NSString *accessKey;

/**
 Current language.
 @since Version 1.0
 */
@property (nonatomic, copy) NSString *language;

/**
 The department ID.
 @since Version 1.0
 */
@property (nonatomic, copy) NSString *departmentId;

/**
 Current chat key.
 @since Version 1.0
 */
@property (nonatomic, copy)NSString *chatKey;

/**
 Current chat ID.
 @since Version 1.0
 */
@property (nonatomic, copy)NSString *chatId;

/**
 Current client ID.
 @since Version 1.0
 */
@property (nonatomic, copy)NSString *clientId;

/**
 Recapture is available if the unavailable operator form is shown, and an operator became available.
 @since Version 1.0
 */
@property (nonatomic, assign)BOOL recaptureAvailable;

/**
 The end reason of the chat.
 @since Version 1.0
 */
@property (nonatomic, assign)BCChatEndReason endReason;

/**
 The unavailable operator reason.
 @since Version 1.0
 */
@property (nonatomic, assign) BCUnavailableReason unavailableReason;

/**
 If an unavailableMessage needs to be shown, and there is no form, show this message.
 @since Version 1.0
 */
@property (nonatomic, strong) NSString *unavailableMessage;

/**
 the current visitor.
 @since Version 1.0
 */
@property (nonatomic, strong)BCPerson *visitor;

/**
 The pre chat form description for the current chat session.
 @since Version 1.0
 */

@property (nonatomic, strong)BCForm *preChatForm;

/**
 The post chat form description for the current chat session. It is filled after the chat.
 @since Version 1.0
 */
@property (nonatomic, strong)BCForm *postChatForm;

/**
 The unavailable operator form description. It is filled before the next phase is the unavailable operator form.
 @since Version 1.0
 */
@property (nonatomic, strong)BCForm *unavailableForm;

/**
 The chatting instance. It is filled before the BCChatSessionNextStepChat nextStep was initiated. It can happen after startSession, restartSession, submitPreChatAnswers.
 @since Version 1.0
 */
@property (nonatomic, strong)id<BCChat> chat;

/**
 A dictionary that contains the localized strings for the current language.
 @since Version 1.0
 */
@property (nonatomic, copy)NSDictionary *branding;

/**
 Connectivity manager for the network calls. The same connectivity manager is used for the chat sessions and the availability ckeckers.
 @since Version 1.0
 */
@property (nonatomic, strong)BCConnectivityManager *connectivityManager;

/**
 CreateChatCall object.
 @since Version 1.0
 */
@property (nonatomic, strong)BCCreateChatCall *createChatCall;

/**
 SubmitUnavailableEmailCall object.
 @since Version 1.0
 */
@property (nonatomic, strong)BCSubmitUnavailableEmailCall *submitUnavailableEmailCall;

/**
 SubmitPreChatCall object.
 @since Version 1.0
 */
@property (nonatomic, strong)BCSubmitPreChatCall *submitPreChatCall;

/**
 SubmitPostChatCall object.
 @since Version 1.0
 */
@property (nonatomic, strong)BCSubmitPostChatCall *submitPostChatCall;

/**
 EmailChatHistoryCall object.
 @since Version 1.0
 */
@property (nonatomic, strong)BCEmailChatHistoryCall *emailChatHistoryCall;

/**
 ChangeLanguageCall object.
 @since Version 1.0
 */
@property (nonatomic, strong)BCChangeLanguageCall *changeLanguageCall;

/**
 Chat recovery for checking if there is an available operator
 @since Version 1.0
 */
@property (nonatomic, strong)BCChatRecovery *chatRecovery;

/**
 If there is pre-chat set for the chat it can be skipped with sending the answers in the data.
 @since Version 1.0
 */
@property (nonatomic, assign)BOOL skipPreChat;

/**
 The answers for the skipped pre chat and external parameters.
 @since Version 1.0
 */
@property (nonatomic, strong)NSDictionary *data;

/**
 The delegate for create chat call result.
 @since Version 1.0
 */
@property (nonatomic, assign)id<BCChatSessionImplCreationDelegate> createChatDelegate;

/**
 The delegate for submitUnavailableEmail result.
 @since Version 1.0
 */
@property (nonatomic, assign)id<BCSubmitUnavailableEmailDelegate> submitUnavailableEmailDelegate;

/**
 The cancelable for submitUnavailableEmail.
 @since Version 1.0
 */
@property (nonatomic, strong)BCCancelableImpl *submitUnavailableEmailCancelable;

/**
 The delegate for submitPreChat result.
 @since Version 1.0
 */
@property (nonatomic, assign)id<BCSubmitPreChatDelegate> submitPreChatDelegate;

/**
 The cancelable for submitPreChat.
 @since Version 1.0
 */
@property (nonatomic, strong)BCCancelableImpl *submitPreChatCancelable;

/**
 The delegate for submitPostChat result.
 @since Version 1.0
 */
@property (nonatomic, assign)id<BCSubmitPostChatDelegate> submitPostChatDelegate;

/**
 The cancelable for submitPostChat.
 @since Version 1.0
 */
@property (nonatomic, strong)BCCancelableImpl *submitPostChatCancelable;

/**
 The delegate for emailChatHistory result.
 @since Version 1.0
 */
@property (nonatomic, assign)id<BCEmailChatHistoryDelegate> emailChatHistoryDelegate;

/**
 The cancelable for emailChatHistory.
 @since Version 1.0
 */
@property (nonatomic, strong)BCCancelableImpl *emailChatHistoryCancelable;

/**
 The delegate for emailChatHistory result.
 @since Version 1.0
 */
@property (nonatomic, assign)id<BCChangeLanguageDelegate> changeLanguageDelegate;

/**
 The cancelable for emailChatHistory.
 @since Version 1.0
 */
@property (nonatomic, strong)BCCancelableImpl *changeLanguageCancelable;



/**
 Starts the chat session creation.
 @since Version 1.0
 */
- (void)startChatSession;

/**
 Creates an error from a message got from the server.
 @param message The message from the server.
 @returns The error object.
 @since Version 1.0
 */
- (NSError *)errorFromMessage:(NSString *)message;

/**
 Creates unavailable reason enum from string got from the server.
 @param string The string representation of the unavailable reason.
 @returns Unavailable reason enum value.
 @since Version 1.0
 */
- (BCUnavailableReason)unavailableReasonFromString:(NSString *)string;

/**
 Tests if all required fields are answered.
 @param formDescription The form description.
 @returns The array of \link BCFormField \endlink objects that are required but not filled.
 @since Version 1.0
 */
- (NSArray *)testFormAnswers:(BCForm *)formDescription;


/**
 Cancels the currently running submit unavailable operator form call.
 @since Version 1.0
 */
- (void)cancelSubmitUnavailableFormAnswers;

/**
 Cancels the currently running submit pre chat answers form call.
 @since Version 1.0
 */
- (void)cancelSubmitPreChatAnswers;

/**
 Cancels the currently running submit post chat answers form call.
 @since Version 1.0
 */
- (void)cancelSubmitPostChatAnswers;

/**
 Cancels the currently running request to send the transcript to the given email.
 @since Version 1.0
 */
- (void)cancelRequestChatHistoryInEmail;

/**
 Cancels the currently running request to schange language.
 @since Version 1.0
 */
- (void)cancelChangeLanguage;


@end

@implementation BCChatSessionImpl

@synthesize state = _state;
@synthesize suspended = _suspended;

@synthesize chatRecaptureDelegate = _chatRecaptureDelegate;

@synthesize accountId = _accountId;
@synthesize accessKey = _accessKey;
@synthesize language = _language;
@synthesize departmentId = _departmentId;
@synthesize chatKey = _chatKey;
@synthesize chatId = _chatId;
@synthesize clientId = _clientId;
@synthesize recaptureAvailable = _recaptureAvailable;
@synthesize endReason = _endReason;
@synthesize unavailableReason = _unavailableReason;
@synthesize visitor = _visitor;
@synthesize skipPreChat = _skipPreChat;
@synthesize data = _data;

@synthesize preChatForm = _preChatForm;
@synthesize postChatForm = _postChatForm;
@synthesize unavailableForm = _unavailableForm;

@synthesize chat = _chat;
@synthesize branding = _branding;

@synthesize connectivityManager = _connectivityManager;
@synthesize createChatCall = _createChatCall;
@synthesize submitUnavailableEmailCall = _submitUnavailableEmailCall;
@synthesize submitPreChatCall = _submitPreChatCall;
@synthesize submitPostChatCall = _submitPostChatCall;
@synthesize emailChatHistoryCall = _emailChatHistoryCall;
@synthesize unavailableMessage = _unavailableMessage;

@synthesize createChatDelegate = _createChatDelegate;

@synthesize submitUnavailableEmailDelegate = _submitUnavailableEmailDelegate;
@synthesize submitUnavailableEmailCancelable = _submitUnavailableEmailCancelable;

@synthesize submitPreChatDelegate = _submitPreChatDelegate;
@synthesize submitPreChatCancelable = _submitPreChatCancelable;

@synthesize submitPostChatDelegate = _submitPostChatDelegate;
@synthesize submitPostChatCancelable = _submitPostChatCancelable;

@synthesize emailChatHistoryDelegate = _emailChatHistoryDelegate;
@synthesize emailChatHistoryCancelable = _emailChatHistoryCancelable;

@synthesize changeLanguageDelegate = _changeLanguageDelegate;
@synthesize changeLanguageCancelable = _changeLanguageCancelable;

+ (id)chatSessionImplWithAccountId:(NSString *)accountId
                         accessKey:(NSString *)accessKey
               connectivityManager:(BCConnectivityManager *)connectivityManager
                          language:(NSString *)language
                         visitorId:(NSString *)visitorId
                       skipPreChat:(BOOL)skipPreChat
                              data:(NSDictionary *)data{
    return [[[self class] alloc] initWithAccountId:accountId
                                         accessKey:accessKey
                               connectivityManager:connectivityManager
                                          language:language
                                         visitorId:visitorId
                                       skipPreChat:skipPreChat
                                              data:data];
}

- (id)initWithAccountId:(NSString *)accountId
              accessKey:(NSString *)accessKey
    connectivityManager:(BCConnectivityManager *)connectivityManager
               language:(NSString *)language
              visitorId:(NSString *)visitorId
            skipPreChat:(BOOL)skipPreChat
                   data:(NSDictionary *)data{
    if ((self = [self init])) {
        self.accountId = accountId;
        self.accessKey = accessKey;
        self.language = language;
        self.visitor = [[BCPerson alloc] init];
        self.visitor.personType = BCPersonTypeVisitor;
        if (visitorId) {
            self.visitor.personId = visitorId;
        }
        self.connectivityManager = connectivityManager;
        
        self.skipPreChat = skipPreChat;
        self.data = data;
    }
    return self;
}

- (void)createChatWithDelegate:(id<BCChatSessionImplCreationDelegate>)createChatDelegate {
    self.createChatDelegate = createChatDelegate;
    [self startChatSession];
}

- (void)startChatSession {
    if (self.suspended || !(self.state == BCChatSessionStateIdle || self.state == BCChatSessionStateFinished) ) {
        return;
    }
    self.recaptureAvailable = NO;
    self.state = BCChatSessionStateCreatingChat;
    self.createChatCall = [self.connectivityManager createChatCall];
    self.createChatCall.visitorId = self.visitor.personId;
    self.createChatCall.language = self.language;
    self.createChatCall.includeBrandingValues = YES;
    self.createChatCall.skipPreChat = _skipPreChat;
    self.createChatCall.data = _data;
    self.createChatCall.delegate = self;
    [self.createChatCall start];
}

- (void)finishChatSession {
    if (self.suspended) return;
    
    [self.chatRecovery sendClosedAndStop];
    
    if (self.state == BCChatSessionStateCreatingChat) {
        [self.createChatCall cancel];
        self.createChatCall = nil;
    } else if(self.state == BCChatSessionStateChatting) {
        [self.chat finishChat];
    } else if (self.state == BCChatSessionStateSendingPreChatInfo) {
        [self.submitPreChatCall cancel];
    } else if (self.state == BCChatSessionStateSendingPostChatInfo) {
        [self.submitPostChatCall cancel];
    } else if (self.state == BCChatSessionStateSendingUnavailableInfo) {
        [self.submitUnavailableEmailCall cancel];
    }
    self.state = BCChatSessionStateFinished;
}

- (void)suspend {
    if (self.suspended) return;
    
    if (self.state != BCChatSessionStateIdle && self.state != BCChatSessionStateFinished) {
        [self.chatRecovery stop];
    }
    
    if (self.state == BCChatSessionStateCreatingChat) {
        [self.createChatCall suspend];
    } else if (self.state == BCChatSessionStateChatting) {
        [(BCChatImpl *)self.chat suspend];
    } else if (self.state == BCChatSessionStateSendingPreChatInfo) {
        [self.submitPreChatCall suspend];
    } else if (self.state == BCChatSessionStateSendingPostChatInfo) {
        [self.submitPostChatCall suspend];
    } else if (self.state == BCChatSessionStateSendingUnavailableInfo) {
        [self.submitUnavailableEmailCall suspend];
    }
    self.suspended = YES;
}

- (void)resume {
    if (!self.suspended) return;
    self.suspended = NO;
    
    if (self.state != BCChatSessionStateIdle && self.state != BCChatSessionStateFinished) {
        [self.chatRecovery start];
    }
    
    if (self.state == BCChatSessionStateCreatingChat) {
        [self.createChatCall resume];
    }else if (self.state == BCChatSessionStateChatting) {
        [(BCChatImpl *)self.chat resume];
    } else if (self.state == BCChatSessionStateSendingPreChatInfo) {
        [self.submitPreChatCall resume];
    } else if (self.state == BCChatSessionStateSendingPostChatInfo) {
        [self.submitPostChatCall resume];
    } else if (self.state == BCChatSessionStateSendingUnavailableInfo) {
        [self.submitUnavailableEmailCall resume];
    }
}

- (id<BCCancelable>)submitUnavailableEmail:(BCForm *)unavailableForm delegate:(id<BCSubmitUnavailableEmailDelegate>)submitUnavailableEmailDelegate {
    self.submitUnavailableEmailDelegate = submitUnavailableEmailDelegate;
    
    if (self.state != BCChatSessionStateUnavailableForm) {
        if (self.state != BCChatSessionStateSendingUnavailableInfo) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.submitUnavailableEmailDelegate bcChatSession:self
                          didFailToSubmitUnavailableEmailWithError:[NSError errorWithDomain:@"BCChatSession"
                                                                                       code:BCChatSessionErrorInvalidState
                                                                     userInfo:@{@"reason" : @"Submit unavailable answers is called not in the suitable state"}]];
                self.submitUnavailableEmailDelegate = nil;
                [self.submitUnavailableEmailCancelable clear];
                self.submitUnavailableEmailCancelable = nil;
            });
        }
        return nil;
    }
    NSArray *requiredButNotFilledFields = [self testFormAnswers:unavailableForm];
    if (requiredButNotFilledFields) {
        NSMutableArray *missingFieldKeys = [NSMutableArray array];
        for (BCFormField *formField in requiredButNotFilledFields) {
            [missingFieldKeys addObject:formField.key];
        }
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.submitUnavailableEmailDelegate bcChatSession:self
                      didFailToSubmitUnavailableEmailWithError:[NSError errorWithDomain:@"BCChatSession"
                                                                         code:BCChatSessionErrorRequiredFieldMissing
                                                                     userInfo:@{@"reason" : @"A required field is not filled",
                                                                                @"missingFieldKeys" : missingFieldKeys}]];
            self.submitUnavailableEmailDelegate = nil;
            [self.submitUnavailableEmailCancelable clear];
            self.submitUnavailableEmailCancelable = nil;
        });
        return nil;
    }
    self.submitUnavailableEmailCancelable = [[BCCancelableImpl alloc] initWithDelegate:self];
    self.state = BCChatSessionStateSendingUnavailableInfo;
    
    self.submitUnavailableEmailCall = [self.connectivityManager submitUnavailableEmailCall];
    self.submitUnavailableEmailCall.chatKey = self.chatKey;
    self.submitUnavailableEmailCall.delegate = self;
    
    self.submitUnavailableEmailCall.from = [unavailableForm formFieldByKey:BCFormFieldEmail].value;
    self.submitUnavailableEmailCall.subject = [unavailableForm formFieldByKey:@"subject"].value;
    self.submitUnavailableEmailCall.body = [unavailableForm formFieldByKey:@"body"].value;
    
    [self.submitUnavailableEmailCall start];
    
    return self.submitUnavailableEmailCancelable;
}

- (void)cancelSubmitUnavailableFormAnswers {
    if (self.state == BCChatSessionStateSendingUnavailableInfo) {
        self.state = BCChatSessionStateUnavailableForm;
        [self.submitUnavailableEmailCall cancel];
        self.submitUnavailableEmailCall = nil;
    }
}

- (id<BCCancelable>)submitPreChat:(BCForm *)preChatForm andStartChatWithDelegate:(id<BCSubmitPreChatDelegate>)submitPreChatDelegate {
    self.submitPreChatDelegate = submitPreChatDelegate;
    if (self.state != BCChatSessionStatePreChatForm) {
        if (self.state != BCChatSessionStateSendingPreChatInfo) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.submitPreChatDelegate bcChatSession:self didFailToSubmitPreChat:[NSError errorWithDomain:@"BCChatSession"
                                                                                                  code:BCChatSessionErrorInvalidState
                                                                                              userInfo:@{@"reason" : @"Pre chat submit is called not in the suitable state"}]];
                self.submitPreChatDelegate = nil;
                [self.submitPreChatCancelable clear];
                self.submitPreChatCancelable = nil;
            });
        }
        return nil;
    }
    NSArray *requiredButNotFilledFields = [self testFormAnswers:preChatForm];
    if (requiredButNotFilledFields && requiredButNotFilledFields.count) {
        NSMutableArray *missingFieldKeys = [NSMutableArray array];
        for (BCFormField *formField in requiredButNotFilledFields) {
            [missingFieldKeys addObject:formField.key];
        }
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.submitPreChatDelegate bcChatSession:self didFailToSubmitPreChat:[NSError errorWithDomain:@"BCChatSession"
                                                                                              code:BCChatSessionErrorRequiredFieldMissing
                                                                                          userInfo:@{@"reason" : @"A required field is not filled",
                                                                                                     @"missingFieldKeys" : missingFieldKeys}]];
            self.submitPreChatDelegate = nil;
            [self.submitPreChatCancelable clear];
            self.submitPreChatCancelable = nil;
        });
        return nil;
    }
    self.submitPreChatCancelable = [[BCCancelableImpl alloc] initWithDelegate:self];
    self.state = BCChatSessionStateSendingPreChatInfo;
    self.submitPreChatCall = [self.connectivityManager submitPreChatCall];
    self.submitPreChatCall.chatKey = self.chatKey;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    self.departmentId = [preChatForm formFieldByKey:BCFormFieldDepartment].value;
    
    for (BCFormField *formField in preChatForm.formFields) {
        if (formField.value && formField.value.length > 0) {
            dictionary[formField.key] = formField.value;
        }
    }
    
    self.submitPreChatCall.data = dictionary;
    self.submitPreChatCall.delegate = self;
    
    [self.submitPreChatCall start];
    return self.submitPreChatCancelable;
}

- (void)cancelSubmitPreChatAnswers {
    if (self.state == BCChatSessionStateSendingPreChatInfo) {
        self.state = BCChatSessionStatePreChatForm;
        [self.submitPreChatCall cancel];
        self.submitPreChatCall = nil;
    }
}

- (id<BCCancelable>)submitPostChat:(BCForm *)postChatForm delegate:(id<BCSubmitPostChatDelegate>)submitPostChatDelegate {
    self.submitPostChatDelegate = submitPostChatDelegate;
    if (self.state != BCChatSessionStatePostChatForm) {
        if (self.state != BCChatSessionStateSendingPostChatInfo) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.submitPostChatDelegate bcChatSession:self
                          didFailToSubmitPostChatWithError:[NSError errorWithDomain:@"BCChatSession"
                                                                               code:BCChatSessionErrorInvalidState
                                                                           userInfo:@{@"reason" : @"Post chat submit is called not in the suitable state"}]];
                self.submitPostChatDelegate = nil;
                [self.submitPostChatCancelable clear];
                self.submitPostChatCancelable = nil;
            });
        }
        return nil;
    }
    NSArray *requiredButNotFilledFields = [self testFormAnswers:postChatForm];
    if (requiredButNotFilledFields && requiredButNotFilledFields.count) {
        NSMutableArray *missingFieldKeys = [NSMutableArray array];
        for (BCFormField *formField in requiredButNotFilledFields) {
            [missingFieldKeys addObject:formField.key];
        }
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.submitPostChatDelegate bcChatSession:self didFailToSubmitPostChatWithError:[NSError errorWithDomain:@"BCChatSession"
                                                                                                                 code:BCChatSessionErrorRequiredFieldMissing
                                                                                                             userInfo:@{@"reason" : @"A required field is not filled",
                                                                                                                        @"missingFieldKeys" : missingFieldKeys}]];
            self.submitPostChatDelegate = nil;
            [self.submitPostChatCancelable clear];
            self.submitPostChatCancelable = nil;
        });
        return nil;
    }
    self.submitPostChatCancelable = [[BCCancelableImpl alloc] initWithDelegate:self];
    self.state = BCChatSessionStateSendingPostChatInfo;
    self.submitPostChatCall = [self.connectivityManager submitPostChatCall];
    self.submitPostChatCall.chatKey = self.chatKey;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (BCFormField *formField in postChatForm.formFields) {
        if (formField.value && formField.value.length > 0) {
            dictionary[formField.key] = formField.value;
        }
    }
    self.submitPostChatCall.data = dictionary;
    self.submitPostChatCall.delegate = self;
    
    [self.submitPostChatCall start];
    return self.submitPostChatCancelable;
}

- (void)cancelSubmitPostChatAnswers {
    if (self.state == BCChatSessionStateSendingPostChatInfo) {
        self.state = BCChatSessionStatePostChatForm;
        [self.submitPostChatCall cancel];
        self.submitPostChatCall = nil;
    }
}

- (id<BCCancelable>)emailChatHistory:(NSString *)emailAddress delegate:(id<BCEmailChatHistoryDelegate>)emailChatHistoryDelegate {
    self.emailChatHistoryDelegate = emailChatHistoryDelegate;
    if (![emailAddress bcIsValidEmailAddress]) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.emailChatHistoryDelegate bcChatSession:self didFailToRequestChatHistoryWithError:[NSError errorWithDomain:@"BCChatSession" code:BCChatSessionErrorInvalidEmailFormat userInfo:@{@"reason" : @"The emai address given is invalid"}]];
            self.emailChatHistoryDelegate = nil;
            [self.emailChatHistoryCancelable clear];
            self.emailChatHistoryCancelable = nil;
        });
    } else if (self.chatKey) {
        self.emailChatHistoryCancelable = [[BCCancelableImpl alloc] initWithDelegate:self];
        self.emailChatHistoryCall = [self.connectivityManager emailChatHistoryCall];
        self.emailChatHistoryCall.chatKey = self.chatKey;
        self.emailChatHistoryCall.emailAddress = emailAddress;
        self.emailChatHistoryCall.delegate = self;
        [self.emailChatHistoryCall start];
        return self.emailChatHistoryCancelable;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.emailChatHistoryDelegate bcChatSession:self didFailToRequestChatHistoryWithError:[NSError errorWithDomain:@"BCChatSession" code:BCChatSessionErrorInvalidState userInfo:@{@"reason" : @"Request history is called not in the suitable state"}]];
            self.emailChatHistoryDelegate = nil;
            [self.emailChatHistoryCancelable clear];
            self.emailChatHistoryCancelable = nil;
        });
    }
    return nil;
}

- (void)cancelRequestChatHistoryInEmail {
    [self.emailChatHistoryCall cancel];
    self.emailChatHistoryCall = nil;
}

- (id<BCCancelable>)changeLanguage:(NSString *)languageString delegate:(id<BCChangeLanguageDelegate>)changeLanguageDelegate {
    self.changeLanguageDelegate = changeLanguageDelegate;
    if (languageString.length && ![self.language isEqualToString:languageString]) {
        if (self.state == BCChatSessionStateIdle) {
            self.language = languageString;
            return nil;
        } else {
            self.emailChatHistoryCancelable = [[BCCancelableImpl alloc] initWithDelegate:self];
            self.changeLanguageCall = [self.connectivityManager changeLanguageCall];
            self.changeLanguageCall.chatKey = self.chatKey;
            self.changeLanguageCall.language = languageString;
            self.changeLanguageCall.delegate = self;
            [self.changeLanguageCall start];
            return self.emailChatHistoryCancelable;
        }
    }
    return nil;
}

- (void)cancelChangeLanguage {
    [self.changeLanguageCall cancel];
    self.changeLanguageCall = nil;
}


- (NSError *)errorFromMessage:(NSString *)message {
    NSInteger errorCode = BCGeneralUnknownError;
    if ([message isEqualToString:@"No chat api settings found"]) {
        errorCode = BCGeneralInvalidAccessKeyError;
    } else if ([message isEqualToString:@"Not authorized"]) {
        errorCode = BCGeneralInvalidAccessKeyError;
    } else if ([message isEqualToString:@"Invalid DepartmentID"]) {
        errorCode = BCChatSessionErrorInvalidDepartmentId;
    } if ([message rangeOfString:@"Visitor"].location != NSNotFound) {
        errorCode = BCChatSessionErrorInvalidVisitorId;
    } if ([message isEqualToString:@"Invalid ChatWindowID"]) {
        errorCode = BCGeneralInvalidAccessKeyError;
    } if ([message isEqualToString:@"Invalid WebsiteID"]) {
        errorCode = BCGeneralInvalidAccessKeyError;
    } if ([message isEqualToString:@"Invalid ChatKey"]) {
        errorCode = BCChatSessionErrorInvalidChatKey;
    }
    return [NSError errorWithDomain:@"BCChatSession" code:errorCode userInfo:@{@"reason" : message, @"localisedReason" : message}];
}

- (BCUnavailableReason)unavailableReasonFromString:(NSString *)string {
    BCUnavailableReason reason = BCUnavailableReasonUnknown;
    if ([string isEqualToString:@"queue_full"]) {
        reason = BCUnavailableReasonQueueFull;
    } else if ([string isEqualToString:@"no_operators"]) {
        reason = BCUnavailableReasonNoOperators;
    } else if ([string isEqualToString:@"visitor_blocked"]) {
        reason = BCUnavailableReasonVisitorBlocked;
    } else if ([string isEqualToString:@"outside_hours"]) {
        reason = BCUnavailableReasonOutsideHours;
    } else if ([string isEqualToString:@"unsecure"]) {
        reason = BCUnavailableReasonUnsecure;
    }
    return reason;
}

- (NSArray *)testFormAnswers:(BCForm *)formDescription {
    NSMutableArray *notAnsweredRequiredFields = [NSMutableArray array];
    
    for (BCFormField *field in formDescription.formFields) {
        if (field.isRequired) {
            if (field.value == nil || field.value.length <= 0) {
                [notAnsweredRequiredFields addObject:field];
            } else if (field.type == BCFormFieldTypeEmail && ![field.value bcIsValidEmailAddress]) {
                [notAnsweredRequiredFields addObject:field];
            } else if (field.type == BCFormFieldTypePhone && ![field.value bcIsValidPhoneNumber]) {
                [notAnsweredRequiredFields addObject:field];
            }
            
        } else {
            if (field.type == BCFormFieldTypeEmail && field.value && field.value.length > 0 && ![field.value bcIsValidEmailAddress]) {
                [notAnsweredRequiredFields addObject:field];
            } else if (field.type == BCFormFieldTypePhone && field.value && field.value.length > 0 && ![field.value bcIsValidPhoneNumber]) {
                [notAnsweredRequiredFields addObject:field];
            }
        }
    }
    return notAnsweredRequiredFields.count ? notAnsweredRequiredFields : nil;
}

#pragma mark -
#pragma mark BCChatStateDelegate
- (void)bcChatDidConnect:(id<BCChat>)chat {
    
}

- (void)bcChatDidAccept:(id<BCChat>)chat {
    
}

- (void)bcChat:(id<BCChat>)chat didFinishWithReason:(BCChatEndReason)reason time:(NSDate *)date postChatForm:(BCForm *)postChatForm {
    self.postChatForm = postChatForm;
    BOOL needsPostChat = (postChatForm && postChatForm.formFields.count > 0);
    self.state = needsPostChat ? BCChatSessionStatePostChatForm : BCChatSessionStateFinished;
    if (!needsPostChat) {
        [self.chatRecovery sendClosedAndStop];
    }
}

- (void)bcChat:(id<BCChat>)chat didFinishWithUnavailableReason:(BCUnavailableReason)reason unavailableForm:(BCForm *)unavailableForm unavailableMessage:(NSString *)message {
    self.unavailableForm = unavailableForm;
    if (unavailableForm.formFields.count) {
        self.state = BCChatSessionStateUnavailableForm;
    } else {
        self.state = BCChatSessionStateFinished;
        [self.chatRecovery sendClosedAndStop];
    }
    self.unavailableReason = reason;
    self.unavailableMessage = message;
}

- (void)bcChat:(id<BCChat>)chat didFinishWithError:(NSError *)error {
    
}


#pragma mark -
#pragma mark BCCreateChatCallDelegate
- (void)bcCreateChatCall:(BCCreateChatCall *)createChatCall didFinishWithResult:(BCCreateChatCallResult *)result {
    if (result.statusSuccess) {
        self.language = result.language;
        self.chatId = result.chatId;
        self.chatKey = result.chatKey;
        self.visitor.personId = result.visitorId;
        self.clientId = result.clientId;
        self.branding = result.brandings;
        if (result.name) self.visitor.name = result.name;
        
        self.chatRecovery = [[BCChatRecovery alloc] init];
        self.chatRecovery.delegate = self;
        self.chatRecovery.connectivityManager = self.connectivityManager;
        self.chatRecovery.chatKey = self.chatKey;
        [self.chatRecovery start];
        
        if (result.unavailableReason != nil) {
            if (result.unavailableForm.count) {
                self.state = BCChatSessionStateUnavailableForm;
                self.unavailableForm = [[BCForm alloc] initWithFormFields:result.unavailableForm];
            } else {
                self.state = BCChatSessionStateFinished;
                [self.chatRecovery sendClosedAndStop];
            }
            self.unavailableReason = [self unavailableReasonFromString:result.unavailableReason];
            self.unavailableMessage = result.errorMessage;
            [self.createChatDelegate bcChatSessionImpl:self didCreateUnavailableWithReason:self.unavailableReason unavailableForm:self.unavailableForm unavailableMessage:self.unavailableMessage];
        } else if (result.preChat && result.preChat.count) {
            self.state = BCChatSessionStatePreChatForm;
            self.preChatForm = [[BCForm alloc] initWithFormFields:result.preChat];
            [self.createChatDelegate bcChatSessionImpl:self didCreateWithPreChat:self.preChatForm];
        } else {
            self.state = BCChatSessionStateChatting;
            self.chat = [[BCChatImpl alloc] initWithChatId:self.chatId chatKey:self.chatKey clientId:self.clientId visitor:self.visitor connectivityManager:self.connectivityManager webSocketUrl:result.webSocketURL longPollUrl:result.longPollURL clientTimeout:result.clientTimeout answerTimeout:result.answerTimeout];
            [self.chat addChatStateDelegate:self];
            ((BCChatImpl *)self.chat).language = self.language;
            [((BCChatImpl *)self.chat) startChat];
            [self.createChatDelegate bcChatSessionImplDidCreateWithoutPreChat:self];
        }
    } else {
        self.state = BCChatSessionStateIdle;
        NSError *error = [self errorFromMessage:result.errorMessage];
        [self.createChatDelegate bcChatSessionImpl:self didFailToCreateWithError:error];
    }
}

- (void)bcCreateChatCall:(BCCreateChatCall *)createChatCall didFinishWithError:(NSError *)error {
    self.state = BCChatSessionStateIdle;
    [self.createChatDelegate bcChatSessionImpl:self didFailToCreateWithError:error];
}

#pragma mark -
#pragma mark BCSubmitUnavailableEmailCallDelegate
- (void)bcSubmitUnavailableEmailCall:(BCSubmitUnavailableEmailCall *)submitUnavailableEmailCall didFinishWithResult:(BCSubmitUnavailableEmailCallResult *)result {
    self.submitUnavailableEmailCall = nil;
    if (result.statusSuccess) {
        [self.chatRecovery sendClosedAndStop];
        self.state = BCChatSessionStateFinished;
        [self.submitUnavailableEmailDelegate bcChatSessionDidSubmitUnavailableEmail:self];
    } else {
        self.state = BCChatSessionStateUnavailableForm;
        [self.submitUnavailableEmailDelegate bcChatSession:self didFailToSubmitUnavailableEmailWithError:[self errorFromMessage:result.errorMessage]];
    }
    self.submitUnavailableEmailDelegate = nil;
    [self.submitUnavailableEmailCancelable clear];
    self.submitUnavailableEmailCancelable = nil;
}

- (void)bcSubmitUnavailableEmailCall:(BCSubmitUnavailableEmailCall *)submitUnavailableEmailCall didFinishWithError:(NSError *)error {
    self.state = BCChatSessionStateUnavailableForm;
    [self.submitUnavailableEmailDelegate bcChatSession:self didFailToSubmitUnavailableEmailWithError:error];
    self.submitUnavailableEmailDelegate = nil;
    [self.submitUnavailableEmailCancelable clear];
    self.submitUnavailableEmailCancelable = nil;
}

#pragma mark -
#pragma mark BCSubmitPreChatCallDelegate
- (void)bcSubmitPreChatCall:(BCSubmitPreChatCall *)submitPreChatCall didFinishWithResult:(BCSubmitPreChatCallResult *)result {
    if (result.statusSuccess) {
        if (result.name) self.visitor.name = result.name;
        if (result.unavailableReason != nil) {
            self.clientId = result.clientId;
            if (result.unavailableForm.count) {
                self.state = BCChatSessionStateUnavailableForm;
                self.unavailableForm = [[BCForm alloc] initWithFormFields:result.unavailableForm];
            } else {
                self.state = BCChatSessionStateFinished;
                [self.chatRecovery sendClosedAndStop];
            }
            self.unavailableReason = [self unavailableReasonFromString:result.unavailableReason];
            self.unavailableMessage = result.errorMessage;
            [self.submitPreChatDelegate bcChatSession:self didSubmitPreChatToUnavailableChatWithReason:self.unavailableReason unavailableForm:self.unavailableForm unavailableMessage:self.unavailableMessage];
        } else {
            self.clientId = result.clientId;
            self.state = BCChatSessionStateChatting;
            self.chat = [[BCChatImpl alloc] initWithChatId:self.chatId chatKey:self.chatKey clientId:self.clientId visitor:self.visitor connectivityManager:self.connectivityManager webSocketUrl:result.webSocketURL longPollUrl:result.longPollURL clientTimeout:result.clientTimeout answerTimeout:result.answerTimeout];
            ((BCChatImpl *)self.chat).language = self.language;
            [self.chat addChatStateDelegate:self];
            [((BCChatImpl *)self.chat) startChat];
            [self.submitPreChatDelegate bcChatSessionDidSubmitPreChat:self andDidStartChat:self.chat];
        }
    } else {
        self.state = BCChatSessionStatePreChatForm;
        NSError *error = [self errorFromMessage:result.errorMessage];
        [self.submitPreChatDelegate bcChatSession:self didFailToSubmitPreChat:error];
    }
    self.submitPreChatCancelable = nil;
    [self.submitPreChatCancelable clear];
    self.submitPreChatCancelable = nil;
}

- (void)bcSubmitPreChatCall:(BCSubmitPreChatCall *)submitPreChatCall didFinishWithError:(NSError *)error {
    self.state = BCChatSessionStatePreChatForm;
    [self.submitPreChatDelegate bcChatSession:self didFailToSubmitPreChat:error];
    self.submitPreChatDelegate = nil;
    [self.submitPreChatCancelable clear];
    self.submitPreChatCancelable = nil;
}

#pragma mark -
#pragma mark BCSubmitPostChatCallDelegate
- (void)bcSubmitPostChatCall:(BCSubmitPostChatCall *)submitPostChatCall didFinishWithResult:(BCSubmitPostChatCallResult *)result {
    if (result.statusSuccess) {
        [self.chatRecovery sendClosedAndStop];
        self.state = BCChatSessionStateFinished;
        [self.submitPostChatDelegate bcChatSessionDidSubmitPostChat:self];
        
    } else {
        self.state = BCChatSessionStatePostChatForm;
        NSError *error = [self errorFromMessage:result.errorMessage];
        [self.submitPostChatDelegate bcChatSession:self didFailToSubmitPostChatWithError:error];
    }
    self.submitPostChatDelegate = nil;
    [self.submitPostChatCancelable clear];
    self.submitPostChatCancelable = nil;
}

- (void)bcSubmitPostChatCall:(BCSubmitPostChatCall *)submitPostChatCall didFinishWithError:(NSError *)error {
    self.state = BCChatSessionStatePostChatForm;
    [self.submitPostChatDelegate bcChatSession:self didFailToSubmitPostChatWithError:error];
    self.submitPostChatDelegate = nil;
    [self.submitPostChatCancelable clear];
    self.submitPostChatCancelable = nil;
}

#pragma mark -
#pragma mark BCEmailChatHistoryCallDelegate
- (void)bcEmailChatHistoryCall:(BCEmailChatHistoryCall *)emailChatHistoryCall didFinishWithResult:(BCEmailChatHistoryCallResult *)result {
    if (result.statusSuccess) {
        [self.emailChatHistoryDelegate bcChatSessionDidRequestChatHistory:self];
    } else {
        self.state = BCChatSessionStatePostChatForm;
        NSError *error = [self errorFromMessage:result.errorMessage];
        [self.emailChatHistoryDelegate bcChatSession:self didFailToRequestChatHistoryWithError:error];
    }
    self.emailChatHistoryDelegate = nil;
    [self.emailChatHistoryCancelable clear];
    self.emailChatHistoryCancelable = nil;
}

- (void)bcEmailChatHistoryCall:(BCEmailChatHistoryCall *)emailChatHistoryCall didFinishWithError:(NSError *)error {
    [self.emailChatHistoryDelegate bcChatSession:self didFailToRequestChatHistoryWithError:error];
    self.emailChatHistoryDelegate = nil;
    [self.emailChatHistoryCancelable clear];
    self.emailChatHistoryCancelable = nil;
}

#pragma mark -
#pragma mark BCChangeLanguageCallDelegate
- (void)bcChangeLanguageCall:(BCChangeLanguageCall *)changeLanguageCall didFinishWithResult:(BCChangeLanguageCallResult *)result {
    self.branding = result.brandings;
    self.language = result.language;
    if (result.statusSuccess) {
        [self.changeLanguageDelegate bcChatSession:self didChangeToLanguage:result.language withBranding:result.brandings];
    } else {
        [self.changeLanguageDelegate bcChatSession:self didFailToChangeLanguageWithError:[self errorFromMessage:result.errorMessage]];
    }
    self.changeLanguageDelegate = nil;
    [self.changeLanguageCancelable clear];
    self.changeLanguageCancelable = nil;
}

- (void)bcChangeLanguageCall:(BCChangeLanguageCall *)changeLanguageCall didFinishWithError:(NSError *)error {
    [self.changeLanguageDelegate bcChatSession:self didFailToChangeLanguageWithError:error];
    self.changeLanguageDelegate = nil;
    [self.changeLanguageCancelable clear];
    self.changeLanguageCancelable = nil;
}

#pragma mark -
#pragma mark BCChatRecoveryDelegate
- (void)bcChatRecovery:(BCChatRecovery *)chatRecovery didReceiveRecaptureAvailable:(BOOL)recaptureAvailable {
    self.recaptureAvailable = recaptureAvailable;
    if (self.state == BCChatSessionStateChatting ||
        self.state == BCChatSessionStateUnavailableForm ||
        self.state == BCChatSessionStateSendingUnavailableInfo) {
        if (recaptureAvailable) {
            [self.chatRecaptureDelegate bcChatSessionRecaptureAvailable:self];
        }
    }
}

#pragma mark -
#pragma mark BCCancelableImplDelegate

- (void)bcCancelableImplDidCancel:(BCCancelableImpl *)cancelableImpl {
    if (cancelableImpl == self.submitUnavailableEmailCancelable) {
        [self cancelSubmitUnavailableFormAnswers];
        self.submitUnavailableEmailDelegate = nil;
        [self.submitUnavailableEmailCancelable clear];
        self.submitUnavailableEmailCancelable = nil;
    } else if (cancelableImpl == self.submitPreChatCancelable) {
        [self cancelSubmitPreChatAnswers];
        self.submitPreChatDelegate = nil;
        [self.submitPreChatCancelable clear];
        self.submitPreChatCancelable = nil;
    } else if (cancelableImpl == self.submitPostChatCancelable) {
        [self cancelSubmitPostChatAnswers];
        self.submitPostChatDelegate = nil;
        [self.submitPostChatCancelable clear];
        self.submitPostChatCancelable = nil;
    } else if (cancelableImpl == self.emailChatHistoryCancelable) {
        [self cancelRequestChatHistoryInEmail];
        self.emailChatHistoryDelegate = nil;
        [self.emailChatHistoryCancelable clear];
        self.emailChatHistoryCancelable = nil;
    } else if (cancelableImpl == self.changeLanguageCancelable) {
        [self cancelChangeLanguage];
        self.emailChatHistoryDelegate = nil;
        [self.changeLanguageCancelable clear];
        self.changeLanguageCancelable = nil;
    }
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
    self.chatRecovery.delegate = nil;
    [self.chatRecovery sendClosedAndStop];
    [self.createChatCall cancel];
    [self.submitUnavailableEmailCall cancel];
    [self.submitPreChatCall cancel];
    [self.submitPostChatCall cancel];
    [self.emailChatHistoryCall cancel];
}

@end
