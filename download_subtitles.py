#!/usr/bin/env python3
"""Download English subtitles for all video files in a folder."""

import sys
import os
from pathlib import Path

VIDEO_EXTENSIONS = {".mp4", ".mkv", ".avi", ".mov", ".ts", ".m4v", ".wmv", ".flv", ".webm"}


def find_video_files(folder: Path) -> list[Path]:
    return [f for f in folder.iterdir() if f.is_file() and f.suffix.lower() in VIDEO_EXTENSIONS]


def download_subtitles(folder: Path):
    try:
        import subliminal
        from babelfish import Language
        from subliminal import download_best_subtitles, save_subtitles, scan_videos
    except ImportError:
        print("Missing dependencies. Run: pip install subliminal babelfish")
        sys.exit(1)

    videos = find_video_files(folder)
    if not videos:
        print(f"No video files found in {folder}")
        return

    print(f"Found {len(videos)} video file(s):")
    for v in videos:
        print(f"  {v.name}")
    print()

    scanned = scan_videos([str(v) for v in videos])

    subtitles = download_best_subtitles(
        scanned,
        {Language("eng")},
        only_one=True,
    )

    saved = 0
    for video, subs in subtitles.items():
        if subs:
            save_subtitles(video, subs)
            print(f"[OK]   {Path(video.name).name}")
            saved += 1
        else:
            print(f"[MISS] {Path(video.name).name} — no subtitle found")

    print(f"\nDone: {saved}/{len(scanned)} subtitle(s) downloaded.")


if __name__ == "__main__":
    folder = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    if not folder.is_dir():
        print(f"Not a directory: {folder}")
        sys.exit(1)
    download_subtitles(folder)
