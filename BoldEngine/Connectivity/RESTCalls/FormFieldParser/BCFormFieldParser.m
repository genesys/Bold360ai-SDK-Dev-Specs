//
//  BCFormFieldParser.m
//  VisitorSDK
//
//  Created by Viktor Fabian on 4/10/14.
//  Copyright (c) 2014 LogMeIn Inc. All rights reserved.
//

#import "BCFormFieldParser.h"
#import "NSObject+nilOrValue.h"

@implementation BCFormFieldParser

+ (BCFormField *)formField:(NSDictionary *)formField {
    if (!formField) return nil;
    BCFormFieldType type = [self chatItemTypeForDictionary:formField key:@"Type"];
    NSString *key = [formField[@"Key"] bcNilOrStringValue];
    BOOL multiline = [formField[@"MultiLine"] bcNilOrBoolValue];
    NSString *label = [formField[@"Label"] bcNilOrStringValue];
    NSString *labelBranding = [formField[@"LabelBranding"] bcNilOrStringValue];
    BOOL required = [formField[@"Required"] bcNilOrBoolValue];
    BOOL showSelector = formField[@"ShowSelector"] ? [formField[@"ShowSelector"] bcNilOrBoolValue] : YES;
    BOOL showDepartmentStatus = [formField[@"ShowDepartmentStatus"] bcNilOrBoolValue];
    NSString *defaultValue = [formField[@"Value"] bcNilOrStringValue];
    NSArray *options = [self formFieldOptions:formField[@"Options"]];
    
    BCFormField *field = [BCFormField formFieldWithType:type
                                                    key:key
                                              isMultiline:multiline
                                                  label:label
                                       labelBrandingKey:labelBranding
                                               isRequired:required
                                              isVisible:showSelector
                                    isDepartmentStatusVisible:showDepartmentStatus
                                           defaultValue:defaultValue
                                                options:[options copy]];
    
    return field;
}

+ (NSArray *)formFields:(NSArray *)formFields {
    if (!formFields) return nil;
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in formFields) {
        [array addObject:[self formField:dict]];
    }
    return [array copy];
}

+ (BCFormFieldOption *)formFieldOption:(NSDictionary *)formOption {
    if (!formOption) return nil;
    NSString *name = [formOption[@"Name"] bcNilOrStringValue];
    NSString *value = [formOption[@"Value"] bcNilOrStringValue];
    NSString *nameBrandingKey = [formOption[@"NameBrandingKey"] bcNilOrStringValue];
    BOOL isDefault = [formOption[@"Default"] bcNilOrBoolValue];
    BOOL availiblitySet = (formOption[@"Available"] && formOption[@"AvailableLabel"]);
    BOOL available = [formOption[@"Available"] bcNilOrBoolValue];
    NSString *availableLabel = [formOption[@"AvailableLabel"] bcNilOrStringValue];
    
    BCFormFieldOption *option = nil;
    if (availiblitySet) {
        option = [[BCFormFieldOption alloc] initWithName:name value:value nameBrandingKey:nameBrandingKey isDefaultValue:isDefault isAvailable:available availableLabel:availableLabel];
    } else {
        option = [[BCFormFieldOption alloc] initWithName:name value:value nameBrandingKey:nameBrandingKey isDefaultValue:isDefault];
    }
    return option;
}

+ (NSArray *)formFieldOptions:(NSArray *)formOptions {
    if (!formOptions) return nil;
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in formOptions) {
        [array addObject:[self formFieldOption:dict]];
    }
    return [array copy];
}

+ (BCFormFieldType)chatItemTypeForDictionary:(NSDictionary *)dictionary key:(NSString *)key {
    BCFormFieldType type = BCFormFieldTypeText;
    NSString *typeString = dictionary[key];
    
    if (typeString) {
        if ([typeString isEqualToString:@"text"]) {
            type = BCFormFieldTypeText;
        } else if ([typeString isEqualToString:@"phone"]) {
            type =BCFormFieldTypePhone;
        } else if ([typeString isEqualToString:@"email"]) {
            type = BCFormFieldTypeEmail;
        } else if ([typeString isEqualToString:@"select"]) {
            type = BCFormFieldTypeSelect;
        } else if ([typeString isEqualToString:@"rating"]) {
            type = BCFormFieldTypeRating;
        } else if ([typeString isEqualToString:@"radio"]) {
            type = BCFormFieldTypeRadio;
        }
        
    }
    return type;
}

@end
