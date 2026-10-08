#!/usr/bin/env python3
"""Build a launcher icon from assets/logo.png.

The mark (pink X + yellow dot) sits inside Android's 72dp adaptive-icon
circle so the home-screen icon and the legacy icon inside the app bundle
show the same artwork. The in-app splash keeps the full-bleed logo.
"""
import math

from PIL import Image

SRC = "assets/logo.png"
OUT = "assets/icon_launcher.png"
BG = (10, 10, 10, 255)
# 72dp circle on a 108dp adaptive canvas, with a little margin.
SAFE_RADIUS = (36 / 108) * 0.96


def main() -> None:
    src = Image.open(SRC).convert("RGBA")
    w, h = src.size
    if w != h:
        raise SystemExit(f"expected a square logo, got {w}x{h}")

    pixels = src.load()
    xs, ys = [], []
    for y in range(h):
        for x in range(w):
            r, g, b, _a = pixels[x, y]
            if (r, g, b, 255) != BG:
                xs.append(x)
                ys.append(y)
    if not xs:
        raise SystemExit("logo has no foreground pixels")

    minx, maxx = min(xs), max(xs)
    miny, maxy = min(ys), max(ys)
    cx = (minx + maxx) / 2
    cy = (miny + maxy) / 2
    max_d = max(math.hypot(x - cx, y - cy) for x, y in zip(xs, ys))
    scale = (SAFE_RADIUS * w) / max_d

    mark = src.crop((minx, miny, maxx + 1, maxy + 1))
    resized = mark.resize(
        (max(1, round(mark.width * scale)), max(1, round(mark.height * scale))),
        Image.Resampling.LANCZOS,
    )
    out = Image.new("RGBA", (w, h), BG)
    out.paste(
        resized,
        ((w - resized.width) // 2, (h - resized.height) // 2),
        resized,
    )
    out.save(OUT)
    print(f"wrote {OUT} {out.size} scale={scale:.3f}")


if __name__ == "__main__":
    main()
