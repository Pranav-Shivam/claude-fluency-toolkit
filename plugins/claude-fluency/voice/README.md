# Voice mode for Claude Code

`/conversation` makes replies short and spoken-style. `voice_chat.py` adds a real mic and speaker loop around it:

mic (`arecord`) -> whisper.cpp -> `claude -p` -> Piper -> speaker (`aplay`)

Push-to-talk: press Enter to start recording, Enter again to stop, `q` + Enter to quit. The conversation keeps context across turns (one Claude Code session per run) and uses the rules from `commands/conversation.md`.

The script uses `arecord`/`aplay` (ALSA), so it runs on Linux as shipped. On Mac or Windows, point `REC_BIN`/`PLAY_BIN` at equivalent commands (`sox`/`ffplay`), or run it inside WSL2.

## Install (CPU only, no GPU needed)

```bash
# Speech-to-text
git clone https://github.com/ggerganov/whisper.cpp ~/whisper.cpp
cd ~/whisper.cpp && cmake -B build && cmake --build build -j
bash ./models/download-ggml-model.sh base.en      # or small.en for accuracy

# Text-to-speech
python3 -m venv ~/voice-venv                      # needed on Ubuntu 24+ / Debian 12+ (system pip is locked)
~/voice-venv/bin/pip install piper-tts
mkdir -p ~/piper-voices && cd ~/piper-voices
~/voice-venv/bin/python -m piper.download_voices en_US-lessac-medium
```

With a GPU, swap whisper.cpp for `faster-whisper` and set `WHISPER_BIN` to a wrapper that prints the transcript.

## Run

```bash
export PIPER_BIN=~/voice-venv/bin/piper
export PIPER_MODEL=~/piper-voices/en_US-lessac-medium.onnx
export WHISPER_BIN=~/whisper.cpp/build/bin/whisper-cli
python3 voice_chat.py
```

## Settings (environment variables)

| Variable | Default |
|---|---|
| `PIPER_MODEL` | required — path to a Piper `.onnx` voice |
| `WHISPER_BIN` | `whisper-cli` |
| `WHISPER_MODEL` | `~/whisper.cpp/models/ggml-base.en.bin` |
| `PIPER_BIN` / `REC_BIN` / `PLAY_BIN` / `CLAUDE_BIN` | `piper` / `arecord` / `aplay` / `claude` |

Without the script, `/conversation` alone still works as a text-only spoken-style mode.
