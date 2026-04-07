package cmd

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestResolveWorkspaceRoot(t *testing.T) {
	// Test case 1: Using Env Var
	t.Run("EnvVarPriority", func(t *testing.T) {
		expected := "/tmp/mock-workspace"
		os.Setenv("KELVIN_WORKSPACE_ROOT", expected)
		defer os.Unsetenv("KELVIN_WORKSPACE_ROOT") // cleanup

		actual := ResolveWorkspaceRoot()
		assert.Equal(t, expected, actual, "Should prioritize KELVIN_WORKSPACE_ROOT env var")
	})

	// Test case 2: Directory traversal fallback
	// This is slightly tricky to test purely unit without scaffolding a fake filesystem,
	// but we know that running tests will be inside `kelvinbward/cli/cmd`, so walking
	// upwards will naturally find `kelvinbward`.
	t.Run("DirectoryTraversal", func(t *testing.T) {
		os.Unsetenv("KELVIN_WORKSPACE_ROOT")
		cwd, _ := os.Getwd()
		
		// Expected root would be two levels up from kelvinbward/cli/cmd, i.e., kelvinbward is inside it.
		// Wait, the real layout is: Workspaces -> kelvinbward -> cli -> cmd.
		// So the workspace root is the parent of kelvinbward.
		candidate := filepath.Clean(filepath.Join(cwd, "..", "..", ".."))

		actual := ResolveWorkspaceRoot()
		assert.Equal(t, candidate, actual, "Should default to parent directory of kelvinbward")
	})
}
