import { Action, ActionPanel, List } from "@raycast/api";
import { Temporal } from "temporal-polyfill";

const now = Temporal.Now.zonedDateTimeISO();

function format(dt: Temporal.ZonedDateTime, format: Intl.DateTimeFormatOptions): string {
  return dt.toLocaleString("en-US", format);
}

const options: { [key: string]: string } = {
  1: format(now, { dateStyle: "short" }),
  2: format(now, { hour: "numeric", minute: "2-digit", timeZoneName: "short" }),
  3: now.toPlainDate().toString(),
  4: format(now, { dateStyle: "long" }),
  5: format(now, { dateStyle: "full" }),
  6: `${now.toPlainDate()} ${now.toPlainTime().toString().substring(0, 8)}`,
};

export default function Command() {
  return (
    <List navigationTitle="Dates & Times">
      {Object.entries(options).map(([k, v]) => (
        <List.Item
          key={k}
          title={k}
          subtitle={v}
          actions={
            <ActionPanel>
              <Action title="Select" onAction={() => console.log(`${k} selected`)} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
