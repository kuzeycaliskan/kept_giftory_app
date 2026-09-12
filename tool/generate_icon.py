#!/usr/bin/env python3
"""Kept app icon generator (final: E2 — gold ribbon threaded behind the K stem).

Outputs (1024x1024):
  assets/branding/icon.png             full-bleed icon (iOS + in-app logo)
  assets/branding/icon_android_bg.png  adaptive-icon background (gradient)
  assets/branding/icon_android_fg.png  adaptive-icon foreground (transparent,
                                       glyph scaled into the 66% safe zone)

Run: python3 tool/generate_icon.py   (then: dart run flutter_launcher_icons)
"""
from PIL import Image, ImageDraw, ImageFilter
import math
import os

S = 4  # supersample factor
C = 1024 * S
CLEAR = (0, 0, 0, 0)

WHITE = (255, 255, 255, 255)
VIOLET_TL = (128, 96, 255, 255)
VIOLET_BR = (76, 44, 216, 255)
GOLD = (255, 199, 89, 255)
GOLD_DK = (240, 173, 52, 255)

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'branding')


def diag_grad(tl, br):
    img = Image.new('RGBA', (C, C))
    d = ImageDraw.Draw(img)
    for i in range(2 * C):
        t = i / (2 * C)
        d.line([(0, i), (i, 0)],
               fill=tuple(int(tl[k] + (br[k] - tl[k]) * t) for k in range(4)))
    return img


def arm(d, p1, p2, r, fill, notch_polys):
    """Squared thick segment p1->p2; extended V-notched ribbon tail at p2."""
    ang = math.atan2(p2[1] - p1[1], p2[0] - p1[0])
    ux, uy = math.cos(ang), math.sin(ang)
    nx, ny = -uy, ux
    tip = (p2[0] + ux * r, p2[1] + uy * r)
    d.polygon([
        (p1[0] + nx * r, p1[1] + ny * r), (tip[0] + nx * r, tip[1] + ny * r),
        (tip[0] - nx * r, tip[1] - ny * r), (p1[0] - nx * r, p1[1] - ny * r),
    ], fill=fill)
    depth = r * 1.15
    notch_polys.append([
        (tip[0] + nx * r, tip[1] + ny * r),
        (tip[0] - nx * r, tip[1] - ny * r),
        (tip[0] - ux * depth, tip[1] - uy * depth),
    ])


def glyph_layers():
    """(ribbon, stem, stem_shadow_on_ribbon) transparent layers."""
    w = int(150 * S)
    r = w // 2
    stem_x = 372 * S
    joint = (stem_x, 512 * S)  # bend hidden behind the stem
    up_end = (676 * S, 262 * S)
    dn_end = (670 * S, 748 * S)

    ribbon = Image.new('RGBA', (C, C), CLEAR)
    d = ImageDraw.Draw(ribbon)
    notches = []
    arm(d, joint, up_end, r, GOLD, notches)      # upper: light gold
    arm(d, joint, dn_end, r, GOLD_DK, notches)   # lower: darker = fold
    d.ellipse([joint[0] - r, joint[1] - r, joint[0] + r, joint[1] + r],
              fill=GOLD_DK)
    mask = Image.new('L', (C, C), 255)
    md = ImageDraw.Draw(mask)
    for n in notches:
        md.polygon(n, fill=0)
    ribbon.putalpha(Image.composite(
        ribbon.getchannel('A'), Image.new('L', (C, C), 0), mask))

    stem = Image.new('RGBA', (C, C), CLEAR)
    ds = ImageDraw.Draw(stem)
    ds.line([(stem_x, 256 * S), (stem_x, 768 * S)], fill=WHITE, width=w)
    for y in (256 * S, 768 * S):
        ds.ellipse([stem_x - r, y - r, stem_x + r, y + r], fill=WHITE)

    stem_sh = Image.new('RGBA', (C, C), CLEAR)
    stem_sh.paste(Image.new('RGBA', (C, C), (30, 12, 90, 90)),
                  (int(10 * S), 0), stem.getchannel('A'))
    stem_sh = stem_sh.filter(ImageFilter.GaussianBlur(10 * S))
    stem_sh.putalpha(Image.composite(
        stem_sh.getchannel('A'), Image.new('L', (C, C), 0),
        ribbon.getchannel('A')))
    return ribbon, stem, stem_sh


def compose_glyph(ribbon, stem, stem_sh):
    g = Image.alpha_composite(ribbon, stem_sh)
    return Image.alpha_composite(g, stem)


def save(img, name):
    img = img.resize((1024, 1024), Image.LANCZOS)
    path = os.path.join(OUT, name)
    img.save(path)
    print('wrote', os.path.relpath(path))


def main():
    ribbon, stem, stem_sh = glyph_layers()
    glyph = compose_glyph(ribbon, stem, stem_sh)

    # Full-bleed icon: gradient + drop shadow + glyph.
    bg = diag_grad(VIOLET_TL, VIOLET_BR)
    sh = Image.new('RGBA', (C, C), CLEAR)
    sh.paste(Image.new('RGBA', (C, C), (28, 10, 84, 100)),
             (0, int(14 * S)), glyph.getchannel('A'))
    full = Image.alpha_composite(bg, sh.filter(ImageFilter.GaussianBlur(24 * S)))
    full = Image.alpha_composite(full, glyph)
    save(full.convert('RGB'), 'icon.png')

    # Android adaptive layers: bg = gradient; fg = glyph scaled into the
    # 66% safe zone (adaptive masks crop aggressively).
    save(bg.convert('RGB'), 'icon_android_bg.png')
    scale = 0.72
    small = glyph.resize((int(C * scale), int(C * scale)), Image.LANCZOS)
    fg = Image.new('RGBA', (C, C), CLEAR)
    off = (C - small.width) // 2
    fg.paste(small, (off, off), small)
    save(fg, 'icon_android_fg.png')


if __name__ == '__main__':
    main()
