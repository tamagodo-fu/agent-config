# Whisper Transcribe Skill

Claude Code skill and command for transcribing audio/video files using OpenAI's Whisper model.

## Installation

### 1. Install Whisper

```bash
# Install OpenAI Whisper
pip install -U openai-whisper

# Install FFmpeg (required for video files)
brew install ffmpeg
```

### 2. Verify Installation

```bash
which whisper
whisper --help
```

### 3. Skill and Command Location

- **Skill**: `~/.claude/skills/whisper-transcribe/SKILL.md`
- **Command**: `~/.claude/commands/whisper-transcribe`

Claude Code automatically discovers these files.

## Usage

### Via Claude Code

Simply ask Claude to transcribe files:

```
Transcribe this video: ~/Videos/meeting.mp4
```

```
Use Whisper to transcribe interview.mp3 with the large model
```

```
Convert this audio to text: presentation.m4a
```

### Direct Command

```bash
# Basic usage
whisper-transcribe video.mp4

# With specific model
whisper-transcribe audio.mp3 --model large

# With language specification
whisper-transcribe interview.mov --language ja

# With timestamps (Glasp-style)
whisper-transcribe meeting.mp4 --timestamps

# Verbose output
whisper-transcribe podcast.mp3 --model medium --verbose
```

## Command Options

```
Usage: whisper-transcribe <input_file> [OPTIONS]

Arguments:
    input_file          Path to audio/video file

Options:
    --model MODEL       Model size: tiny, base, small, medium, large
                        Default: base
    --language LANG     Language code: ja, en, zh, ko, etc.
                        Default: auto-detect
    --timestamps        Generate timestamped output (Glasp-style)
                        Creates additional _timestamped.md file
    --verbose          Show detailed processing information
    -h, --help         Show help message
```

## Model Selection Guide

| Model | Speed | Accuracy | VRAM | Use Case |
|-------|-------|----------|------|----------|
| tiny | ⚡⚡⚡ | ⭐⭐ | ~1GB | Quick drafts, low resource |
| base | ⚡⚡ | ⭐⭐⭐ | ~1GB | **Recommended default** |
| small | ⚡ | ⭐⭐⭐⭐ | ~2GB | Good quality, reasonable speed |
| medium | 🐌 | ⭐⭐⭐⭐⭐ | ~5GB | High quality |
| large | 🐌🐌 | ⭐⭐⭐⭐⭐ | ~10GB | Best quality, slow |

## Output Format

The command creates a markdown file in the same directory:

**Input:** `~/Videos/interview.mp4`
**Output:** `~/Videos/interview.md`

**With --timestamps:**
- `~/Videos/interview.md` (regular transcription)
- `~/Videos/interview_timestamped.md` (Glasp-style with timestamps)

### Markdown Structure

```markdown
---
title: Transcription of interview.mp4
date: 2026-01-20
source: /Users/username/Videos/interview.mp4
model: base
language: auto-detected
---

# Transcription

[Transcribed text content...]

## Metadata

- Duration: 45:32
- File size: 1.2GB
- Transcription date: 2026-01-20 14:30:15
- Model: base
- Source: `/Users/username/Videos/interview.mp4`
```

## Supported Formats

### Video
- mp4, mov, avi, mkv, webm, flv

### Audio
- mp3, wav, m4a, flac, ogg, aac

## Examples

### 1. Meeting Recording

```bash
whisper-transcribe meeting_2026-01-20.mp4
```

### 2. Podcast Episode

```bash
whisper-transcribe podcast_ep42.mp3 --model medium --language en
```

### 3. Japanese Interview

```bash
whisper-transcribe interview_jp.mov --language ja --model large
```

### 4. Quick Transcription

```bash
whisper-transcribe voice_memo.m4a --model tiny
```

### 5. Meeting with Timestamps

```bash
whisper-transcribe meeting.mp4 --timestamps --language ja
```

**Output:**
- `meeting.md` - Regular transcript
- `meeting_timestamped.md` - With timestamps for easy reference

**Example timestamped output:**
```markdown
00:00:00 会議を始めます。本日の議題は3つあります。

00:00:15 まず第一に、新製品の開発状況について報告します。

00:00:45 次に、来月のマーケティングキャンペーンについて。

00:01:30 最後に、予算の見直しについて議論します。
```

## Performance Tips

### 1. GPU Acceleration

Whisper automatically uses GPU if available (CUDA/Metal Performance Shaders).

### 2. Extract Audio First

For video files, extract audio for faster processing:

```bash
ffmpeg -i video.mp4 -vn -acodec pcm_s16le -ar 16000 audio.wav
whisper-transcribe audio.wav
```

### 3. Process Multiple Files

```bash
for file in *.mp4; do
    whisper-transcribe "$file" --model base
done
```

### 4. Use Appropriate Model

- **Quick preview**: `tiny` or `base`
- **Production**: `medium` or `large`
- **Multi-language**: Always specify language

## Troubleshooting

### Issue: "whisper: command not found"

**Solution:**
```bash
pip install openai-whisper
# or
pip3 install openai-whisper
```

### Issue: Slow transcription

**Solution:**
1. Use smaller model: `--model base` or `--model tiny`
2. Extract audio first (see Performance Tips)
3. Use GPU if available
4. Try [faster-whisper](https://github.com/guillaumekln/faster-whisper)

### Issue: Out of memory

**Solution:**
1. Use smaller model: `--model tiny`
2. Split long files into chunks
3. Close other applications
4. Use swap memory

### Issue: Poor accuracy

**Solution:**
1. Use larger model: `--model large`
2. Specify language: `--language ja`
3. Improve audio quality
4. Add context with initial_prompt (requires direct whisper CLI)

### Issue: Wrong language detected

**Solution:**
```bash
whisper-transcribe file.mp4 --language ja
```

## Advanced Usage

### Custom Whisper Options

For advanced options, use whisper CLI directly:

```bash
# With initial prompt for context
whisper video.mp4 \
  --model medium \
  --initial_prompt "This is a technical discussion about AI." \
  --output_format txt

# With word-level timestamps
whisper audio.mp3 \
  --model base \
  --word_timestamps True

# Translate to English
whisper japanese_audio.mp3 \
  --task translate \
  --model large
```

### Batch Processing Script

Create a batch script for multiple files:

```bash
#!/bin/bash
# batch_transcribe.sh

for file in /path/to/videos/*.mp4; do
    echo "Processing: $file"
    whisper-transcribe "$file" --model base --language ja
done

echo "All files transcribed!"
```

### Integration with Other Tools

#### 1. Generate Subtitles

```bash
whisper video.mp4 --output_format srt --model base
```

#### 2. Create VTT for Web

```bash
whisper video.mp4 --output_format vtt --model base
```

#### 3. Extract Quotes

After transcription, extract key quotes:

```bash
grep -E "important|key point|summary" interview.md
```

## Alternatives

### Faster Whisper (Recommended for Production)

```bash
pip install faster-whisper

# Use in Python
from faster_whisper import WhisperModel

model = WhisperModel("base")
segments, info = model.transcribe("audio.mp3")

for segment in segments:
    print(f"[{segment.start:.2f}s -> {segment.end:.2f}s] {segment.text}")
```

### Whisper.cpp (C++ Implementation)

```bash
brew install whisper-cpp

# Transcribe
whisper-cpp -m base.en -f audio.wav
```

## Updating

### Update Whisper

```bash
pip install -U openai-whisper
```

### Update Command

```bash
# Re-download from skills repository
cp /path/to/new/whisper-transcribe ~/.claude/commands/
chmod +x ~/.claude/commands/whisper-transcribe
```

## Resources

- [OpenAI Whisper Repository](https://github.com/openai/whisper)
- [Whisper Model Card](https://github.com/openai/whisper/blob/main/model-card.md)
- [Faster Whisper](https://github.com/guillaumekln/faster-whisper)
- [Whisper.cpp](https://github.com/ggerganov/whisper.cpp)
- [FFmpeg Documentation](https://ffmpeg.org/documentation.html)

## Contributing

To improve this skill:

1. Test with various audio/video formats
2. Note edge cases and add to troubleshooting
3. Optimize performance for common scenarios
4. Add language-specific tips

## Version

- Skill version: 1.0.0
- Last updated: 2026-01-20
- Compatible with: openai-whisper >= 20231117

## License

Part of Claude Code skills ecosystem.
