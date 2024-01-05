# WebEngage Reeact Native Segment Integration Plugin

## SDK Installation

### Segment Setup

Install [`@segment/analytics-react-native`](https://github.com/segmentio/analytics-react-native)

```sh
yarn add @segment/analytics-react-native
# or
npm install @segment/analytics-react-native
```

Initialise the Segment SDK

```js
import { createClient } from "@segment/analytics-react-native";

const segmentClient = createClient({
  writeKey: "SEGMENT_API_KEY",
});
```

**Notes**: For complete Segment SDK setup please refer [`Segment Developer Documentation`](https://segment.com/docs/connections/sources/catalog/libraries/mobile/react-native/)

### WebEngage ReactNative Setup

Install `react-native-segment-plugin-webengage`

```sh
npm install react-native-segment-plugin-webengage
```

Add the WebEngage Plugin to Segment Client.

```js
import { WebEngagePlugin } from "react-native-segment-plugin-webengage";

segmentClient.add({ plugin: new WebEngagePlugin() });
```

Once the installation is done move to platform specific integrations.

### Android

Add the Segment Integration to WebEngage in Application class in onCreate Method

```kotlin
 val webEngageConfig = WebEngageConfig.Builder()
      .setDebugMode(true)
      .build()
  WeSegmentHelper.getInstance().initWebEngage(this,webEngageConfig)
```

Add LicenseCode in AndroidManifest.xml file inside the Application tag

```xml
<application>


<meta-data android:name="com.webengage.sdk.android.key" android:value="LICENSE_CODE" />

  <application/>
```

### iOS

Add the Segment Integration in application:didFinishLaunchingWithOptions: method: of AppDelegate

```Objective-C
#import "WEGSegmentIntegrationFactory.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
   [[WEGSegmentIntegrationFactory sharedInstance] instanceWithApplication:application launchOptions:launchOptions];

    return YES;
}
```

Add the LicenseCode code in info.plist file refer - [`iOS Docs`](https://docs.webengage.com/docs/ios-getting-started#3-configure-infoplist)

### Callbacks

To get the callback of InApp first install ReactNative WebEngage Plugin

```sh
npm install react-native-webengage --save
```

### iOS setup

Open AppDelegate.h file from the ios/AppName/ folder:

```Objective-C
#import <WEGWebEngageBridge.h>

// Add the following line inside the interface class
@property (nonatomic, strong) WEGWebEngageBridge *wegBridge;

```

Open AppDelegate.m from the ios/AppName/ folder:

Inside the didFinishLaunchingWithOptions function, add the following lines:

> **_NOTE:_** `[[WEGSegmentIntegrationFactory sharedInstance]` should be called only once; no multiple initializations.

```Objective-C
self.wegBridge = [WEGWebEngageBridge new];
[[WEGSegmentIntegrationFactory sharedInstance] instanceWithApplication:application launchOptions:launchOptions notificationDelegate:self.wegBridge];

```

In your React Native code:

```js
import WebEngage from "react-native-webengage";

// override the below two methods

this.webengage.notification.onShown(function (notificationData) {});

this.webengage.notification.onClick(function (notificationData, clickId) {
  Alert.alert("Notification Click", JSON.stringify(notificationData));
});
```

For more information, refer to the documentation
[`here`](https://docs.webengage.com/docs/react-native-callbacks#in-app-message-callbacks)
