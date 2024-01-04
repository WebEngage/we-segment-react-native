![Logo](/.github/logo.png)

# WebEngage Segment Integration Plugin

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
import {createClient} from '@segment/analytics-react-native';

const segmentClient = createClient({
  writeKey: 'SEGMENT_API_KEY',
});
```

**Notes**: For complete Segment SDK setup please refer [`Segment Developer Documentation`](https://segment.com/docs/connections/sources/catalog/libraries/mobile/react-native/)

### WebEngage ReactNative Setup

Install ` & [`]()

```sh
npm install
```

Add the WebEngage Plugin to Segment Client.

```js
import {WebEngagePlugin} from 'react-native-segment-plugin-webengage';

segmentClient.add({plugin: new WebEngagePlugin()});
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
