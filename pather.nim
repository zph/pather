#!/usr/bin/env nim

import std/os
import std/algorithm
import std/strutils
import std/sugar
import std/sequtils
import std/strformat
import std/logging

type PriorityPath = tuple
  path: string
  priority: int

var paths: seq[PriorityPath]

# Rewrite using std/with https://nim-lang.github.io/Nim/with.html
iterator reverse*[T](a: seq[T]): T {.inline.} =
    var i = len(a) - 1
    while i > -1:
        yield a[i]
        dec(i)

proc byWeight(a, b: PriorityPath): int =
  cmp(b.priority, a.priority)

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
  var pathsRaw = path.split(separator)
  for p in deduplicate(pathsRaw):
    if p.startsWith(getEnv("HOME")):
      paths.add((absolutePath p, 200))
    elif p.startsWith("/usr/local"):
      paths.add((absolutePath p, 100))
    elif p.startsWith("/opt/homebrew"):
      paths.add((absolutePath p, 50))
    else:
      paths.add((absolutePath p, 1))

  algorithm.sort(paths, byWeight)
  var newPaths: seq[string] = @[]
  for p in paths:
    newPaths.add(p.path)

  # TODO: determine how to insert with priority
  for d in frontloadDirs:
    newPaths.insert(d, 0)
  echo(join(newPaths, ":"))
  return min(127, returnCode)

import cligen; dispatch pather
