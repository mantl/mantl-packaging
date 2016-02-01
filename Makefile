scripts/paths: **/*
	hammer query '|{{.Name}}| {{.SpecRoot}}' > scripts/paths
