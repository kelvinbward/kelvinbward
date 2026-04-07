package cmd

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestRunInDir(t *testing.T) {
	// Temporarily swap execCommand with our fake implementation
	originalExec := execCommand
	execCommand = fakeExecCommand
	defer func() { execCommand = originalExec }()

	os.Setenv("MOCK_GIT_STATUS", "dirty")
	defer os.Unsetenv("MOCK_GIT_STATUS")

	out, err := runInDir(".", "git", "status", "-s")
	assert.NoError(t, err)
	assert.True(t, out != "", "Mock git status should return dirty output")
}

// In a real scenario we could test getRepos() by mocking the filesystem,
// but for now, testing the exec abstraction is the primary goal.
