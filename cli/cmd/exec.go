package cmd

import "os/exec"

// execCommand is a variable pointing to exec.Command. 
// It allows us to swap the real command execution with a mock in our tests.
var execCommand = exec.Command
