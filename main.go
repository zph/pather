package main

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
)

// weightedPath represents a path and its associated weight
type weightedPath struct {
	path   string
	weight int
}

func main() {
	// Parse command line arguments into weighted paths
	weightedArgs := make(map[string]int)
	for _, arg := range os.Args[1:] {
		parts := strings.Split(arg, ":")
		path := parts[0]

		// Try to get real path
		if realPath, err := filepath.EvalSymlinks(path); err == nil {
			path = realPath
		}

		weight := 1
		if len(parts) > 1 {
			if w, err := strconv.Atoi(parts[1]); err == nil {
				weight = w
			}
		}
		weightedArgs[path] = weight
	}

	// Get current PATH environment
	pathEnv := os.Getenv("PATH")
	paths := strings.Split(pathEnv, ":")

	// Add weighted args paths to the beginning
	for path := range weightedArgs {
		paths = append([]string{path}, paths...)
	}

	// Sort paths by length and remove duplicates
	sort.Slice(paths, func(i, j int) bool {
		return len(paths[i]) < len(paths[j])
	})
	paths = removeDuplicates(paths)

	// Create weighted paths
	var weightedPaths []weightedPath
	home := os.Getenv("HOME")

	for _, path := range paths {
		weight := 1

		// Determine weight based on path
		if w, exists := weightedArgs[path]; exists {
			weight = w
		} else if strings.HasPrefix(path, filepath.Join(home, ".local/bin")) {
			weight = 200
		} else if strings.HasPrefix(path, home) {
			weight = 100
		} else if strings.HasPrefix(path, "/opt/homebrew") {
			weight = 50
		} else if strings.HasPrefix(path, "/usr/local") {
			weight = 50
		}

		weightedPaths = append(weightedPaths, weightedPath{path: path, weight: weight})
	}

	// Filter out negative weights
	var filteredPaths []weightedPath
	for _, wp := range weightedPaths {
		if wp.weight >= 0 {
			filteredPaths = append(filteredPaths, wp)
		}
	}

	// Sort by weight in descending order
	sort.Slice(filteredPaths, func(i, j int) bool {
		return filteredPaths[i].weight > filteredPaths[j].weight
	})

	// Remove duplicates while maintaining order
	filteredPaths = removeDuplicateWeightedPaths(filteredPaths)

	// Join paths with colon and print
	var result []string
	for _, wp := range filteredPaths {
		result = append(result, wp.path)
	}
	fmt.Println(strings.Join(result, ":"))
}

func removeDuplicates(paths []string) []string {
	seen := make(map[string]bool)
	var result []string
	for _, path := range paths {
		if !seen[path] {
			seen[path] = true
			result = append(result, path)
		}
	}
	return result
}

func removeDuplicateWeightedPaths(paths []weightedPath) []weightedPath {
	seen := make(map[string]bool)
	var result []weightedPath
	for _, wp := range paths {
		if !seen[wp.path] {
			seen[wp.path] = true
			result = append(result, wp)
		}
	}
	return result
}
