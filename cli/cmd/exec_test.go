package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"
)

// fakeExecCommand returns a mock command that will call the test binary itself,
// using a specific test (TestHelperProcess) to simulate output.
func fakeExecCommand(command string, args ...string) *exec.Cmd {
	cs := []string{"-test.run=TestHelperProcess", "--", command}
	cs = append(cs, args...)
	cmd := exec.Command(os.Args[0], cs...)
	cmd.Env = append(os.Environ(), "GO_WANT_HELPER_PROCESS=1")
	return cmd
}

// TestHelperProcess isn't a real test. It's used as a fake command in tests.
func TestHelperProcess(t *testing.T) {
	if os.Getenv("GO_WANT_HELPER_PROCESS") != "1" {
		return
	}

	args := os.Args
	for len(args) > 0 {
		if args[0] == "--" {
			args = args[1:]
			break
		}
		args = args[1:]
	}

	if len(args) == 0 {
		fmt.Fprintf(os.Stderr, "No command!\n")
		os.Exit(2)
	}

	cmd := args[0]

	// MOCK OUTPUTS
	switch cmd {
	case "git":
		fullCmd := strings.Join(args, " ")
		if strings.Contains(fullCmd, "config --get remote.origin.url") {
			fmt.Println("git@github.com:kelvinbward/test-repo.git")
		} else if strings.Contains(fullCmd, "status -s") {
			// Mocking uncommitted changes
			if os.Getenv("MOCK_GIT_STATUS") == "dirty" {
				fmt.Println(" M modified_file.go")
			} else {
				fmt.Print("") // clean
			}
		} else {
			fmt.Println("mock git success")
		}
		os.Exit(0)
	case "docker":
		fmt.Println("mock docker success")
		os.Exit(0)
	case "kelvinbward/scripts/infra/scaffold_dirs.sh", "kelvinbward/scripts/infra/gen_configs.sh", "kelvinbward/scripts/infra/gen_scripts.sh":
		// These paths will naturally be prepended with workspace dir, so a direct match is tricky unless we suffix check
		fmt.Println("mock infra script execution success")
		os.Exit(0)
	default:
		// Fallback for full paths like /some/path/scaffold_dirs.sh
		if strings.HasSuffix(cmd, ".sh") {
			fmt.Println("mock shell script execution success")
			os.Exit(0)
		}
		fmt.Fprintf(os.Stderr, "Unknown command %s\n", cmd)
		os.Exit(1)
	}
}
