package cmd

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
)

var forceClean bool

var gitCmd = &cobra.Command{
	Use:   "git",
	Short: "Git workspace utilities",
}

var gitCleanCmd = &cobra.Command{
	Use:   "clean",
	Short: "Clean and reset all tracked repositories",
	Long: `Resets and cleans all repositories defined by the workspace.
By default (SAFE mode), it preserves known configuration files and untracked data.
Use --force to destructively remove ALL untracked files including secrets.`,
	Run: func(cmd *cobra.Command, args []string) {
		cleanGit()
	},
}

func init() {
	rootCmd.AddCommand(gitCmd)
	gitCmd.AddCommand(gitCleanCmd)
	gitCleanCmd.Flags().BoolVarP(&forceClean, "force", "f", false, "Force clean (removes all untracked files including secrets and data)")
}

func runInDir(dir string, command string, args ...string) (string, error) {
	cmd := exec.Command(command, args...)
	cmd.Dir = dir
	var outBuf, errBuf bytes.Buffer
	cmd.Stdout = &outBuf
	cmd.Stderr = &errBuf
	err := cmd.Run()
	if err != nil {
		return "", fmt.Errorf("%s: %v\nstderr: %s", command, err, errBuf.String())
	}
	return outBuf.String(), nil
}

func getRepos() []string {
	// Re-evaluate the dynamic workspace root
	workspaceRoot := ResolveWorkspaceRoot()

	// We can either execute `repos.sh` and parse it or simply traverse the directory like `repos sync`
	// Doing the traversal here is safer than trying to execute bash and source an array.
	var repos []string
	entries, err := os.ReadDir(workspaceRoot)
	if err != nil {
		return repos
	}

	for _, entry := range entries {
		targetPath := filepath.Join(workspaceRoot, entry.Name())
		if entry.IsDir() {
			gitPath := filepath.Join(targetPath, ".git")
			if stat, err := os.Stat(gitPath); err == nil && stat.IsDir() {
				repos = append(repos, targetPath)
			}
		}
	}
	return repos
}

func cleanGit() {
	mode := "SAFE"
	if forceClean {
		mode = "FORCE"
	}

	fmt.Println("🧹 Git Cleanup Utility")
	fmt.Println("----------------------")
	fmt.Printf("Mode: %s\n", mode)
	fmt.Println("⚠️  WARNING: This command FORCE DELETES (-D) all local branches other than main.")
	fmt.Println("   Ensure you have PUSHED your work to origin before proceeding.")
	fmt.Println("   Stashed changes are saved, but branch context will be lost.")
	fmt.Println("")

	repos := getRepos()
	if len(repos) == 0 {
		fmt.Println("❌ No repositories found.")
		return
	}

	for _, repo := range repos {
		fmt.Printf("Processing %s...\n", repo)
		repoName := filepath.Base(repo)

		if repoName == "pi-cluster-configs" {
			fmt.Println("  🏝️  Sandbox Environment Detected.")

			// Fetch latest
			_, err := runInDir(repo, "git", "fetch", "origin")
			if err != nil {
				fmt.Printf("  ❌ Fetch failed: %v\n", err)
				continue
			}

			// Aggressive Reset
			fmt.Println("  🔄 Resetting to origin/main...")
			_, err = runInDir(repo, "git", "reset", "--hard", "origin/main")
			if err != nil {
				fmt.Printf("  ❌ Reset failed: %v\n", err)
				continue
			}

			// Clean Untracked
			if forceClean {
				fmt.Println("  🔥 [FORCE] Nuking untracked files...")
				if _, err := runInDir(repo, "git", "clean", "-fd"); err != nil {
					fmt.Printf("  ⚠️  clean failed: %v\n", err)
				}
			} else {
				fmt.Println("  🛡️ [SAFE] Cleaning but preserving configuration/data...")
				// We build the equivalent of the bash shell git clean using exclude args
				if _, err := runInDir(repo, "git", "clean", "-fd",
					"-e", "secrets.env",
					"-e", "config.env",
					"-e", "gateway/data",
					"-e", "gateway/letsencrypt",
					"-e", "core-services/postgres_data",
					"-e", "management/data",
					"-e", ".vscode",
					"-e", ".idea"); err != nil {
					fmt.Printf("  ⚠️  safe clean failed: %v\n", err)
				}
			}
		} else {
			// Standard Repo Logic

			statusOut, _ := runInDir(repo, "git", "status", "-s")
			if strings.TrimSpace(statusOut) != "" {
				fmt.Println("  📦 Stashing local changes...")
				if _, err := runInDir(repo, "git", "stash"); err != nil {
					fmt.Printf("  ⚠️  stash failed: %v\n", err)
				}
			}

			// Checkout main if not already
			branchOut, err := runInDir(repo, "git", "symbolic-ref", "--short", "HEAD")
			if err == nil && strings.TrimSpace(branchOut) != "main" {
				fmt.Println("  switched to main...")
				if _, err := runInDir(repo, "git", "checkout", "main"); err != nil {
					fmt.Printf("  ⚠️  checkout failed: %v\n", err)
				}
			}

			// Pull Rebase
			fmt.Println("  ⬇️  Pulling origin main...")
			if _, err := runInDir(repo, "git", "pull", "--rebase", "origin", "main"); err != nil {
				fmt.Printf("  ⚠️  pull failed: %v\n", err)
			}
		}

		// Prune Branches for both cases
		fmt.Println("  ✂️  Pruning local branches...")
		branchesOut, err := runInDir(repo, "git", "branch", "--format=%(refname:short)")
		if err == nil {
			scanner := bufio.NewScanner(strings.NewReader(branchesOut))
			for scanner.Scan() {
				b := scanner.Text()
				if b != "main" && b != "" && !strings.Contains(b, "*") {
					if _, err := runInDir(repo, "git", "branch", "-D", b); err != nil {
						fmt.Printf("  ⚠️  failed to prune branch %s: %v\n", b, err)
					}
				}
			}
		}

		fmt.Println("  ✅ Done.")
		fmt.Println("--------------------------------")
	}

	fmt.Println("🎉 Workspace Cleanup Complete!")
}
