import { Toast, showHUD, showToast } from "@raycast/api";
import { execSync } from "node:child_process";

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

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function hasActiveSessions(): boolean {
  try {
    const stdout = execSync("zellij list-sessions --no-formatting", { env: { ...process.env, PATH } }).toString();
    return parseSessionOutput(stdout).some((s) => s.status !== "exited");
  } catch {
    return false;
  }
}

async function waitForSessionsToDie(timeoutMs = 5000, intervalMs = 100): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (!hasActiveSessions()) return;
    await sleep(intervalMs);
  }
}

export default async function Command() {
  try {
    await showToast({ style: Toast.Style.Animated, title: "Restarting Zellij..." });

    let sessions: ZellijSession[] = [];
    try {
      const stdout = execSync("zellij list-sessions --no-formatting", { env: { ...process.env, PATH } }).toString();
      sessions = parseSessionOutput(stdout);
    } catch {
      // No sessions or zellij not running
    }

    const activeNames = sessions.filter((s) => s.status !== "exited").map((s) => s.name);

    try {
      execSync("zellij kill-all-sessions -y", { env: { ...process.env, PATH } });
    } catch {
      // Tolerate failure if no sessions
    }

    await waitForSessionsToDie();

    for (const name of activeNames) {
      const script = `
tell application "Ghostty"
  set cfg to new surface configuration
  set command of cfg to "/bin/zsh -lc '/opt/homebrew/bin/zellij attach --create ${name}'"
  new window with configuration cfg
  activate
end tell`;
      execSync(`osascript -e '${script.replace(/'/g, "'\\''")}'`);
    }

    await showHUD(`Zellij restarted (${activeNames.length} session${activeNames.length === 1 ? "" : "s"})`);
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: "Failed to restart Zellij",
      message: String(error),
    });
  }
}
