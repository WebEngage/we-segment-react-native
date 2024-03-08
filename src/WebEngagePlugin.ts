import {
  DestinationPlugin,
  IdentifyEventType,
  PluginType,
  SegmentAPISettings,
  TrackEventType,
  ScreenEventType,
  UpdateType,
} from '@segment/analytics-react-native';
import WESegmentPluginHandler from './internal/WESegmentPluginHandler';
import {
  WEConstants,
  generateCreateJson,
  transformIdentifyMap,
} from './internal/WEConstants';
import {WebEngageLogger} from './Logger';

export class WebEngagePlugin extends DestinationPlugin {
  tag = 'WeEngagePlugin';
  key = WEConstants.KEY;
  type = PluginType.destination;

  weSegementPluginHandler: WESegmentPluginHandler | undefined;

  constructor() {
    super();
    WebEngageLogger.debug(this.tag, 'INIT');
    this.init();
  }

  init(): void {
    if (this.weSegementPluginHandler == null)
      this.weSegementPluginHandler = new WESegmentPluginHandler();
  }

  update(settings: SegmentAPISettings, type: UpdateType): void {
    try {
      if (
        type == UpdateType.initial &&
        settings.integrations?.[WEConstants.KEY] !== undefined
      ) {
        let webEngageSettings = settings.integrations[WEConstants.KEY];
        let json = generateCreateJson(webEngageSettings);
        this.weSegementPluginHandler?.create(json);
      }
    } catch (error) {
      WebEngageLogger.error(
        this.tag,
        `update(): error while fetching config ${error}`,
      );
    }
  }

  identify(
    event: IdentifyEventType,
  ): IdentifyEventType | Promise<IdentifyEventType | undefined> | undefined {
    try {
      this.weSegementPluginHandler?.identify(transformIdentifyMap(event));
    } catch (error) {
      WebEngageLogger.error(this.tag, `Error ${error}`);
    }
    return event;
  }

  track(
    event: TrackEventType,
  ): TrackEventType | Promise<TrackEventType | undefined> | undefined {
    WebEngageLogger.debug(this.tag, JSON.stringify(event));
    this.weSegementPluginHandler?.trackEvent(event.event, event.properties);
    return event;
  }

  screen(
    event: ScreenEventType,
  ): Promise<ScreenEventType | undefined> | ScreenEventType | undefined {
    this.weSegementPluginHandler?.trackScreen(event.name, event.properties);
    return event;
  }

  reset(): void {
    this.weSegementPluginHandler?.logoutUser();
  }
}
