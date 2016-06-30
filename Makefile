scripts/paths: **/*
	hammer query '|{{.Name}}| {{.SpecRoot}}' > scripts/paths
	sed -i '' "s|$(shell pwd)/||g" scripts/paths
