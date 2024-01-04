/**
 * Supported LogLevel by {@link WebEngageLogger}
 *
 * @author
 * @since
 */
export enum WebEngageLogLevel {
  /**
   * Log Level Debug Log
   */
  DEBUG = 0,

  /**
   * Log Level Warning
   */
  WARN = 1,

  /**
   * Log Level Error
   */
  ERROR = 2,

  /**
   * No Log Will be printed (even in debug build)
   */
  NO_LOG = 99,
}

export namespace WebEngageLogger {
  /**
   * Min log level which need to be logged on console
   */
  let logLevel: WebEngageLogLevel = WebEngageLogLevel.DEBUG;

  /**
   * Whether the log is enabled or not
   * Note: Log is enabled in debug build by default & disabled in released build
   */
  let isEnabled: boolean = __DEV__;

  /**
   * Configure the logging in WebEngage Segment Plugin
   *
   * @param {WebEngageLogLevel} level = log level which need to be logged on console
   * @param {boolean} isEnabledForReleaseBuild = whether log is enabled for release build or not
   */
  export function configureLogs(
    level: WebEngageLogLevel,
    isEnabledForReleaseBuild: boolean = false,
  ): void {
    logLevel = level;
    isEnabled = isEnabledForReleaseBuild || __DEV__;
  }

  /**
   * Console debug log
   *
   * @param {string} tag - tag which will be added before message
   * @param {string} message - log message which need to be logged
   */
  export function debug(tag: string, message: string): void {
    if (!isEnabled || logLevel > WebEngageLogLevel.DEBUG) return;
    console.log(`${tag} ${message}`);
  }

  /**
   * Console warning log
   *
   * @param {string} tag - tag which will be added before message
   * @param {string} message - log message which need to be logged
   */
  export function warn(tag: string, message: string): void {
    if (!isEnabled || logLevel > WebEngageLogLevel.WARN) return;
    console.warn(`${tag} ${message}`);
  }

  /**
   * Console error log
   *
   * @param {string} tag - tag which will be added before message
   * @param {string} message - log message which need to be logged
   */
  export function error(tag: string, message: string): void {
    if (!isEnabled || logLevel > WebEngageLogLevel.ERROR) return;
    console.error(`${tag} ${message}`);
  }
}
