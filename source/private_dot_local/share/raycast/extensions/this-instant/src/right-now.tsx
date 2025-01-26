import { Action, ActionPanel, Color, Clipboard, Detail, getPreferenceValues } from "@raycast/api";
import { Temporal } from "temporal-polyfill";

interface Preferences {
  timeZones?: string;
}

const formats: { [key: string]: Intl.DateTimeFormatOptions } = {
  date: { dateStyle: "full" },
  time: { hour: "numeric", minute: "2-digit", timeZoneName: "short" },
  h12: { hour: "numeric", minute: "2-digit" },
  tz: { day: "2-digit", timeZoneName: "long" },
  std: { hour12: false, hour: "2-digit", minute: "2-digit", second: "2-digit" },
};

const now = Temporal.Now.zonedDateTimeISO();
const utc = now.withTimeZone("UTC");
const unix = Math.floor(now.epochMilliseconds / 1000).toString();

const clockTime = `
  # ${format(now, "time")}
  ${format(now, "date")}
`;

export default function Command() {
  const preferences = getPreferenceValues<Preferences>();
  const zoneTimes = getTimeZonesPref(preferences);

  return (
    <Detail
      markdown={clockTime + AdditionalTimeZones(zoneTimes)}
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.Label title="24hr Time" text={`${format(now, "std")} ${now.offset}`} />
          <Detail.Metadata.Label title="Time Zone" text={formatTZ(now)} />
          <Detail.Metadata.Separator />
          <Detail.Metadata.TagList title="UTC">
            <CopyTag value={format(utc, "std")} color={Color.Blue} />
          </Detail.Metadata.TagList>
          <Detail.Metadata.TagList title="ISO 8601">
            <CopyTag value={Temporal.Now.instant().toString()} color={Color.Green} />
          </Detail.Metadata.TagList>
          <Detail.Metadata.TagList title="Unix">
            <CopyTag value={unix} color={Color.SecondaryText} />
          </Detail.Metadata.TagList>
        </Detail.Metadata>
      }
      actions={
        <ActionPanel>
          <Action.CopyToClipboard content={clockTime} shortcut={{ modifiers: ["cmd"], key: "." }} />
        </ActionPanel>
      }
    />
  );
}

function AdditionalTimeZones(zones: Temporal.ZonedDateTime[]) {
  return zones.reduce((prev, cur) => {
    return `${prev}## ${formatTZ(cur)}\n${format(cur, "h12")} / ${format(cur, "std")} ${cur.offset}\n\n`;
  }, ``);
}

function CopyTag({ value, color }: { value: string; color: Color }) {
  const clip = () => Clipboard.copy(value);
  return <Detail.Metadata.TagList.Item text={value} color={color} onAction={clip} />;
}

function format(dt: Temporal.ZonedDateTime, format: string): string {
  return dt.toLocaleString("en-US", formats[format]);
}

function formatTZ(dt: Temporal.ZonedDateTime) {
  return format(dt, "tz").substring(4);
}

function getTimeZonesPref(prefs: Preferences): Temporal.ZonedDateTime[] {
  const { timeZones } = prefs;
  const valid: Temporal.ZonedDateTime[] = [];
  timeZones?.split(/,? /).forEach((i) => {
    try {
      const tz = now.withTimeZone(i);
      valid.push(tz);
    } catch (e) {
      if (!(e instanceof RangeError)) {
        console.error(e);
      }
    }
  });
  return valid;
}
