import {JsonMap} from '@segment/analytics-react-native';
import {WebEngageLogger as Logger, WebEngageLogger} from '../Logger';

const WeESegmentBridge = require('react-native').NativeModules.WESegmentBridge;

const APP_ID_KEY = 'apiKey';

export default class WESegmentPluginHandler {
  tag = 'WeEngagePluginHandler';

  constructor() {}

  create(weSettings: JsonMap): void {
    try {
      WebEngageLogger.debug(
        this.tag,
        `Tracking CREATE =>  ${JSON.stringify(weSettings)}`,
      );
      WeESegmentBridge.create(weSettings);
    } catch (error) {
      WebEngageLogger.error(this.tag, `ERROR : create : ${error}`);
    }
  }

  identify(properties?: JsonMap): void {
    try {
      WebEngageLogger.debug(
        this.tag,
        `Tracking Identity Data => ${JSON.stringify(properties)}`,
      );
      WeESegmentBridge.identify(properties);
    } catch (error) {
      WebEngageLogger.error(this.tag, `ERROR : identify : ${error}`);
    }
  }

  trackEvent(event: string, properties?: JsonMap): void {
    try {
      WebEngageLogger.debug(
        this.tag,
        `Tracking Event => Name: ${event}, Properties: ${JSON.stringify(
          properties,
        )}`,
      );
      WeESegmentBridge.trackEvent(event, properties);
    } catch (error) {
      WebEngageLogger.error(this.tag, `ERROR : trackEvent : ${error}`);
    }
  }

  trackScreen(screenName: string, properties?: JsonMap): void {
    try {
      WebEngageLogger.debug(
        this.tag,
        `Tracking Screen => Name: ${screenName}, Properties : ${JSON.stringify(
          properties,
        )}`,
      );
      WeESegmentBridge.trackScreen(screenName, properties);
    } catch (error) {
      WebEngageLogger.error(this.tag, `ERROR : trackScreen : ${error}`);
    }
  }

  logoutUser(): void {
    try {
      WebEngageLogger.debug(this.tag, `logout`);
      WeESegmentBridge.logout();
    } catch (error) {
      WebEngageLogger.error(this.tag, `ERROR : logoutUser : ${error}`);
    }
  }
}
