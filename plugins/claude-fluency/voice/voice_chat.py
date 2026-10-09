#!/usr/bin/env python3
"""Push-to-talk voice loop for Claude Code.

mic (arecord) -> whisper.cpp -> `claude -p` -> Piper -> speaker (aplay)

Each turn: press Enter to start recording, Enter again to stop. Type q to quit.
Replies use the rules from commands/conversation.md. Setup: voice/README.md.
"""
import os
import re
import subprocess
import sys
import tempfile
import uuid
from pathlib import Path

HERE = Path(__file__).resolve().parent
RULES_FILE = HERE.parent / "commands" / "conversation.md"

CLAUDE = os.environ.get("CLAUDE_BIN", "claude")
RECORD = os.environ.get("REC_BIN", "arecord")
PLAY = os.environ.get("PLAY_BIN", "aplay")
WHISPER = os.environ.get("WHISPER_BIN", "whisper-cli")
WHISPER_MODEL = os.environ.get(
    "WHISPER_MODEL", str(Path.home() / "whisper.cpp/models/ggml-base.en.bin"))
PIPER = os.environ.get("PIPER_BIN", "piper")
PIPER_MODEL = os.environ.get("PIPER_MODEL", "")


def conversation_rules():
    text = RULES_FILE.read_text()
    return re.sub(r"\A---\n.*?\n---\n", "", text, flags=re.S).strip()


def record(wav):
    proc = subprocess.Popen(
        [RECORD, "-q", "-f", "S16_LE", "-r", "16000", "-c", "1", wav])
    input("Recording. Press Enter to stop... ")
    proc.terminate()
    proc.wait()


def transcribe(wav):
    out = subprocess.run(
        [WHISPER, "-m", WHISPER_MODEL, "-f", wav, "-nt", "-np"],
        capture_output=True, text=True, check=True)
    return out.stdout.strip()


def ask_claude(prompt, session_id, first):
    cmd = [CLAUDE, "-p", prompt]
    if first:
        cmd += ["--session-id", session_id,
                "--append-system-prompt", conversation_rules()]
    else:
        cmd += ["--resume", session_id]
    out = subprocess.run(cmd, capture_output=True, text=True, check=True)
    return out.stdout.strip()


def speak(text, wav):
    subprocess.run([PIPER, "--model", PIPER_MODEL, "--output_file", wav],
                   input=text, text=True, check=True, capture_output=True)
    subprocess.run([PLAY, "-q", wav], check=True)


def main():
    if not PIPER_MODEL:
        sys.exit("Set PIPER_MODEL to a Piper .onnx voice file. See voice/README.md.")
    session_id = str(uuid.uuid4())
    first = True
    with tempfile.TemporaryDirectory() as tmp:
        in_wav = os.path.join(tmp, "in.wav")
        out_wav = os.path.join(tmp, "out.wav")
        while True:
            if input("Press Enter to talk (q + Enter to quit)... ").strip().lower() == "q":
                return
            record(in_wav)
            heard = transcribe(in_wav)
            if not heard:
                print("(heard nothing)")
                continue
            print(f"You: {heard}")
            reply = ask_claude(heard, session_id, first)
            first = False
            print(f"Claude: {reply}")
            speak(reply, out_wav)


if __name__ == "__main__":
    try:
        main()
    except (KeyboardInterrupt, EOFError):
        pass
