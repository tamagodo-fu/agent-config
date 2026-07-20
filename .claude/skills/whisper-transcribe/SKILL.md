---
name: whisper-transcribe
description: Transcribes audio/video files using local Whisper model and saves the result as markdown. Automatically translates non-Japanese content to Japanese as a separate file. Use when the user mentions transcription, subtitles, speech-to-text, Whisper, or wants to convert audio/video to text.
allowed-tools:
  - Bash
  - Read
  - Write
---

# Whisper Transcribe

Transcribes audio and video files using OpenAI's Whisper model running locally, and saves the output as markdown files.

## Quick Start

```bash
# Transcribe a video file
whisper-transcribe /path/to/video.mp4

# Transcribe with specific model
whisper-transcribe /path/to/audio.mp3 --model large

# Transcribe with language hint
whisper-transcribe /path/to/video.mp4 --language ja

# Transcribe with timestamps (Glasp-style)
whisper-transcribe /path/to/video.mp4 --timestamps
```

## Requirements

Whisper must be installed locally:

```bash
# Install OpenAI Whisper
pip install -U openai-whisper

# Or use faster whisper-cpp (optional)
brew install whisper-cpp
```

## Usage

### Basic Transcription

The skill transcribes any audio/video file and creates a markdown file in the same directory:

**Input:** `~/Videos/interview.mp4`
**Output:** `~/Videos/interview.md`

### Supported Formats

- **Video**: mp4, mov, avi, mkv, webm
- **Audio**: mp3, wav, m4a, flac, ogg

### Model Selection

Whisper offers different model sizes:

| Model | Speed | Accuracy | VRAM |
|-------|-------|----------|------|
| tiny | Fast | Low | ~1GB |
| base | Fast | Moderate | ~1GB |
| small | Moderate | Good | ~2GB |
| medium | Slow | Better | ~5GB |
| large | Slowest | Best | ~10GB |

Default: `base` (good balance)

### Language Detection

Whisper auto-detects language, but you can specify:

```bash
--language ja  # Japanese
--language en  # English
--language zh  # Chinese
--language ko  # Korean
```

## Workflow

When user requests transcription:

1. **Check File Exists**
   ```bash
   ls -lh /path/to/file.mp4
   ```

2. **Check Whisper Installation**
   ```bash
   which whisper
   ```

3. **Run Transcription**
   ```bash
   whisper /path/to/file.mp4 \
     --model base \
     --output_format txt \
     --output_dir /tmp/whisper_output
   ```

4. **Format as Markdown**
   - Add frontmatter (title, date, source file)
   - Format timestamps if needed
   - Clean up text formatting

5. **Save in Same Directory**
   - Same filename, .md extension
   - Preserve directory structure

6. **IMPORTANT: Auto-Translation for Non-Japanese Content**
   - **Check detected language** from Whisper output
   - **If language is NOT Japanese**, automatically translate to Japanese
   - **Save translation as separate file**: `filename_ja.md`
   - **Include in translation file**:
     - Original language in frontmatter
     - "Translated to: Japanese" in frontmatter
     - Summary section for quick understanding
     - All metadata from original transcription

   **Translation file naming convention:**
   - Original: `video.md` (original language transcription)
   - Translation: `video_ja.md` (Japanese translation)

   **Example workflow for non-Japanese content:**
   ```
   1. Transcribe → video.md (original language)
   2. Detect language: Vietnamese
   3. Auto-translate → video_ja.md (Japanese)
   4. User gets both files for reference
   ```

## Output Format

### Original Language Transcription

Generated markdown includes:

```markdown
---
title: Transcription of filename.mp4
date: YYYY-MM-DD
source: /path/to/filename.mp4
model: base
language: auto-detected
---

# Transcription

[Transcribed text content...]

## Metadata

- Duration: XX:XX
- File size: XXX MB
- Transcription date: YYYY-MM-DD HH:MM
```

### Japanese Translation (for non-Japanese content)

When original language is not Japanese:

```markdown
---
title: filename.mp4の文字起こし（日本語翻訳）
date: YYYY-MM-DD
source: /path/to/filename.mp4
original_language: Vietnamese (or English, Chinese, etc.)
translated_to: Japanese
model: base
translator: Claude Sonnet 4.5
---

# 文字起こし（日本語翻訳）

[Japanese translated content...]

## メタデータ

- 動画の長さ: XX:XX
- ファイルサイズ: XXX MB
- 文字起こし日時: YYYY-MM-DD HH:MM
- 翻訳日時: YYYY-MM-DD HH:MM
- 元ファイル: `/path/to/filename.mp4`
- 元の言語: [Original Language]

## 要約

[Brief summary in Japanese for quick understanding]
```

### Timestamped Output (with --timestamps flag)

When `--timestamps` flag is used, an additional file is created:

**File naming:** `filename_timestamped.md`

**Format (Glasp-style):**
```markdown
---
title: Transcription of filename.mp4 (Timestamped)
date: YYYY-MM-DD
source: /path/to/filename.mp4
model: base
language: auto-detected
format: Glasp-style timestamps
---

# Transcription (Timestamped)

00:00:00 First sentence or segment of speech.

00:00:05 Second sentence or segment continues here.

00:00:12 Each line starts with HH:MM:SS timestamp.

00:00:20 Timestamps mark the beginning of each segment.

## Metadata

- Duration: XX:XX
- File size: XXX MB
- Transcription date: YYYY-MM-DD HH:MM
- Model: base
- Format: Timestamps in HH:MM:SS format at line start
- Source: `/path/to/filename.mp4`
```

**Use cases for timestamped output:**
- Creating study notes with time references
- Navigating long interviews or lectures
- Generating YouTube timestamps for video chapters
- Reviewing specific parts of meetings
- Creating clickable transcript links

## Error Handling

### Whisper Not Installed

```bash
# Check installation
if ! command -v whisper &> /dev/null; then
  echo "Whisper not found. Install with: pip install openai-whisper"
  exit 1
fi
```

### File Not Found

```bash
if [ ! -f "$input_file" ]; then
  echo "File not found: $input_file"
  exit 1
fi
```

### Out of Memory

If transcription fails due to memory:
- Try smaller model (tiny, base, small)
- Process shorter segments
- Use whisper.cpp instead

## Advanced Options

### Custom Output Format

```bash
# Include timestamps
whisper file.mp4 --output_format srt

# Multiple formats
whisper file.mp4 --output_format txt,srt,vtt
```

### Processing Long Files

For files > 1 hour, split into chunks:

```bash
# Split audio into 10-minute segments
ffmpeg -i long_video.mp4 -f segment -segment_time 600 -c copy chunk_%03d.mp4

# Transcribe each chunk
for chunk in chunk_*.mp4; do
  whisper "$chunk" --model base
done

# Combine results
cat chunk_*.txt > full_transcription.txt
```

### Improve Accuracy

```bash
# Use larger model
whisper file.mp4 --model large

# Specify language (helps accuracy)
whisper file.mp4 --language ja

# Add initial prompt (context)
whisper file.mp4 --initial_prompt "This is a technical interview about AI."
```

## Performance Tips

1. **GPU Acceleration**: Whisper uses GPU if available (CUDA/MPS)
2. **Model Caching**: First run downloads model (~150MB-3GB)
3. **Batch Processing**: Process multiple files in parallel
4. **Audio Extraction**: Extract audio first for faster processing

```bash
# Extract audio from video (faster transcription)
ffmpeg -i video.mp4 -vn -acodec pcm_s16le -ar 16000 audio.wav
whisper audio.wav
```

## Integration with Other Tools

### Subtitle Generation

```bash
# Generate SRT subtitles
whisper video.mp4 --output_format srt
```

### Translation

```bash
# Transcribe and translate to English
whisper japanese_video.mp4 --task translate
```

### Timestamped Output

```bash
# Include word-level timestamps
whisper file.mp4 --word_timestamps True
```

## Common Use Cases

### Meeting Transcription

```bash
whisper-transcribe meeting_recording.mp4 --model medium --language ja --timestamps
```

**Output:** Meeting notes with exact timestamps for action items

### Podcast Episode

```bash
whisper-transcribe podcast_ep01.mp3 --model base --language en --timestamps
```

**Output:** Episode transcript with chapter markers

### Interview Notes

```bash
whisper-transcribe interview.mov --model small --language ja
```

**Output:** Clean transcript for analysis

### Lecture Recording

```bash
whisper-transcribe lecture.mp4 --model large --language en --timestamps
```

**Output:** Study notes with timestamps for review

### YouTube Video Content

```bash
whisper-transcribe youtube_video.mp4 --timestamps
```

**Output:** Timestamped transcript for video description/chapters

## Troubleshooting

### Issue: Slow Transcription

**Solution:**
- Use smaller model (base instead of large)
- Extract audio first
- Use GPU acceleration
- Try whisper.cpp (faster C++ implementation)

### Issue: Poor Accuracy

**Solution:**
- Use larger model
- Specify language explicitly
- Add initial_prompt with context
- Improve audio quality

### Issue: Out of Memory

**Solution:**
- Use tiny or base model
- Split file into smaller chunks
- Close other applications
- Use whisper.cpp

### Issue: Wrong Language Detected

**Solution:**
```bash
whisper file.mp4 --language ja --model base
```

## Alternative: Faster Whisper

For better performance, consider faster-whisper:

```bash
# Install faster-whisper
pip install faster-whisper

# Use in Python
from faster_whisper import WhisperModel

model = WhisperModel("base", device="cpu")
segments, info = model.transcribe("audio.mp3")

for segment in segments:
    print(f"[{segment.start:.2f}s -> {segment.end:.2f}s] {segment.text}")
```

## Guidelines

### Do's
- ✅ Check file exists before transcription
- ✅ Verify Whisper installation
- ✅ Use appropriate model size for accuracy/speed tradeoff
- ✅ Specify language when known
- ✅ Format output as clean markdown
- ✅ Include metadata in frontmatter
- ✅ Handle errors gracefully
- ✅ **ALWAYS translate non-Japanese content to Japanese**
- ✅ **Save translation as separate `_ja.md` file**
- ✅ **Include summary section in Japanese translation**
- ✅ **Preserve both original and translated files**
- ✅ **Use `--timestamps` for meetings, lectures, and long-form content**
- ✅ **Generate timestamped version for easy navigation**

### Don'ts
- ❌ Use large model on long files without GPU
- ❌ Forget to check disk space (models are large)
- ❌ Skip error handling
- ❌ Overwrite existing transcription without asking
- ❌ Use auto-detected language for mixed-language content
- ❌ **Skip translation for non-Japanese content**
- ❌ **Overwrite original transcription with translation**
- ❌ **Forget to add summary in Japanese translation**

## Quality Checklist

Before finalizing transcription:
- [ ] File successfully processed
- [ ] Output saved in correct location
- [ ] Markdown properly formatted
- [ ] Metadata included (source, date, model)
- [ ] Text is readable and accurate
- [ ] Special characters properly encoded
- [ ] No truncation or data loss

**Additional for non-Japanese content:**
- [ ] Language detected correctly
- [ ] Japanese translation created as `_ja.md`
- [ ] Translation includes original_language in frontmatter
- [ ] Summary section added to translation
- [ ] Both original and translation files available
- [ ] Translation quality verified

**Additional for timestamped output:**
- [ ] `--timestamps` flag used when needed
- [ ] Timestamped file created as `_timestamped.md`
- [ ] Timestamps in HH:MM:SS format
- [ ] Each segment properly aligned with timestamp
- [ ] Both regular and timestamped versions available
- [ ] Timestamps accurate and useful for navigation

## Resources

- [OpenAI Whisper GitHub](https://github.com/openai/whisper)
- [Whisper Model Card](https://github.com/openai/whisper/blob/main/model-card.md)
- [Faster Whisper](https://github.com/guillaumekln/faster-whisper)
- [Whisper.cpp](https://github.com/ggerganov/whisper.cpp)
