#import "WEGSegmentIntegrationFactory.h"
#import "WEGSegmentPluginInfo.h"

@interface WEGSegmentIntegrationFactory ()
@property(nonatomic, strong, readwrite) UIApplication *application;
@property(nonatomic, strong, readwrite) NSDictionary *launchOptions;
@property(nonatomic, strong, readwrite) id<WEGInAppNotificationProtocol> notificationDelegate;
@property(nonatomic, readwrite) BOOL autoAPNSRegister;
@end

@implementation WEGSegmentIntegrationFactory

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static WEGSegmentIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)instanceWithApplication:(UIApplication *)application
                          launchOptions:(NSDictionary *)launchOptions {
    return [self instanceWithApplication:application
                           launchOptions:launchOptions
                    notificationDelegate:nil
                        autoAPNSRegister:YES];
}

- (instancetype)instanceWithApplication:(UIApplication *)application
                          launchOptions:(NSDictionary *)launchOptions
                       autoAPNSRegister:(BOOL)autoRegister {
    
    return [self instanceWithApplication:application
                           launchOptions:launchOptions
                    notificationDelegate:nil
                        autoAPNSRegister:autoRegister];
}

- (instancetype)instanceWithApplication:(UIApplication *)application
                          launchOptions:(NSDictionary *)launchOptions
                   notificationDelegate:
(id<WEGInAppNotificationProtocol>)notificationDelegate {
    
    return [self instanceWithApplication:application
                           launchOptions:launchOptions
                    notificationDelegate:notificationDelegate
                        autoAPNSRegister:YES];
}

- (instancetype)instanceWithApplication:(UIApplication *)application
                          launchOptions:(NSDictionary *)launchOptions
                   notificationDelegate:
(id<WEGInAppNotificationProtocol>)notificationDelegate
                       autoAPNSRegister:(BOOL)autoRegister {
    self.application = application;
    self.launchOptions = launchOptions;
    self.notificationDelegate = notificationDelegate;
    self.autoAPNSRegister = autoRegister;
    
    return self;
}

- (void)createWithSettings:(NSDictionary *)settings{
    BOOL __block isInited = NO;
    /*
     Adding main thread check as,
     Segment calls this method on background queue on first launch,
     From second launch onwards it calls this method on main queue.
     */
    
    [self runOnMainQueueWithoutDeadlocking:^{
        NSString *licenceCode = settings[@"licenseCode"];
        
        
        // Check if license code has been overridden or not
        NSString *LicenseCodeFromInfoPlist = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WEGLicenseCode"];
        if ([LicenseCodeFromInfoPlist length] != 0){
            licenceCode = LicenseCodeFromInfoPlist;
        }
        
        isInited = [[WebEngage sharedInstance]
                    application:self.application
                    didFinishLaunchingWithOptions:@{
                        @"WebEngage" : settings ? settings : @{},
                        @"launchOptions" : self.launchOptions ? self.launchOptions : @{}
                    }
                    notificationDelegate:self.notificationDelegate
                    autoRegister:self.autoAPNSRegister
                    setLicenseCode:licenceCode];
        [self initialiseWEGVersion];
    }];
}
- (void)runOnMainQueueWithoutDeadlocking:(void (^)(void))block {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void)initialiseWEGVersion {
    WegVersionKey key = WegVersionKeySEGRN;
    [[WebEngage sharedInstance] setVersionForChildSDK:WEG_REACT_NATIVE_SEGMENT_PLUGIN_VERSION forKey:key];
}

- (NSString *)key {
    return @"WebEngage";
}

@end
