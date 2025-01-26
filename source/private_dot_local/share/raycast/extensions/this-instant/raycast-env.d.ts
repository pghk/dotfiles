/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {
  /** Additional Time Zones - Space and/or comma-separated list of time zone IDs (i.e. America/New_York) to display in addition to the local time */
  "timeZones"?: string
}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `right-now` command */
  export type RightNow = ExtensionPreferences & {}
  /** Preferences accessible in the `timestamp` command */
  export type Timestamp = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `right-now` command */
  export type RightNow = {}
  /** Arguments passed to the `timestamp` command */
  export type Timestamp = {}
}

