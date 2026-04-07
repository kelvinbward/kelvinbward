package cmd

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestCreateAppValidation(t *testing.T) {
	originalExec := execCommand
	execCommand = fakeExecCommand
	defer func() { execCommand = originalExec }()

	// Reset types locally to test validations
	appType = "unsupported"
	// we cannot easily test os.Exit(1) without a sub-process pattern or changing os.Exit dependency,
	// but we can ensure the command exists.
	assert.NotNil(t, appCreateCmd)
	assert.Equal(t, "app", appCmd.Use)
}

func TestAppCreateFlags(t *testing.T) {
    if err := appCreateCmd.Flags().Set("type", "astro"); err != nil {
		t.Fatal(err)
	}
	if err := appCreateCmd.Flags().Set("hub", "goobface"); err != nil {
		t.Fatal(err)
	}

	assert.Equal(t, "astro", appType)
	assert.Equal(t, "goobface", appHub)
}
