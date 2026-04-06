import { ActionPanel, Action, Icon, List, Toast, closeMainWindow, popToRoot, showToast } from "@raycast/api";
import { useExec } from "@raycast/utils";
import { execSync } from "node:child_process";
import { useState } from "react";

interface ZellijSession {
  name: string;
  age: string;
  status: "current" | "exited" | "active";
}

const PATH = "/opt/homebrew/bin:" + (process.env.PATH ?? "");

function parseSessionOutput(stdout: string): ZellijSession[] {
  const lines = stdout.trim().split("\n").filter(Boolean);
  return lines
    .map((line) => {
      const match = line.match(/^(.+?)\s+\[Created (.+?) ago\]\s*(\(.*\))?\s*$/);
      if (!match) return null;
      const [, name, age, statusRaw] = match;
      let status: ZellijSession["status"] = "active";
      if (statusRaw?.includes("current")) {
        status = "current";
      } else if (statusRaw?.includes("EXITED")) {
        status = "exited";
      }
      return { name: name.trim(), age, status };
    })
    .filter((s): s is ZellijSession => s !== null);
}

async function openSession(name: string) {
  const script = `
tell application "Ghostty"
  set cfg to new surface configuration
  set command of cfg to "/opt/homebrew/bin/zellij attach --create ${name}"
  new window with configuration cfg
  activate
end tell`;
  try {
    execSync(`osascript -e '${script.replace(/'/g, "'\\''")}'`);
    await closeMainWindow();
    await popToRoot();
    await showToast({ style: Toast.Style.Success, title: `Opened session: ${name}` });
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: "Failed to open session",
      message: String(error),
    });
  }
}

export default function Command() {
  const [searchText, setSearchText] = useState("");

  const { data, isLoading, error } = useExec("zellij", ["list-sessions", "--no-formatting"], {
    env: { PATH },
    parseOutput: ({ stdout }) => parseSessionOutput(stdout),
  });

  const sessions = data ?? [];
  const exactMatch = sessions.some((s) => s.name === searchText);

  if (error) {
    const isNotFound = error.message.includes("ENOENT") || error.message.includes("not found");
    return (
      <List>
        <List.EmptyView
          icon={Icon.Warning}
          title={isNotFound ? "zellij not found" : "Error loading sessions"}
          description={isNotFound ? "Install zellij: brew install zellij" : error.message}
        />
      </List>
    );
  }

  return (
    <List
      isLoading={isLoading}
      filtering={true}
      onSearchTextChange={setSearchText}
      searchBarPlaceholder="Search or create a Zellij session..."
    >
      <List.EmptyView
        icon={Icon.Terminal}
        title="No sessions found"
        description="Type a name to create a new session"
      />
      {searchText.length > 0 && !exactMatch && (
        <List.Item
          icon={Icon.Plus}
          title={`Open: ${searchText}`}
          actions={
            <ActionPanel>
              <Action title={`Open Session "${searchText}"`} onAction={() => openSession(searchText)} />
            </ActionPanel>
          }
        />
      )}
      {sessions.map((session) => (
        <List.Item
          key={session.name}
          icon={Icon.Terminal}
          title={session.name}
          accessories={[
            ...(session.status !== "active"
              ? [{ tag: { value: session.status, color: session.status === "current" ? "#a6d189" : "#e78284" } }]
              : []),
            { text: session.age },
          ]}
          keywords={[session.status]}
          actions={
            <ActionPanel>
              <Action title={`Open Session "${session.name}"`} onAction={() => openSession(session.name)} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
