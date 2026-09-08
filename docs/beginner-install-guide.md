# Installing the full toolkit — for non-technical users

If you only want `/prompt-master`, `/humanize`, or `/mom`, you don't need any of this — see [`no-cli-prompt-master.md`](no-cli-prompt-master.md), [`no-cli-humanize.md`](no-cli-humanize.md), [`no-cli-mom.md`](no-cli-mom.md), which work by copy-pasting into the normal claude.ai chat. There's also a manual-input [`no-cli-timesheet.md`](no-cli-timesheet.md) if you don't need the automatic git-scanning version.

This guide is for the **rest of the toolkit** — `/security-scan`, `/pr-description`, the automatic `/timesheet`, `/adr`, `/create-pptx`, etc. Those commands read your actual files, git history, or folders, so they can't run inside a plain web chat — they need the **Claude Code** app, which runs from a terminal window. That sounds scary if you've never used one, but every step below is copy-paste — you're not expected to type commands from memory.

Written for Windows (matches the screenshots that prompted this guide). Mac/Linux notes at the bottom.

## Before you start

A **terminal** (also called "command line," "PowerShell," "Command Prompt") is just a plain black/dark window where you type text instead of clicking buttons. You'll open one, paste a line of text into it, press Enter, and read what it prints back. That's the entire skill required here.

## Step 1 — Install Node.js

Claude Code needs Node.js to run.

1. Go to **[nodejs.org](https://nodejs.org)**.
2. Click the big green button that says **LTS** (it'll show a version number — any current LTS version is fine).
3. Once it downloads, double-click the installer and click **Next** through every screen, leaving all the default options as they are. Click **Install**, then **Finish**.

## Step 2 — Open a terminal

1. Press the **Windows key**, type `powershell`, and press **Enter**.
2. A dark window opens — this is your terminal. Leave it open for the next steps.

## Step 3 — Check Node.js installed correctly

Paste this in and press Enter (right-click pastes into PowerShell):

```
node -v
```

You should see something like `v22.11.0` printed back. If instead you see **"node is not recognized"**, close the PowerShell window, reopen it (Step 2 again), and try `node -v` once more — Windows sometimes needs a fresh window to notice a new install. If it still fails, restart your computer once and try again.

## Step 4 — Install Claude Code

In the same PowerShell window, paste:

```
npm install -g @anthropic-ai/claude-code
```

Press Enter and wait — this downloads and installs the app. You'll see a bunch of text scroll by; that's normal. When it stops and gives you a new blank line, it's done.

## Step 5 — Close and reopen PowerShell

This step is easy to skip and is the #1 cause of the next step failing. **Close the PowerShell window completely and open a brand new one** (Step 2 again).

## Step 6 — Start Claude Code

Navigate to a folder you want to work in (or just use your Desktop for now), then start Claude Code. To go to your Desktop and start it:

```
cd Desktop
claude
```

The first time you run this, it'll ask you to log in — it opens a browser window, you sign in with your Claude account, and come back to the terminal. If you see **"claude is not recognized"**, you skipped Step 5 — close the window, reopen a fresh one, and try `claude` again.

## Step 7 — Add the toolkit

Once you see a prompt inside Claude Code (it looks different from the plain PowerShell prompt — you'll see a `>` you can type into), paste this and press Enter:

```
/plugin marketplace add Pranav-Shivam/claude-fluency-toolkit
```

Then paste this and press Enter:

```
/plugin install claude-fluency@claude-fluency-toolkit
```

**Important:** these two `/plugin` commands only work *inside the Claude Code terminal app* from Step 6 — not in the regular claude.ai website or desktop chat app. If you see "`/plugin` isn't available in this environment," you're typing it in the wrong place — go back to the PowerShell window where you ran `claude`.

## Step 8 — Try it

Still inside Claude Code, try:

```
/humanize
```

It'll ask what you want rewritten — paste some text and see what comes back. If that worked, everything else in the toolkit (`/prompt-master`, `/security-scan`, `/pr-description`, `/timesheet`, `/mom`, `/adr`, `/create-pptx`) is ready too. See [`HOWTOUSE.md`](../plugins/claude-fluency/HOWTOUSE.md) in the plugin folder for a worked example of every command.

## Common problems

| What you see | What it means | Fix |
|---|---|---|
| `node is not recognized` | Node.js install didn't finish, or terminal is stale | Reopen PowerShell (fresh window); if still broken, restart your computer once |
| `npm is not recognized` | Same as above — npm ships with Node.js | Same fix |
| `claude is not recognized` | You didn't open a fresh terminal after installing (Step 5) | Close PowerShell completely, open a new one |
| `/plugin isn't available in this environment` | You're in the regular claude.ai chat, not the Claude Code terminal app | Go back to the PowerShell window from Step 6 |
| Nothing happens after pasting a command | Right-click paste sometimes doesn't register the Enter — press Enter yourself after pasting | — |
| Login browser window doesn't open | Some work/managed computers block auto-opening browsers | Copy the login link it prints and paste it into your browser manually |

## Mac / Linux notes

Same steps, different terminal app:
- Open **Terminal** (Mac: Cmd+Space, type "Terminal"; Linux: usually Ctrl+Alt+T).
- Install Node.js the same way from [nodejs.org](https://nodejs.org) (macOS `.pkg` installer), or via Homebrew: `brew install node`.
- Steps 4, 6, 7, 8 are identical — same commands, same order.
- Instead of `cd Desktop`, Mac/Linux paths usually look like `cd ~/Desktop`.
