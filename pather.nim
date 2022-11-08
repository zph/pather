#!/usr/bin/env nim
import std/os
import std/strutils
import std/sugar
import std/sequtils

# Rewrite using std/with https://nim-lang.github.io/Nim/with.html

var path = getEnv("PATH")
var paths = path.split(":")
let px = collect:
  for p in paths:
    absolutePath p

let dedupedPx = deduplicate(px)
echo join(dedupedPx, ":")
