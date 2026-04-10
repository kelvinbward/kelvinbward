package cmd

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
)

func runOrWarn(label string, cmd *exec.Cmd) {
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "⚠️  %s: %v\n", label, err)
	}
}

var runSetup bool

var infraCmd = &cobra.Command{
	Use:   "infra",
	Short: "Infrastructure management commands",
}

var infraCleanCmd = &cobra.Command{
	Use:   "clean",
	Short: "Stop local cluster services",
	Long:  "Stops and removes local cluster services provisioned by init_infra.sh without deleting configs.",
	Run: func(cmd *cobra.Command, args []string) {
		cleanInfra()
	},
}

var infraInitCmd = &cobra.Command{
	Use:   "init",
	Short: "Initialize private cloud orchestrator",
	Long:  "Initializes the shared infrastructure required by the public repositories by calling modular sub-scripts.",
	Run: func(cmd *cobra.Command, args []string) {
		initInfra()
	},
}

func init() {
	rootCmd.AddCommand(infraCmd)
	infraCmd.AddCommand(infraCleanCmd)
	infraCmd.AddCommand(infraInitCmd)
	infraCmd.AddCommand(infraStatusCmd)
	infraCmd.AddCommand(infraLogsCmd)
	infraCmd.AddCommand(infraReloadCmd)

	infraInitCmd.Flags().BoolVarP(&runSetup, "setup", "s", false, "Automatically run setup.sh after initialization")
}

var infraReloadCmd = &cobra.Command{
	Use:   "reload",
	Short: "Securely bounce the Nginx gateway router",
	Run: func(cmd *cobra.Command, args []string) {
		reloadInfra()
	},
}

var infraStatusCmd = &cobra.Command{
	Use:   "status",
	Short: "Check health of the ecosystem cluster",
	Run: func(cmd *cobra.Command, args []string) {
		statusInfra()
	},
}

var infraLogsCmd = &cobra.Command{
	Use:   "logs [app_name]",
	Short: "Tail logs for a specific application in the cluster",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		logsInfra(args[0])
	},
}

func initInfra() {
	fmt.Println("🚀 Starting Private Cloud Bootstrap...")

	workspaceRoot := ResolveWorkspaceRoot()
	targetDir := filepath.Join(workspaceRoot, "pi-cluster-configs")

	fmt.Printf("📂 Target Directory: %s\n", targetDir)

	// 1. Network Setup
	fmt.Println("🔌 [Step 1] Checking Docker Network...")
	netCheck := execCommand("docker", "network", "ls")
	out, err := netCheck.Output()
	if err != nil || !strings.Contains(string(out), "web_gateway") {
		fmt.Println("   Creating 'web_gateway' network...")
		err = execCommand("docker", "network", "create", "web_gateway").Run()
		if err != nil {
			fmt.Printf("❌ Failed to create network: %v\n", err)
		}
	} else {
		fmt.Println("   ✅ 'web_gateway' network exists.")
	}

	// 2. Bootstrap
	if runSetup {
		fmt.Println("🚀 Executing setup.sh...")
		setupScriptPath := filepath.Join(targetDir, "setup.sh")

		triggerSetup := execCommand(setupScriptPath)
		triggerSetup.Dir = targetDir
		triggerSetup.Stdout = os.Stdout
		triggerSetup.Stderr = os.Stderr

		if err := triggerSetup.Run(); err != nil {
			fmt.Printf("❌ setup.sh execution failed: %v\n", err)
		} else {
			fmt.Println("✅ setup.sh executed successfully.")
		}
	} else {
		fmt.Println("\n✅ Network ready.")
		fmt.Println("========================================================================")
		fmt.Println("To start your Private Cloud infrastructure:")
		fmt.Println("")
		fmt.Println("  cd " + targetDir)
		fmt.Println("  ./setup.sh")
		fmt.Println("")
		fmt.Println("Or re-run with --setup to do this automatically:")
		fmt.Println("  kelvin-cli infra init --setup")
		fmt.Println("========================================================================")
	}
}

func cleanInfra() {
	fmt.Println("🧹 Infrastructure Cleanup Utility")
	fmt.Println("⚠️  WARNING: This will stop and remove the local cluster services provisioned by init_infra.sh.")
	fmt.Println("   It will not delete configuration files.")
	fmt.Print("   Are you sure you want to proceed? (y/N) ")

	reader := bufio.NewReader(os.Stdin)
	response, _ := reader.ReadString('\n')
	response = strings.TrimSpace(strings.ToLower(response))

	if response == "y" || response == "yes" {
		fmt.Println("🛑 Stopping services in pi-cluster-configs...")

		// Determine workspace root dynamically
		workspaceRoot := ResolveWorkspaceRoot()
		targetDir := filepath.Join(workspaceRoot, "pi-cluster-configs")

		services := []string{"gateway", "core-services", "management"}

		for _, svc := range services {
			svcPath := filepath.Join(targetDir, svc)
			if stat, err := os.Stat(svcPath); err == nil && stat.IsDir() {
				fmt.Printf("   Stopping %s...\n", svc)
				downCmd := execCommand("docker", "compose", "down")
				downCmd.Dir = svcPath
				// Capture output just to hide it unless there's an error, like bash >/dev/null
				_ = downCmd.Run()
			}
		}

		fmt.Println("🕸️  Removing web_gateway network...")
		netCmd := execCommand("docker", "network", "rm", "web_gateway")
		runOrWarn("docker network rm web_gateway", netCmd)

		fmt.Println("✅ Infrastructure cleanup complete.")
	} else {
		fmt.Println("🛑 Aborted.")
	}
}

func statusInfra() {
	fmt.Println("📊 Infrastructure Status")
	fmt.Println("------------------------")
	
	// We filter by the web_gateway network to show only ecosystem-related containers
	cmd := execCommand("docker", "ps", "-a", "--filter", "network=web_gateway", "--format", "table {{.Names}}\t{{.State}}\t{{.Status}}\t{{.Ports}}")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	runOrWarn("docker ps", cmd)
	
	fmt.Println("------------------------")
}

func logsInfra(target string) {
	target = strings.ToLower(target)
	root := ResolveWorkspaceRoot()

	// Core infrastructure specific folders
	switch target {
	case "gateway", "core-services", "management":
		fmt.Printf("🔍 Tailing logs for core service: %s\n", target)
		cmd := execCommand("docker", "compose", "logs", "-f")
		cmd.Dir = filepath.Join(root, "pi-cluster-configs", target)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		runOrWarn("docker compose logs", cmd)
		return
	}

	// Try to find it in apps.config
	configFile := filepath.Join(root, "pi-cluster-configs", "apps.config")
	content, err := os.ReadFile(configFile)
	if err != nil {
		fmt.Println("❌ Failed to read apps.config")
		return
	}

	lines := strings.Split(string(content), "\n")
	hostVar := fmt.Sprintf("APP_%s_HOST=", strings.ToUpper(target))

	var containerName string
	for _, line := range lines {
		if strings.HasPrefix(line, hostVar) {
			containerName = strings.Trim(strings.TrimPrefix(line, hostVar), "\"' ")
			break
		}
	}

	if containerName == "" {
		// Fallback to expecting the container is just named the target
		fmt.Printf("⚠️  Application '%s' not explicitly found in apps.config. Attempting generic attach...\n", target)
		containerName = target
	} else {
		fmt.Printf("🔍 Tailing logs for spoke: %s (Container: %s)\n", target, containerName)
	}

	cmd := execCommand("docker", "logs", "-f", containerName)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	runOrWarn("docker logs", cmd)
}

func reloadInfra() {
	fmt.Println("🔄 Securely reloading Gateway Router without downtime...")
	root := ResolveWorkspaceRoot()
	cmd := execCommand("docker", "compose", "restart")
	cmd.Dir = filepath.Join(root, "pi-cluster-configs", "gateway")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	runOrWarn("docker compose restart gateway", cmd)
	fmt.Println("✅ Gateway reloaded successfully.")
}

