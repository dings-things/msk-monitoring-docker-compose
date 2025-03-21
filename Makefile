ENV_FILE = .env

render:
	@echo "🔧 Using env file: $(ENV_FILE)"
	@mkdir -p generated
	@set -a && . $(ENV_FILE) && set +a && \
	envsubst < templates/prometheus.tmpl.yaml > generated/prometheus.yaml && \
	envsubst < templates/burrow.tmpl.toml > generated/burrow.toml && \
	envsubst < templates/targets.tmpl.json > generated/targets.json
