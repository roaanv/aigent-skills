# Project Makefile

.PHONY: setup build run deploy lint scan-secrets

## setup: Install dependencies and configure git hooks
setup:
	@echo "Installing pre-commit..."
	@pip3 install pre-commit --quiet
	@echo "Clearing core.hooksPath if set (required for pre-commit)..."
	@git config --local --unset-all core.hooksPath 2>/dev/null || true
	@echo "Installing git hooks..."
	@python3 -m pre_commit install
	@echo "Setup complete. Git hooks are now active."

## build: Build the project
build:
	@echo "No build step configured."

## run: Run the project
run:
	@echo "No run step configured."

## deploy: Deploy the project
deploy:
	@echo "No deploy step configured."

## lint: Run linters and hooks against all files
lint:
	@python3 -m pre_commit run --all-files

## scan-secrets: Run gitleaks scan on the entire repo history
scan-secrets:
	@gitleaks detect --source . --verbose

## help: Show available targets
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## //' | column -t -s ':'
