package cmd

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/spf13/cobra"
)

var dockerCmd = &cobra.Command{
	Use:   "docker",
	Short: "Docker management commands",
}

var dockerCleanCmd = &cobra.Command{
	Use:   "clean",
	Short: "Reset Docker to a clean slate",
	Long:  "Destroys ALL Docker containers, networks, images, and volumes.",
	Run: func(cmd *cobra.Command, args []string) {
		cleanDocker()
	},
}

var dockerComposeCmd = &cobra.Command{
	Use:   "compose [args...]",
	Short: "Run docker compose across all available repositories",
	Long:  "Dynamically scans the workspace and infrastructure directories for compose files and runs the given docker compose arguments natively in each.",
	DisableFlagParsing: true,
	Run: func(cmd *cobra.Command, args []string) {
		runComposeAcrossAll(args)
	},
}

func init() {
	rootCmd.AddCommand(dockerCmd)
	dockerCmd.AddCommand(dockerCleanCmd)
	dockerCmd.AddCommand(dockerComposeCmd)
}

func runComposeAcrossAll(args []string) {
	workspaceRoot := ResolveWorkspaceRoot()
	var composeDirs []string

	// 1. Add infra sub-directories
	infraDirs := []string{"gateway", "core-services", "management"}
	for _, dir := range infraDirs {
		infraPath := filepath.Join(workspaceRoot, "pi-cluster-configs", dir)
		if _, err := os.Stat(filepath.Join(infraPath, "docker-compose.yml")); err == nil {
			composeDirs = append(composeDirs, infraPath)
		} else if _, err := os.Stat(filepath.Join(infraPath, "docker-compose.standalone.yml")); err == nil {
			composeDirs = append(composeDirs, infraPath)
		}
	}

	// 2. Add full repositories
	entries, err := os.ReadDir(workspaceRoot)
	if err == nil {
		var folderNames []string
		for _, entry := range entries {
			folderNames = append(folderNames, entry.Name())
		}
		sort.Strings(folderNames)

		for _, name := range folderNames {
			if name == "pi-cluster-configs" {
				// Handled explicitly above since its subdirs contain the compose files
				continue
			}

			repoDir := filepath.Join(workspaceRoot, name)
			info, err := os.Stat(repoDir)
			if err != nil || !info.IsDir() {
				continue
			}

			// Must be a valid repo
			if _, err := os.Stat(filepath.Join(repoDir, ".git")); err != nil {
				continue
			}

			// Must have a compose file
			hasCompose := false
			if _, err := os.Stat(filepath.Join(repoDir, "docker-compose.yml")); err == nil {
				hasCompose = true
			} else if _, err := os.Stat(filepath.Join(repoDir, "docker-compose.standalone.yml")); err == nil {
				hasCompose = true
			}

			if hasCompose {
				composeDirs = append(composeDirs, repoDir)
			}
		}
	}

	if len(composeDirs) == 0 {
		fmt.Println("❌ No docker-compose environment found in the workspace.")
		return
	}

	for _, dir := range composeDirs {
		fmt.Printf("\n🐳 Running 'docker compose %s' in %s...\n", strings.Join(args, " "), filepath.Base(dir))

		fullArgs := append([]string{"compose"}, args...)
		cCmd := execCommand("docker", fullArgs...)
		cCmd.Dir = dir
		cCmd.Stdout = os.Stdout
		cCmd.Stderr = os.Stderr

		if err := cCmd.Run(); err != nil {
			fmt.Printf("❌ Failed in %s: %v\n", filepath.Base(dir), err)
		} else {
			fmt.Printf("✅ Success in %s\n", filepath.Base(dir))
		}
	}
}

func cleanDocker() {
	fmt.Println("🧹 Docker Cleanup Utility")
	fmt.Println("⚠️  WARNING: This will DESTROY ALL Docker containers, networks, images, and volumes.")
	fmt.Print("   Are you sure you want to proceed? (y/N) ")

	reader := bufio.NewReader(os.Stdin)
	response, _ := reader.ReadString('\n')
	response = strings.TrimSpace(strings.ToLower(response))

	if response == "y" || response == "yes" {
		fmt.Println("🚨 Nuking Docker state...")

		// Stop all running containers
		psCmd := execCommand("docker", "ps", "-aq")
		output, err := psCmd.Output()
		if err == nil {
			containerIDs := strings.Fields(string(output))
			if len(containerIDs) > 0 {
				fmt.Println("   Stopping containers...")
				stopArgs := append([]string{"stop"}, containerIDs...)
				stopCmd := execCommand("docker", stopArgs...)
				// Ignore errors on stop, best effort
				_ = stopCmd.Run()
			}
		}

		// Prune everything
		fmt.Println("   Running system prune...")
		pruneCmd := execCommand("docker", "system", "prune", "-a", "--volumes", "-f")
		pruneCmd.Stdout = os.Stdout
		pruneCmd.Stderr = os.Stderr

		if err := pruneCmd.Run(); err != nil {
			fmt.Printf("❌ Docker prune failed: %v\n", err)
			os.Exit(1)
		}

		fmt.Println("✅ Docker is completely clean.")
	} else {
		fmt.Println("🛑 Aborted.")
	}
}
