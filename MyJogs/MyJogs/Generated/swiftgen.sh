#!/bin/sh

SWIFTGEN="${SRCROOT}/Pods/SwiftGen/bin/swiftgen"
INDIR="$SRCROOT/MyJogs"
OUTDIR="$SRCROOT/MyJogs/Generated"

"$SWIFTGEN" strings "$INDIR"/Ressources/Localizable.strings -t structured-swift4 -o "$OUTDIR"/Strings.swift
"$SWIFTGEN" xcassets "$INDIR/Ressources/Assets.xcassets" -t swift4 -o "$OUTDIR"/Assets.swift
"$SWIFTGEN" fonts "$INDIR/Ressources" -t swift4 -o "$OUTDIR"/Fonts.swift
