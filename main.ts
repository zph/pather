#!/usr/bin/env deno run -A

const dirs = Deno.args

import {sortBy} from "https://deno.land/std@0.222.1/collections/sort_by.ts";

type WeightedArgs = {
  [key: string]: number
}
const weightedArgs = dirs.reduce((acc, dir) => {
  const [d, weight] = dir.split(":")

  let p
  try {
    p = Deno.realPathSync(d)
  } catch {
    p = d
  }
  acc[p] = parseInt(weight)
  return acc
}, {} as WeightedArgs)

export const main = () => {
  let path = Deno.env.get("PATH")?.split(":") || []
  let weightedPath: [string, number][] = []
  let weight = 1
  path = [...Object.keys(weightedArgs),...path]
  path = sortBy(path, (i) => i.length)
  path = [...new Set(path)]
  for (const i of path) {
    if (weightedArgs[i]) {
      weight = weightedArgs[i]
    } else {
      if (i.startsWith(Deno.env.get("HOME") + "/.local/bin")) {
        weight = 200
      } else if (i.startsWith(Deno.env.get("HOME") + "")) {
        weight = 100
      } else if (i.startsWith("/opt/homebrew")) {
        weight = 50
      } else if (i.startsWith("/usr/local")) {
        weight = 50
      }
    }
    weightedPath = [...weightedPath, [i, weight]]
  }
  weightedPath = weightedPath.filter(([k, v]) => v >= 0)
  const ordered = [...new Set(sortBy(weightedPath, ([k, v]) => v).reverse())]
  console.log(ordered.map(([k, v]) => k).join(":"))
}
// Learn more at https://deno.land/manual/examples/module_metadata#concepts
if (import.meta.main) {
  main()
}
