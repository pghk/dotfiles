import { ActionPanel, Detail, List, Action, Icon, Toast, showToast, getSelectedText } from "@raycast/api";
import { useEffect, useState } from "react";

interface Stats {
  words?: string;
  chars?: string;
}

export default function Command() {
  const [selectedText, setSelectedText] = useState<string>("");

  useEffect(() => {
    getSelectedText().then(
      (r: string) => setSelectedText(r),
      (e: Error) =>
        showToast({
          style: Toast.Style.Failure,
          title: "Error",
          message: String(e.message),
        }),
    );
  }, [selectedText]);

  const { chars, words } = analyzeSelection(selectedText);

  return (
    <Detail
      markdown={renderSelection(selectedText)}
      navigationTitle="Pikachu"
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.Label title="Character Count" text={chars} />
          <Detail.Metadata.Label title="Word Count" text={words} />
          <Detail.Metadata.TagList title="Type">
            <Detail.Metadata.TagList.Item text="Electric" color={"#eed535"} />
          </Detail.Metadata.TagList>
          <Detail.Metadata.Separator />
          <Detail.Metadata.Link title="Evolution" target="https://www.pokemon.com/us/pokedex/pikachu" text="Raichu" />
        </Detail.Metadata>
      }
    />
  );
}

function renderSelection(text: string) {
  return ">" + text.replaceAll(/[\n\r]/g, "\n>\n>");
}

function analyzeSelection(text: string): Stats {
  return {
    chars: text.length.toString(),
    words: text
      .trim()
      .split(" ")
      .filter((i) => i)
      .length.toString(),
  };
}
