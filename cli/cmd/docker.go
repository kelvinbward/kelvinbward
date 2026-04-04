package cmd

import (
	"bufio"
	"fmt"
	"os"
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

func init() {
	rootCmd.AddCommand(dockerCmd)
	dockerCmd.AddCommand(dockerCleanCmd)
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
