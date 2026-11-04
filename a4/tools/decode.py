#!/usr/bin/env python3
"""Splits a raw capture of the mod's USB MIDI (DTBOOT_USB_OUT) into messages and summarises them.
    decode.py capture.bin [--list]"""
import sys

NAMES = {0x4F: "hello", 0x04: "trig", 0x03: "params", 0x11: "off"}


def messages(b):
    i = 0
    while True:
        s = b.find(b"\xf0", i)
        if s < 0:
            return
        e = b.find(b"\xf7", s)
        if e < 0:
            return
        yield b[s:e + 1]
        i = e + 1


def main():
    b = open(sys.argv[1], "rb").read()
    count, other = {}, 0
    for m in messages(b):
        ok = m[1:4] == b"\x7d\x52\x54" and m[4] in NAMES
        if not ok:
            other += 1
            continue
        k = NAMES[m[4]]
        count[k] = count.get(k, 0) + 1
        if "--list" in sys.argv and k != "params":
            d = ""
            if k == "trig":
                d = f"voice {m[5] & 7} machine 0x{m[5] & 0x78:02x} note {m[6]} vel {m[7]} P1 {m[8]} P2 {m[10]} tag {m[-3]:02x}{m[-2]:02x}"
            elif k == "off":
                d = f"voice {m[5]}"
            print(k, d)
    print(count, "other", other, "bytes", len(b))


if __name__ == "__main__":
    main()
