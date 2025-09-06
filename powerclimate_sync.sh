#!/bin/bash
# PowerClimate Development Sync Script
# This script helps manage the development workflow between the PowerClimate repo and HA core development

POWERCLIMATE_PATH="/workspaces/PowerClimate"
CORE_CUSTOM_COMPONENTS="/workspaces/core/config/custom_components/powerclimate"

case "$1" in
    "status")
        echo "=== PowerClimate Git Status ==="
        cd "$POWERCLIMATE_PATH" && git status
        echo ""
        echo "=== Any uncommitted changes in symlinked integration ==="
        cd "$POWERCLIMATE_PATH" && git diff --name-only config/custom_components/powerclimate/
        ;;

    "commit")
        if [ -z "$2" ]; then
            echo "Usage: $0 commit \"commit message\""
            exit 1
        fi
        echo "=== Committing changes to PowerClimate repo ==="
        cd "$POWERCLIMATE_PATH"
        git add config/custom_components/powerclimate/
        git commit -m "$2"
        echo "Changes committed locally. Use 'push' command to sync with GitHub."
        ;;

    "push")
        echo "=== Pushing PowerClimate changes to GitHub ==="
        cd "$POWERCLIMATE_PATH" && git push origin master
        ;;

    "pull")
        echo "=== Pulling latest PowerClimate changes from GitHub ==="
        cd "$POWERCLIMATE_PATH" && git pull origin master
        ;;

    "diff")
        echo "=== Changes in PowerClimate integration ==="
        cd "$POWERCLIMATE_PATH" && git diff config/custom_components/powerclimate/
        ;;

    "test")
        echo "=== Testing PowerClimate integration in HA Core ==="
        cd "/workspaces/core"
        echo "Running pytest for powerclimate..."
        python -m pytest tests/components/powerclimate/ || echo "No tests found yet - create tests in tests/components/powerclimate/"
        ;;

    "restart-ha")
        echo "=== Restarting Home Assistant Core for testing ==="
        cd "/workspaces/core"
        # Kill existing HA process if running
        pkill -f "homeassistant" || true
        sleep 2
        # Start HA core with the custom component
        python -m homeassistant -c ./config --debug
        ;;

    *)
        echo "PowerClimate Development Sync Script"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  status      - Show git status of PowerClimate repo"
        echo "  commit MSG  - Commit changes to PowerClimate repo"
        echo "  push        - Push committed changes to GitHub"
        echo "  pull        - Pull latest changes from GitHub"
        echo "  diff        - Show uncommitted changes"
        echo "  test        - Run tests for the integration"
        echo "  restart-ha  - Restart HA Core for testing"
        echo ""
        echo "Development workflow:"
        echo "1. Make changes to integration files via the symlink"
        echo "2. Test changes: $0 restart-ha"
        echo "3. Commit changes: $0 commit \"Your commit message\""
        echo "4. Push to GitHub: $0 push"
        ;;
esac
