package cmd

import (
	"bytes"
	"io"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestDockerClean(t *testing.T) {
	originalExec := execCommand
	execCommand = fakeExecCommand
	defer func() { execCommand = originalExec }()

	// Overwrite stdin response to simulate user typing "y"
	r, w, _ := os.Pipe()
	w.WriteString("y\n")
	w.Close()
	
	oldStdin := os.Stdin
	os.Stdin = r
	defer func() { os.Stdin = oldStdin }()

	output := captureStdout(func() {
		cleanDocker()
	})

	assert.Contains(t, output, "Nuking Docker state")
	assert.Contains(t, output, "completely clean")
}

func TestDockerComposeAcrossAll(t *testing.T) {
	originalExec := execCommand
	execCommand = fakeExecCommand
	defer func() { execCommand = originalExec }()

	// Create a mock workspace
	mockRoot := t.TempDir()
	originalResolve := ResolveWorkspaceRoot
	ResolveWorkspaceRoot = func() string { return mockRoot }
	defer func() { ResolveWorkspaceRoot = originalResolve }()

	// Scaffold pi-cluster-configs
	infraDir := filepath.Join(mockRoot, "pi-cluster-configs")
	gatewayDir := filepath.Join(infraDir, "gateway")
	os.MkdirAll(gatewayDir, 0755)
	os.WriteFile(filepath.Join(gatewayDir, "docker-compose.yml"), []byte("services:"), 0644)

	// Scaffold a repo
	repoDir := filepath.Join(mockRoot, "resume")
	os.MkdirAll(repoDir, 0755)
	os.MkdirAll(filepath.Join(repoDir, ".git"), 0755)
	os.WriteFile(filepath.Join(repoDir, "docker-compose.standalone.yml"), []byte("services:"), 0644)

	// Run the logic
	output := captureStdout(func() {
		runComposeAcrossAll([]string{"up", "-d"})
	})

	assert.Contains(t, output, "gateway")
	assert.Contains(t, output, "resume")
	assert.Contains(t, output, "Success")
}
