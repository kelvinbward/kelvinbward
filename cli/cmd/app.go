package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
)

var (
	appType string
	appHub  string
)

var appCmd = &cobra.Command{
	Use:   "app",
	Short: "Application spoke management",
}

var appCreateCmd = &cobra.Command{
	Use:   "create [name]",
	Short: "Scaffold a new spoke application",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		createApp(args[0])
	},
}

func init() {
	rootCmd.AddCommand(appCmd)
	appCmd.AddCommand(appCreateCmd)

	appCreateCmd.Flags().StringVarP(&appType, "type", "t", "", "Framework type to scaffold (nextjs, astro)")
	appCreateCmd.MarkFlagRequired("type")
	
	appCreateCmd.Flags().StringVar(&appHub, "hub", "kelvinbward", "Target hub domain (kelvinbward, goobface)")
}

func createApp(name string) {
	appType = strings.ToLower(appType)
	if appType != "nextjs" && appType != "astro" {
		fmt.Printf("❌ Unsupported app type '%s'. Supported types: nextjs, astro\n", appType)
		os.Exit(1)
	}

	root := ResolveWorkspaceRoot()
	targetDir := filepath.Join(root, name)

	if stat, err := os.Stat(targetDir); err == nil && stat.IsDir() {
		fmt.Printf("❌ Directory '%s' already exists in the workspace. Aborting.\n", targetDir)
		os.Exit(1)
	}

	fmt.Printf("🚀 Scaffolding new '%s' app: %s\n", appType, name)

	var scaffoldCmd *exec.Cmd
	if appType == "nextjs" {
		scaffoldCmd = execCommand("npx", "-y", "create-next-app@latest", targetDir, "--typescript", "--tailwind", "--eslint", "--app", "--src-dir", "--import-alias", "@/*")
	} else if appType == "astro" {
		scaffoldCmd = execCommand("npx", "-y", "create-astro@latest", targetDir, "--template", "minimal", "--install", "--no-git", "--yes")
	}

	scaffoldCmd.Stdout = os.Stdout
	scaffoldCmd.Stderr = os.Stderr
	runOrWarn("Scaffold App", scaffoldCmd)

	fmt.Println("📝 Injecting cluster configuration files...")

	// 1. Dockerfile
	dockerfileContent := ""
	if appType == "nextjs" {
		dockerfileContent = `FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]`
	} else if appType == "astro" {
		dockerfileContent = `FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321
CMD ["node", "./dist/server/entry.mjs"]`
	}

	dfPath := filepath.Join(targetDir, "Dockerfile")
	if err := os.WriteFile(dfPath, []byte(dockerfileContent), 0644); err != nil {
		fmt.Printf("⚠️  Failed to write Dockerfile: %v\n", err)
	}

	// 2. docker-compose.yml
	port := "3000"
	if appType == "astro" {
		port = "4321"
	}
	appNameClean := strings.ToLower(strings.ReplaceAll(name, " ", "-"))

	composeContent := fmt.Sprintf(`version: '3.8'

services:
  %s:
    build: .
    container_name: %s-app-1
    restart: unless-stopped
    ports:
      - "%s"
    networks:
      - web_gateway
    # The --hub flag value '%s' could be used here to dynamically label for Traefik if needed,
    # but currently Nginx Proxy Manager uses container names.
    labels:
      - "hub=%s"

networks:
  web_gateway:
    external: true
`, appNameClean, appNameClean, port, appHub, appHub)

	dcPath := filepath.Join(targetDir, "docker-compose.yml")
	if err := os.WriteFile(dcPath, []byte(composeContent), 0644); err != nil {
		fmt.Printf("⚠️  Failed to write docker-compose.yml: %v\n", err)
	}

	// Make it a git repo if not already
	gitInitCmd := execCommand("git", "init")
	gitInitCmd.Dir = targetDir
	_ = gitInitCmd.Run()

	fmt.Println("🔗 Registering application via repos sync...")
	// Cheat local update
	updateConfig = true 
	syncRepos()

	fmt.Printf("✅ Application '%s' scaffolded and registered successfully!\n", name)
}
