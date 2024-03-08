import {
  IntegrationSettings,
  SegmentAPIIntegrations,
  JsonMap,
  IdentifyEventType,
} from '@segment/analytics-react-native';

export const WEConstants: {[key: string]: string} = {
  KEY: 'WebEngage',
  LICENSE_CODE_KEY: 'licenseCode',
  EVENT: 'event',
  SCREEN: 'screen',
  PROPERTIES: 'properties',
};

export const generateCreateJson = (settings: IntegrationSettings): JsonMap => {
  let json = {
    [WEConstants.LICENSE_CODE_KEY]:
      settings[WEConstants.LICENSE_CODE_KEY as keyof IntegrationSettings],
  };
  return json;
};

export const generateTrackEventJson = (
  event: string,
  properties?: JsonMap,
): JsonMap => {
  let json = {
    [WEConstants.EVENT]: event,
    [WEConstants.PROPERTIES]: properties,
  };
  return json;
};

export const generateScreenEventJson = (
  event: string,
  properties?: JsonMap,
): JsonMap => {
  let json = {
    [WEConstants.SCREEN]: event,
    [WEConstants.PROPERTIES]: properties,
  };
  return json;
};

export const transformIdentifyMap = (event: IdentifyEventType): JsonMap => {
  var map: JsonMap = {};
  if (event.userId) {
    map['userId'] = event.userId;
  }
  if (event.traits) {
    map['traits'] = event.traits;
  }
  if (event.integrations) {
    map['integrations'] = convertToMap(event.integrations);
  }

  return map;
};

export const convertToMap = (integrations: SegmentAPIIntegrations): JsonMap => {
  const jsonMap: JsonMap = {};

  for (const key in integrations) {
    if (integrations.hasOwnProperty(key)) {
      const integrationSettings = integrations[key];
      if (
        typeof integrationSettings === 'object' &&
        integrationSettings !== null
      ) {
        jsonMap[key] = convertToMap(
          integrationSettings as SegmentAPIIntegrations,
        );
      } else {
        jsonMap[key] = integrationSettings;
      }
    }
  }

  return jsonMap;
};
