release-build: dist/pather

dist/pather:
	nim c -o:dist/pather -d:release pather.nim

run:
	nim c --run pather.nim
