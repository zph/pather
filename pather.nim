#!/usr/bin/env nim

import std/os
import std/strutils
import std/sugar
import std/sequtils
import std/strformat
import std/logging

# Rewrite using std/with https://nim-lang.github.io/Nim/with.html
iterator reverse*[T](a: seq[T]): T {.inline.} =
    var i = len(a) - 1
    while i > -1:
        yield a[i]
        dec(i)

proc pather(separator = ":", debug = false, frontloadDirs: seq[string]): int =
  var lvl: Level
  if debug:
    lvl = lvlDebug
  else:
    lvl = lvlInfo

  var logger = newConsoleLogger(levelThreshold=lvl)
  addHandler(logger)

  var returnCode = 0
  var path = getEnv("PATH")
  var paths = path.split(separator)
  var px = collect:
    for p in paths:
      absolutePath p

  for p in reverse(frontloadDirs):
    px.insert(p, 0)
  debug(&"Paths: {px}")

  let dedupedPx = deduplicate(px)
  echo(join(dedupedPx, ":"))
  return min(127, returnCode)

import cligen; dispatch pather
