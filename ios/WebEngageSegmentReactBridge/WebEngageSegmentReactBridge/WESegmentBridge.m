#import "WESegmentBridge.h"
#import <React/RCTLog.h>
#import <React/RCTConvert.h>
#import <React/RCTBundleURLProvider.h>
#import "WebEngage/WebEngage.h"
#import "WEGSegmentIntegrationFactory.h"

@implementation WESegmentBridge


RCT_EXPORT_MODULE();

NSString * const SEG_DATE_FORMAT = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
int const SEG_DATE_FORMAT_LENGTH = 24;


- (NSArray<NSString *> *)supportedEvents {
    return @[];
}


#pragma mark- Initialization Method
RCT_EXPORT_METHOD(create:(NSDictionary *)payload)
{
    [[WEGSegmentIntegrationFactory sharedInstance] createWithSettings:payload];
}

#pragma mark - trackEvent
RCT_EXPORT_METHOD(trackEvent:(NSString *)eventName payload:(NSDictionary *)payload)
{
        NSMutableDictionary * mutableDict = [payload mutableCopy];
       id<WEGAnalytics> weAnalytics = [WebEngage sharedInstance].analytics;
       [weAnalytics trackEventWithName:eventName andValue:[self setDatesInDictionary:mutableDict]];
}

#pragma mark - trackScreen
RCT_EXPORT_METHOD(trackScreen:(NSString *)screenName payload:(NSDictionary *)payload)
{
    NSMutableDictionary * mutableDict = [payload mutableCopy];
    if(payload.count <=0 ){
        [[WebEngage sharedInstance].analytics navigatingToScreenWithName:screenName];
    }else {
        [[WebEngage sharedInstance].analytics navigatingToScreenWithName:screenName andData:[self setDatesInDictionary:mutableDict]];
    }
}

#pragma mark-track user identify
RCT_EXPORT_METHOD(identify:(NSDictionary *)payload)
{
    WEGUser *user = [WebEngage sharedInstance].user;
    
    if(payload[@"userId"]){
        [user login:payload[@"userId"]];
    }
    NSDictionary *traits = payload[@"traits"];
    if(!traits){
        return;
    }
    NSMutableDictionary *traitsCopy = [traits mutableCopy];
    
    NSString *firstName =
        [self getStringValue:traits[WEG_SEGMENT_FIRST_NAME_KEY]];
        if (firstName) {
            [user setFirstName:firstName];
        }
        
    NSString *lastName = [self getStringValue:traits[WEG_SEGMENT_LAST_NAME_KEY]];
        if (lastName) {
            [user setLastName:lastName];
        }
        
        if (!firstName && !lastName) {
            
            NSString *name = [self getStringValue:traits[WEG_SEGMENT_NAME_KEY]];
            if (name) {
                NSArray *nameComponents = [name componentsSeparatedByString:@" "];
                if (nameComponents && nameComponents.count > 0) {
                    firstName = nameComponents[0];
                    [traitsCopy removeObjectForKey:WEG_SEGMENT_NAME_KEY];
                }
                
                if (nameComponents && nameComponents.count > 1) {
                    lastName = nameComponents[nameComponents.count - 1];
                }
                
                if (firstName && firstName.length > 0) {
                    [user setFirstName:firstName];
                }
                
                if (lastName && lastName.length > 0) {
                    [user setLastName:lastName];
                }
            }
        }
        
        NSString *email = [self getStringValue:traits[WEG_SEGMENT_EMAIL_KEY]];
        if (email) {
            [user setEmail:email];
        }
        
        NSString *gender = [self getStringValue:traits[WEG_SEGMENT_GENDER_KEY]];
        if (gender) {
            if ([gender caseInsensitiveCompare:@"male"] == NSOrderedSame ||
                [gender caseInsensitiveCompare:@"m"] == NSOrderedSame) {
                [user setGender:@"male"];
            } else if ([gender caseInsensitiveCompare:@"female"] == NSOrderedSame ||
                       [gender caseInsensitiveCompare:@"f"] == NSOrderedSame) {
                [user setGender:@"female"];
            } else if ([gender caseInsensitiveCompare:@"other"] == NSOrderedSame ||
                       [gender caseInsensitiveCompare:@"others"] == NSOrderedSame) {
                [user setGender:@"other"];
            }
        }
        
        NSString *company = [self getStringValue:traits[WEG_SEGMENT_COMPANY_KEY]];
        if (company) {
            [user setCompany:company];
        }
        
        NSString *phone = [self getStringValue:traits[WEG_SEGMENT_PHONE_KEY]];
        if (phone) {
            [user setPhone:phone];
        }
        
        id birthDay = traits[WEG_SEGMENT_BIRTH_DATE_KEY];
        if (birthDay) {
            NSDate *date = nil;
            if ([birthDay isKindOfClass:[NSNumber class]]) {
                // assumption is Unix Timestamp
                date = [NSDate
                        dateWithTimeIntervalSince1970:((NSNumber *)birthDay).longValue /
                        1000];
            } else if ([birthDay isKindOfClass:[NSString class]]) {
                // assumption is ISO Date format
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                [dateFormatter setLocale:enUSPOSIXLocale];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
                date = [dateFormatter dateFromString:birthDay];
            } else if ([birthDay isKindOfClass:[NSDate class]]) {
                date = birthDay;
            }
            
            if (date) {
                NSDateFormatter *birthDateFormatter = [[NSDateFormatter alloc] init];
                [birthDateFormatter setDateFormat:@"yyyy-MM-dd"];
                [birthDateFormatter
                 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [birthDateFormatter
                 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"gb"]];
                NSString *dateString = [birthDateFormatter stringFromDate:date];
                       
                [user setBirthDateString:dateString];
            }
        }
    NSDictionary *integrations = payload[@"integrations"];
    if(integrations){
        NSDictionary *integration = integrations[@"WebEngage"];
        NSString *wegHashEmail =
        [self getStringValue:integration[WEG_HASHED_EMAIL_KEY]];
        if (wegHashEmail) {
           
            [user setHashedEmail:wegHashEmail];
        }
        
        NSString *wegHashedPhoneKey =
        [self getStringValue:integration[WEG_HASHED_PHONE_KEY]];
        if (wegHashedPhoneKey) {
          
            [user setHashedPhone:wegHashedPhoneKey];
        }
        
        id wegPushOptInKey = integration[WEG_PUSH_OPT_IN_KEY];
        if (wegPushOptInKey) {
           
            [user setOptInStatusForChannel:WEGEngagementChannelPush
                                    status:[wegPushOptInKey boolValue]];
        }
        
        id wegSmsOptInKey = integration[WEG_SMS_OPT_IN_KEY];
        if (wegSmsOptInKey) {
            
            [user setOptInStatusForChannel:WEGEngagementChannelSMS
                                    status:[wegSmsOptInKey boolValue]];
        }
        
        id wegEmailOptInKey = integration[WEG_EMAIL_OPT_IN_KEY];
        if (wegEmailOptInKey) {
        
            [user setOptInStatusForChannel:WEGEngagementChannelEmail
                                    status:[wegEmailOptInKey boolValue]];
        }
        
        id wegWhatsAppOptInKey = integration[WEG_WHATSAPP_OPT_IN_KEY];
        if (wegWhatsAppOptInKey) {
            
            [user setOptInStatusForChannel:WEGEngagementChannelWhatsapp
                                    status:[wegWhatsAppOptInKey boolValue]];
        }
        
        id wegInAppOptInKey = integration[WEG_INAPP_OPT_IN_KEY];
        if (wegInAppOptInKey) {
            
            [user setOptInStatusForChannel:WEGEngagementChannelInApp
                                    status:[wegInAppOptInKey boolValue]];
        }
        
        // As per https://segment.com/docs/spec/identify/#traits, address is should be
        // read from traits as a known field
        NSDictionary *address = traits[WEG_SEGMENT_ADDRESS_KEY];
        if (address) {
            [address
             enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    [user setAttribute:key withValue:obj];
                } else if ([obj isKindOfClass:[NSDate class]]) {
                    [user setAttribute:key withDateValue:obj];
                } else if ([obj isKindOfClass:[NSString class]]) {
                    [user setAttribute:key withStringValue:obj];
                } else if ([obj isKindOfClass:[NSArray class]]) {
                    [user setAttribute:key withArrayValue:obj];
                } else if ([obj isKindOfClass:[NSDictionary class]]) {
                    [user setAttribute:key withDictionaryValue:obj];
                }
                
            }];
        }
    }
        
        [traitsCopy removeObjectForKey:WEG_SEGMENT_LAST_NAME_KEY];
        [traitsCopy removeObjectForKey:WEG_SEGMENT_FIRST_NAME_KEY];
        [traitsCopy removeObjectForKey:WEG_SEGMENT_NAME_KEY];
        [traitsCopy removeObjectForKey:WEG_SEGMENT_EMAIL_KEY];
        [traitsCopy removeObjectForKey:WEG_SEGMENT_GENDER_KEY];
        [traitsCopy removeObjectForKey:WEG_SEGMENT_BIRTH_DATE_KEY];
        [traitsCopy removeObjectForKey:WEG_SEGMENT_COMPANY_KEY];
        [traitsCopy removeObjectForKey:WEG_SEGMENT_PHONE_KEY];
        [traitsCopy removeObjectForKey:WEG_HASHED_EMAIL_KEY];
        [traitsCopy removeObjectForKey:WEG_HASHED_PHONE_KEY];
        [traitsCopy removeObjectForKey:WEG_PUSH_OPT_IN_KEY];
        [traitsCopy removeObjectForKey:WEG_EMAIL_OPT_IN_KEY];
        [traitsCopy removeObjectForKey:WEG_SMS_OPT_IN_KEY];
        [traitsCopy removeObjectForKey:WEG_SEGMENT_ADDRESS_KEY];
        
    
        [traitsCopy enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj,
                                                        BOOL *stop) {
            if ([obj isKindOfClass:[NSNumber class]]) {
            
                [user setAttribute:key withValue:obj];
            } else if ([obj isKindOfClass:[NSDate class]]) {
              
                [user setAttribute:key withDateValue:obj];
            } else if ([obj isKindOfClass:[NSString class]]) {
               
                [user setAttribute:key withStringValue:obj];
            } else if ([obj isKindOfClass:[NSArray class]]) {
               
                [user setAttribute:key withArrayValue:obj];
            } else if ([obj isKindOfClass:[NSDictionary class]]) {
                [user setAttribute:key withDictionaryValue:obj];
            }
            
        }];
    
}

#pragma mark- Reset User
RCT_EXPORT_METHOD(logout)
{
    [[WebEngage sharedInstance].user logout];
}

- (NSDictionary *)setDatesInDictionary:(NSMutableDictionary *)mutableDict {
    NSArray * keys = [mutableDict allKeys];
    for (id key in keys) {
        id value = mutableDict[key];
        if ([value isKindOfClass:[NSString class]] && [value length] == SEG_DATE_FORMAT_LENGTH) {
            NSDate * date = [self getDate:value];
            if (date != nil) {
                mutableDict[key] = date;
            }
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary * nestedDict = [value mutableCopy];
            mutableDict[key] = [self setDatesInDictionary:nestedDict];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray * nestedArr = [value mutableCopy];
            mutableDict[key] = [self setDatesInArray:nestedArr];
        }
    }
    return mutableDict;
}

- (NSDate *)getDate:(NSString *)strValue {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:SEG_DATE_FORMAT];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate * date = [dateFormatter dateFromString:strValue];
    return date;
}

- (NSArray *)setDatesInArray:(NSMutableArray *)mutableArr {
    for (int i = 0; i < [mutableArr count]; i++) {
        id value = mutableArr[i];
        if ([value isKindOfClass:[NSString class]] && [value length] == SEG_DATE_FORMAT_LENGTH) {
            NSDate * date = [self getDate:value];
            if (date != nil) {
                mutableArr[i] = date;
            }
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary * nestedDict = [value mutableCopy];
            mutableArr[i] = [self setDatesInDictionary:nestedDict];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray * nestedArr = [value mutableCopy];
            mutableArr[i] = [self setDatesInArray:nestedArr];
        }
    }
    return mutableArr;
}

- (NSString *)getStringValue:(id)input {
    if ([input isKindOfClass:[NSString class]]) {
        return input;
    } else {
        return [input stringValue];
    }
}

- (NSString *)hexRepresentationForData:(NSData *)data {
    const unsigned char *bytes = (const unsigned char *)[data bytes];
    NSUInteger nbBytes = [data length];
    NSUInteger strLen = 2 * nbBytes;
    
    NSMutableString *hex = [[NSMutableString alloc] initWithCapacity:strLen];
    for (NSUInteger i = 0; i < nbBytes;) {
        [hex appendFormat:@"%02X", bytes[i]];
        ++i;
    }
    return hex;
}


@end
