//
//  WEGSegmentIntegrationFactory.h
//  ReactNativeSegmentWebEngage
//
//  Created by Milind Keni on 29/12/23.
//

#import <Foundation/Foundation.h>
#import <WebEngage/WebEngage.h>
NS_ASSUME_NONNULL_BEGIN

@interface WEGSegmentIntegrationFactory : NSObject

+ (instancetype)sharedInstance;

-(instancetype) instanceWithApplication:(UIApplication*) application
                          launchOptions:(NSDictionary*) launchOptions;

-(instancetype) instanceWithApplication:(UIApplication*) application
                          launchOptions:(NSDictionary*) launchOptions
                       autoAPNSRegister:(BOOL) autoRegister;

-(instancetype) instanceWithApplication:(UIApplication*) application
                          launchOptions:(NSDictionary*) launchOptions
                   notificationDelegate:(id<WEGInAppNotificationProtocol>) notificationDelegate;

-(instancetype) instanceWithApplication:(UIApplication*) application
                          launchOptions:(NSDictionary*) launchOptions
                   notificationDelegate:(id<WEGInAppNotificationProtocol>) notificationDelegate
                       autoAPNSRegister:(BOOL) autoRegister;

-(void) createWithSettings:(NSDictionary *)settings;

@end

NS_ASSUME_NONNULL_END
