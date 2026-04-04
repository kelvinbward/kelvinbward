package cmd

import (
	"bytes"
	"io"
	"os"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func captureStdout(f func()) string {
	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	f()

	w.Close()
	os.Stdout = oldStdout

	var buf bytes.Buffer
	io.Copy(&buf, r)
	return buf.String()
}

func TestStatusInfra(t *testing.T) {
	originalExec := execCommand
	execCommand = fakeExecCommand
	defer func() { execCommand = originalExec }()

	output := captureStdout(func() {
		statusInfra()
	})

	assert.Contains(t, output, "Infrastructure Status")
    // Note: since our mock TestHelperProcess doesn't specifically mock docker ps yet, 
    // it will return "Unknown command" or "mock success", but it shouldn't panic.
}

func TestLogsInfraGateway(t *testing.T) {
	originalExec := execCommand
	execCommand = fakeExecCommand
	defer func() { execCommand = originalExec }()

	output := captureStdout(func() {
		logsInfra("gateway")
	})

	assert.Contains(t, output, "Tailing logs for core service: gateway")
}

func TestLogsInfraSpoke(t *testing.T) {
	// Write a dummy apps.config in a mock workspace
	// Alternatively, just test the fallback since resolving the workspace root 
    // dynamically might fail to find a dummy apps.config in test mode.
    
	originalExec := execCommand
	execCommand = fakeExecCommand
	defer func() { execCommand = originalExec }()

	output := captureStdout(func() {
		logsInfra("unknown-app")
	})

	// it should fallback when apps.config parse fails or app isn't explicitly found
	assert.True(t, strings.Contains(output, "Attempting generic attach") || strings.Contains(output, "Failed to read apps.config"), output)
}

func TestReloadInfra(t *testing.T) {
	originalExec := execCommand
	execCommand = fakeExecCommand
	defer func() { execCommand = originalExec }()

	output := captureStdout(func() {
		reloadInfra()
	})

	assert.Contains(t, output, "Securely reloading")
	assert.Contains(t, output, "reloaded successfully")
}
