//
//  BCAccount.m
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCAccount.h"
#import "BCChatSessionImpl.h"
#import "BCPerson.h"
#import "BCChatAvailabilityChecker.h"
#import "BCConnectivityManager.h"
#import "BCCancelableImpl.h"
#import "NSMutableArray+nonRetaining.h"
#import "NSString+BCValidation.h"

NSString *const BCFormFieldLanguage = @"language";
NSString *const BCFormFieldDepartment = @"department";
NSString *const BCFormFieldFirstName = @"first_name";
NSString *const BCFormFieldName = @"name";
NSString *const BCFormFieldLastName = @"last_name";
NSString *const BCFormFieldPhone = @"phone";
NSString *const BCFormFieldEmail = @"email";
NSString *const BCFormFieldInitialQuestion = @"initial_question";
NSString *const BCFormFieldReference = @"reference";
NSString *const BCFormFieldInformation = @"information";
NSString *const BCFormFieldOverall = @"overall";
NSString *const BCFormFieldKnowledge = @"knowledge";
NSString *const BCFormFieldResponsiveness = @"responsiveness";
NSString *const BCFormFieldProfessionalism = @"professionalism";
NSString *const BCFormFieldComments = @"comments";
NSString *const BCFormFieldCustomUrl = @"CustomUrl";

/**
 BCAccount private interface.
 @since Version 1.0
 */
@interface BCAccount () <BCCancelableImplDelegate, BCChatSessionImplCreationDelegate>

/**
 The access key for the SDK.
 @since Version 1.0
 */
@property (nonatomic, copy) NSString *accessKey;

/**
 Connectivity manager for the network calls. The same connectivity manager is used for the chat sessions and the availability ckeckers.
 @since Version 1.0
 */
@property (nonatomic, strong) BCConnectivityManager *connectivityManager;

/**
 The availability checkers per visitorId.
 @since Version 1.0
 */
@property (nonatomic, strong) NSMutableDictionary *availabilityCheckers;

/**
 The chat session being created.
 @since Version 1.0
 */
@property (nonatomic, strong) NSMutableArray *chatSessionsBeingCreated;

/**
 The chat session being created.
 @since Version 1.0
 */
@property (nonatomic, strong) NSMutableArray *cancelablesOfChatSessions;

/**
 The create chat delegates.
 @since Version 1.0
 */
@property (nonatomic, strong) NSMutableArray *createChatDelegates;


@end

@implementation BCAccount

@synthesize accessKey = _accessKey;
@synthesize connectivityManager = _connectivityManager;
@synthesize availabilityCheckers = _availabilityCheckers;
@synthesize chatSessionsBeingCreated = _chatSessionsBeingCreated;
@synthesize cancelablesOfChatSessions = _cancelablesOfChatSessions;
@synthesize createChatDelegates = _createChatDelegates;

+ (id)accountWithAccessKey:(NSString *)accessKey {
    return [[[self class] alloc] initWithAccessKey:accessKey];
}

- (id)initWithAccessKey:(NSString *)accessKey{
    if ((self = [super init])) {
        self.accessKey = accessKey;
        self.availabilityCheckers = [[NSMutableDictionary alloc] init];
        self.chatSessionsBeingCreated = [[NSMutableArray alloc] init];
        self.cancelablesOfChatSessions = [[NSMutableArray alloc] init];
        self.createChatDelegates = [NSMutableArray bcNonRetainingArrayWithCapacity:2];
        
        NSArray *stringComponents = [accessKey componentsSeparatedByString:@":"];
        NSString *accountId = stringComponents[0];
        NSString *serverSet = nil;
        
        NSMutableArray *accessKeyArray = [NSMutableArray arrayWithArray:stringComponents];
        
        BOOL accountIsNotInUS = (stringComponents.count > 3);
        if(accountIsNotInUS) {
            serverSet = stringComponents[3];
            //remove the server set part
            [accessKeyArray removeObjectAtIndex:3];
        }
        
        //remove the account id part
        [accessKeyArray removeObjectAtIndex:0];
        NSString *accessKeyPart = [accessKeyArray componentsJoinedByString:@":"];
        
        self.connectivityManager = [[BCConnectivityManager alloc] init];
        self.connectivityManager.accountId = accountId;
        self.connectivityManager.accessKey = accessKeyPart;
        self.connectivityManager.serverSet = serverSet;
    }
    return self;
}

/* Chat session creation */
- (id<BCCancelable>)createChatSessionWithDelegate:(id<BCCreateChatSessionDelegate>)delegate language:(NSString *)language {
    return [self createChatSessionWithDelegate:delegate language:language visitorId:nil skipPreChat:NO externalParams:nil];
}

- (id<BCCancelable>)createChatSessionWithDelegate:(id<BCCreateChatSessionDelegate>)delegate language:(NSString *)language visitorId:(NSString *)visitorId skipPreChat:(BOOL)skipPreChat externalParams:(NSDictionary *)externalParams {
    if (externalParams && externalParams[BCFormFieldEmail]) {
        NSString *emailString = externalParams[BCFormFieldEmail];
        if (![emailString bcIsValidEmailAddress]) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [delegate bcAccount:self didFailToCreateWithError:[NSError errorWithDomain:@"BCAccount" code:BCChatSessionErrorInvalidEmailFormat userInfo:@{@"reason": @"Invalid email format"}]];
            });
            return nil;
        }
    }
    if (externalParams && externalParams[BCFormFieldPhone]) {
        NSString *phoneString = externalParams[BCFormFieldPhone];
        if (![phoneString bcIsValidPhoneNumber]) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [delegate bcAccount:self didFailToCreateWithError:[NSError errorWithDomain:@"BCAccount" code:BCChatSessionErrorInvalidPhoneFormat userInfo:@{@"reason": @"Invalid phone format"}]];
            });
            return nil;
        }
    }
    
    BCCancelableImpl *cancelable = [[BCCancelableImpl alloc] initWithDelegate:self];
    BCChatSessionImpl *chatSessionImp = [BCChatSessionImpl chatSessionImplWithAccountId:self.connectivityManager.accountId accessKey:self.connectivityManager.accessKey connectivityManager:self.connectivityManager language:language visitorId:visitorId skipPreChat:skipPreChat data:externalParams];
    
    [self.cancelablesOfChatSessions addObject:cancelable];
    [self.chatSessionsBeingCreated addObject:chatSessionImp];
    [self.createChatDelegates addObject:delegate];
    
    [chatSessionImp createChatWithDelegate:self];
    return cancelable;
}

- (id<BCCancelable>)getChatAvailabilityWithDelegate:(id<BCChatAvailabilityDelegate>)delegate {
    return [self getChatAvailabilityWithDelegate:delegate visitorId:nil];
}

- (id<BCCancelable>)getChatAvailabilityWithDelegate:(id<BCChatAvailabilityDelegate>)delegate visitorId:(NSString *)visitorId {
    BCChatAvailabilityChecker *checker = self.availabilityCheckers[visitorId ? visitorId : [NSNull null]];
    if (!checker) {
        checker = [[BCChatAvailabilityChecker alloc] initWithConnectivityManager:self.connectivityManager visitorId:visitorId];
        self.availabilityCheckers[visitorId ? visitorId : [NSNull null]] = checker;
    }
    BCCancelableImpl *cancelable = [[BCCancelableImpl alloc] initWithDelegate:checker];
    [checker requestAvailabilityWithCancelable:cancelable delegate:delegate];
    return cancelable;
}

- (NSString *)versionString {
    NSString *serverId = nil;

#if _PROD_BUILD
    serverId = @"prod";
#else
    serverId = @"selector";
#endif
    
    BOOL debug = NO;
#if DEBUG
    debug = YES;
#endif
    
#define xstr(s) str(s)
#define str(s) #s
    
    NSString *commitId = @"";
    NSString *boldSdkVersion = @"";
#ifdef _GIT_COMMIT_ID
    char * gitCommitId = xstr(_GIT_COMMIT_ID);
    commitId = [NSString stringWithUTF8String:gitCommitId];
#endif

#ifdef _BOLD_SDK_VERSION
    char * boldSdkVersionCSTR = xstr(_BOLD_SDK_VERSION);
    boldSdkVersion = [NSString stringWithUTF8String:boldSdkVersionCSTR];
#endif


    
#undef xstr
#undef str
    
    return [NSString stringWithFormat:@"Version %@ %@ %@ %@", boldSdkVersion, commitId, serverId, debug ? @"debug" : @"release"];
}

#pragma mark -
#pragma mark BCCancelableImplDelegate

- (void)bcCancelableImplDidCancel:(BCCancelableImpl *)cancelableImpl {
    NSUInteger index = [self.cancelablesOfChatSessions indexOfObject:cancelableImpl];
    if (index != NSNotFound ) {
        BCCancelableImpl *cancelable = ((BCCancelableImpl *)(self.cancelablesOfChatSessions[index]));
        [cancelable clear];
        [self.cancelablesOfChatSessions removeObjectAtIndex:index];
        [self.chatSessionsBeingCreated removeObjectAtIndex:index];
        [self.createChatDelegates removeObjectAtIndex:index];
    }
}

#pragma mark -
#pragma mark BCChatSessionImplCreationDelegate
- (void)bcChatSessionImplDidCreateWithoutPreChat:(BCChatSessionImpl *)chatSession {
    NSUInteger index = [self.chatSessionsBeingCreated indexOfObject:chatSession];
    if (index != NSNotFound ) {
        id<BCCreateChatSessionDelegate> delegate = self.createChatDelegates[index];
        [delegate bcAccount:self didCreateChatWithoutPreChat:chatSession andDidStartChat:chatSession.chat];
        
        BCCancelableImpl *cancelable = ((BCCancelableImpl *)(self.cancelablesOfChatSessions[index]));
        [cancelable clear];
        [self.cancelablesOfChatSessions removeObjectAtIndex:index];
        [self.chatSessionsBeingCreated removeObjectAtIndex:index];
        [self.createChatDelegates removeObjectAtIndex:index];
    }
}

- (void)bcChatSessionImpl:(BCChatSessionImpl *)chatSession didCreateWithPreChat:(BCForm *)preChat {
    NSUInteger index = [self.chatSessionsBeingCreated indexOfObject:chatSession];
    if (index != NSNotFound ) {
        id<BCCreateChatSessionDelegate> delegate = self.createChatDelegates[index];
        [delegate bcAccount:self didCreateChat:chatSession withPreChat:preChat];
        
        BCCancelableImpl *cancelable = ((BCCancelableImpl *)(self.cancelablesOfChatSessions[index]));
        [cancelable clear];
        [self.cancelablesOfChatSessions removeObjectAtIndex:index];
        [self.chatSessionsBeingCreated removeObjectAtIndex:index];
        [self.createChatDelegates removeObjectAtIndex:index];
    }
}

- (void)bcChatSessionImpl:(BCChatSessionImpl *)chatSession didCreateUnavailableWithReason:(BCUnavailableReason)reason unavailableForm:(BCForm *)unavailableForm unavailableMessage:(NSString *)message {
    NSUInteger index = [self.chatSessionsBeingCreated indexOfObject:chatSession];
    if (index != NSNotFound ) {
        id<BCCreateChatSessionDelegate> delegate = self.createChatDelegates[index];
        [delegate bcAccount:self didCreateChat:chatSession unavailableWithReason:reason unavailableForm:unavailableForm unavailableMessage:message];
        
        BCCancelableImpl *cancelable = ((BCCancelableImpl *)(self.cancelablesOfChatSessions[index]));
        [cancelable clear];
        [self.cancelablesOfChatSessions removeObjectAtIndex:index];
        [self.chatSessionsBeingCreated removeObjectAtIndex:index];
        [self.createChatDelegates removeObjectAtIndex:index];
    }
}

- (void)bcChatSessionImpl:(BCChatSessionImpl *)chatSession didFailToCreateWithError:(NSError *)error {
    NSUInteger index = [self.chatSessionsBeingCreated indexOfObject:chatSession];
    if (index != NSNotFound ) {
        id<BCCreateChatSessionDelegate> delegate = self.createChatDelegates[index];
        [delegate bcAccount:self didFailToCreateWithError:error];
        
        BCCancelableImpl *cancelable = ((BCCancelableImpl *)(self.cancelablesOfChatSessions[index]));
        [cancelable clear];
        [self.cancelablesOfChatSessions removeObjectAtIndex:index];
        [self.chatSessionsBeingCreated removeObjectAtIndex:index];
        [self.createChatDelegates removeObjectAtIndex:index];
    }
}

@end

@implementation BCAccount (ServerSet)

- (NSString *)serverSet {
#if _PROD_BUILD
    return nil;
#else
    NSString *serverSetString = [[self connectivityManager] serverSet];
    return serverSetString;
#endif
}

- (void)setServerSet:(NSString *)serverSet {
#if !_PROD_BUILD
    [[self connectivityManager] setServerSet:serverSet];
#endif
    
}

@end
