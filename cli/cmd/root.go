package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

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
