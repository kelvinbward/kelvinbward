package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

// ResolveWorkspaceRoot determines the root data dir of the workspace
func ResolveWorkspaceRoot() string {
	// 1. Check KELVIN_WORKSPACE_ROOT env var
	if root := os.Getenv("KELVIN_WORKSPACE_ROOT"); root != "" {
		return filepath.Clean(root)
	}

	// 2. Walk upward from CWD looking for a directory that contains
	//    a "kelvinbward" subdirectory (the anchor repo)
	cwd, err := os.Getwd()
	if err != nil {
		fmt.Fprintf(os.Stderr, "❌ Failed to get current directory: %v\n", err)
		os.Exit(1)
	}

	dir := cwd
	for {
		candidate := filepath.Join(dir, "kelvinbward")
		if info, err := os.Stat(candidate); err == nil && info.IsDir() {
			return dir
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			break
		}
		dir = parent
	}

	// 3. Fallback: assume running from within kelvinbward/cli
	return filepath.Clean(filepath.Join(cwd, "..", ".."))
}

var rootCmd = &cobra.Command{
	Use:   "kelvin-cli",
	Short: "Kelvin ecosystem orchestrator",
	Long: `A unified infrastructure and management CLI tool for the Kelvin Ecosystem.
This tool replaces the legacy bash/python utility toolchain.`,
}

// Execute adds all child commands to the root command and sets flags appropriately.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func init() {
	// Flags can be defined here, e.g. rootCmd.PersistentFlags().BoolVarP(&Verbose, "verbose", "v", false, "verbose output")
}
