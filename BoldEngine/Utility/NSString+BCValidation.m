//
//  NSString+BCEmailAddressValidation.m
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import <BoldEngine/NSString+BCValidation.h>

@implementation NSString (BCEmailAddressValidation)

- (BOOL)bcIsValidEmailAddress {
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)bcIsValidPhoneNumber {
    NSString *phoneRegex = @"([-+*#,;()0-9])*";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL matches = [test evaluateWithObject:self];
    return matches;
}

- (BOOL)bcIsValidAlphabets {
    NSString *abnRegex = @"[A-Za-z]+";
    NSPredicate *abnTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", abnRegex];
    BOOL isValid = [abnTest evaluateWithObject:self];
    return isValid;
}

@end
