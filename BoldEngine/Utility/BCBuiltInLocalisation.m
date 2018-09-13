//
//  BCBuiltInLocalisation.m
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCBuiltInLocalisation.h"

@implementation BCBuiltInLocalisation

+ (NSString *)localisedStringForChatTitleWithLanguage:(NSString *)language {
    if ([language hasPrefix:@"pt"]) {
        return @"Bate-papo";
    } else {
        return @"Chat";
    }
}

+ (NSString *)localisedStringForNetworkErrorWithLanguage:(NSString *)language {
    return @"There was a network problem, unable to contact chat servers.";
}


@end
