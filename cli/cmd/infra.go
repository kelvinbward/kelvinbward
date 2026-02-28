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

	infraInitCmd.Flags().BoolVarP(&runSetup, "setup", "s", false, "Automatically run setup.sh after initialization")
}

func initInfra() {
	fmt.Println("🚀 Starting Private Cloud Bootstrap...")

	// Determine workspace root dynamically
	cwd, err := os.Getwd()
	if err != nil {
		fmt.Printf("❌ Failed to get current directory: %v\n", err)
		os.Exit(1)
	}
	// Binary runs from kelvinbward/cli, so up two relative up to workspace
	workspaceRoot := filepath.Clean(filepath.Join(cwd, "..", ".."))

	targetDir := filepath.Join(workspaceRoot, "pi-cluster-configs")
	infraScriptsDir := filepath.Join(workspaceRoot, "kelvinbward", "scripts", "infra")

	fmt.Printf("📂 Target Directory: %s\n", targetDir)

	// 1. Network Setup
	fmt.Println("🔌 [Step 1] Checking Docker Network...")
	netCheck := exec.Command("docker", "network", "ls")
	out, err := netCheck.Output()
	if err != nil || !strings.Contains(string(out), "web_gateway") {
		fmt.Println("   Creating 'web_gateway' network...")
		err = exec.Command("docker", "network", "create", "web_gateway").Run()
		if err != nil {
			fmt.Printf("❌ Failed to create network: %v\n", err)
		}
	} else {
		fmt.Println("   ✅ 'web_gateway' network exists.")
	}

	// 2. Scouting & Scaffolding
	fmt.Println("📁 [Step 2] Scaffolding Directories...")
	scaffoldCmd := exec.Command(filepath.Join(infraScriptsDir, "scaffold_dirs.sh"), targetDir)
	scaffoldCmd.Stdout = os.Stdout
	scaffoldCmd.Stderr = os.Stderr
	_ = scaffoldCmd.Run()

	// 3. Generating Configurations
	fmt.Println("📝 [Step 3] Generating Docker Configs...")
	genConfigsCmd := exec.Command(filepath.Join(infraScriptsDir, "gen_configs.sh"), targetDir)
	genConfigsCmd.Stdout = os.Stdout
	genConfigsCmd.Stderr = os.Stderr
	_ = genConfigsCmd.Run()

	// 4. Generating Automation Scripts
	fmt.Println("⚙️ [Step 4] Generating Helper Scripts...")
	genScriptsCmd := exec.Command(filepath.Join(infraScriptsDir, "gen_scripts.sh"), targetDir)
	genScriptsCmd.Stdout = os.Stdout
	genScriptsCmd.Stderr = os.Stderr
	_ = genScriptsCmd.Run()

	// 5. Bootstrap Instructions
	fmt.Println("\n✅ Bootstrap Complete!")

	if runSetup {
		fmt.Println("🚀 Executing setup.sh automatically...")
		setupScriptPath := filepath.Join(targetDir, "setup.sh")

		// Setup script might need to execute docker commands from within targetDir
		triggerSetup := exec.Command(setupScriptPath)
		triggerSetup.Dir = targetDir
		triggerSetup.Stdout = os.Stdout
		triggerSetup.Stderr = os.Stderr

		if err := triggerSetup.Run(); err != nil {
			fmt.Printf("❌ setup.sh execution failed: %v\n", err)
		} else {
			fmt.Println("✅ setup.sh executed successfully.")
		}
	} else {
		fmt.Println("========================================================================")
		fmt.Println("To start your Private Cloud infrastructure:")
		fmt.Println("")
		fmt.Println("1. Configure Applications (Optional):")
		fmt.Printf("   Edit apps.config in %s to enable/disable specific apps.\n", targetDir)
		fmt.Println("")
		fmt.Println("2. Start the Gateway (Nginx Proxy Manager):")
		fmt.Printf("   cd %s/gateway\n", targetDir)
		fmt.Println("   docker compose up -d")
		fmt.Println("")
		fmt.Println("3. Start Core Services (Database):")
		fmt.Printf("   cd %s/core-services\n", targetDir)
		fmt.Println("   docker compose up -d")
		fmt.Println("")
		fmt.Println("4. Start Management Services (Portainer):")
		fmt.Printf("   cd %s/management\n", targetDir)
		fmt.Println("   docker compose up -d")
		fmt.Println("")
		fmt.Println("5. Run the orchestration setup:")
		fmt.Printf("   cd %s\n", targetDir)
		fmt.Println("   ./setup.sh")
		fmt.Println("")
		fmt.Println("Your environment is now ready to support the public apps!")
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
		cwd, err := os.Getwd()
		if err != nil {
			fmt.Printf("❌ Failed to get current directory: %v\n", err)
			os.Exit(1)
		}
		workspaceRoot := filepath.Clean(filepath.Join(cwd, "..", ".."))
		targetDir := filepath.Join(workspaceRoot, "pi-cluster-configs")

		services := []string{"gateway", "core-services", "management"}

		for _, svc := range services {
			svcPath := filepath.Join(targetDir, svc)
			if stat, err := os.Stat(svcPath); err == nil && stat.IsDir() {
				fmt.Printf("   Stopping %s...\n", svc)
				downCmd := exec.Command("docker", "compose", "down")
				downCmd.Dir = svcPath
				// Capture output just to hide it unless there's an error, like bash >/dev/null
				_ = downCmd.Run()
			}
		}

		fmt.Println("🕸️  Removing web_gateway network...")
		netCmd := exec.Command("docker", "network", "rm", "web_gateway")
		_ = netCmd.Run()

		fmt.Println("✅ Infrastructure cleanup complete.")
	} else {
		fmt.Println("🛑 Aborted.")
	}
}
