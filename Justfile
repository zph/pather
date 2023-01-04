release-build: dist-pather

dist-pather:
  nim c -o:dist/pather -d:release pather.nim

run *args:
  nim c --run pather.nim {{args}}

setup:
  nimble install cligen
