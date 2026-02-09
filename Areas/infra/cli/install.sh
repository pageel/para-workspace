#!/bin/bash

# PARA Workspace Installer
# Sets up aliases and permissions

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
 # Path: Areas/infra/cli -> Root is 3 levels up
WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")")")"
PROJECT_REL_PATH="Projects/para-workspace/repo"

# Helper: Sync only if source is newer or destination doesn't exist
sync_if_newer() {
    local src="$1"
    local dest="$2"
    
    # Check if paths are exactly the same physical file
    if [ -f "$src" ] && [ "$(realpath -m "$src")" == "$(realpath -m "$dest")" ]; then
        return 0
    fi

    if [ ! -f "$dest" ] || [ "$src" -nt "$dest" ]; then
        cp "$src" "$dest"
        return 0
    fi
}

echo "🚀 Installing PARA Workspace CLI & Standards..."

# 1. Ensure all internal scripts are executable
chmod +x "$SCRIPT_DIR/scaffold.sh"
chmod +x "$SCRIPT_DIR/update.sh"
chmod +x "$SCRIPT_DIR/workflow.sh"
chmod +x "$SCRIPT_DIR/plan.sh"
chmod +x "$SCRIPT_DIR/verify.sh"
chmod +x "$SCRIPT_DIR/status.sh"
chmod +x "$SCRIPT_DIR/migrate.sh"
chmod +x "$SCRIPT_DIR/config.sh"
chmod +x "$SCRIPT_DIR/rule.sh"

# 2. Initialize/Sync Workspace Config
"$SCRIPT_DIR/config.sh" list > /dev/null

# 3. Sync global rules to root .agent/rules/
echo "⚖️ Syncing global rules to root .agent/rules/..."
mkdir -p "$WORKSPACE_ROOT/.agent/rules/"
for f in "$WORKSPACE_ROOT/$PROJECT_REL_PATH/Resources/ai-agents/rules/"*.md; do
    if [ -f "$f" ]; then
        sync_if_newer "$f" "$WORKSPACE_ROOT/.agent/rules/$(basename "$f")"
    fi
done

# 4. Sync rules catalog to Resources/
echo "📜 Updating rules catalog in Resources/..."
mkdir -p "$WORKSPACE_ROOT/Resources/ai-agents/rules/"
for f in "$WORKSPACE_ROOT/$PROJECT_REL_PATH/Resources/ai-agents/rules/"*.md; do
    if [ -f "$f" ]; then
        sync_if_newer "$f" "$WORKSPACE_ROOT/Resources/ai-agents/rules/$(basename "$f")"
    fi
done

# 5. Install/Update the root 'para' wrapper
echo "📦 Installing root 'para' wrapper..."
# (Root wrapper always regenerated to ensure path consistency)
cat > "$WORKSPACE_ROOT/para" <<EOL
#!/bin/bash
# PARA Root Wrapper (Auto-generated)
WS_ROOT="\$(cd "\$(dirname "\$0")" && pwd)"
REAL_CLI_DIR="\$WS_ROOT/$PROJECT_REL_PATH"
export WORKSPACE_ROOT="\$WS_ROOT"
cd "\$REAL_CLI_DIR" && ./para "\$@"
EOL
chmod +x "$WORKSPACE_ROOT/para"

# 5. Sync global workflows to Resources/ (for catalog)
echo "📑 Updating workflow catalog in Resources/..."
mkdir -p "$WORKSPACE_ROOT/Resources/ai-agents/workflows/"

# Sync workflows WITHOUT prefix by default (prefix only when conflicts occur during manual install)
for f in "$WORKSPACE_ROOT/$PROJECT_REL_PATH/Resources/ai-agents/workflows/"*.md; do
    if [ -f "$f" ]; then
        sync_if_newer "$f" "$WORKSPACE_ROOT/Resources/ai-agents/workflows/$(basename "$f")"
    fi
done

# 6. Install CORE components to root .agent/
echo "🤖 Installing default slash commands & skills to .agent/..."
mkdir -p "$WORKSPACE_ROOT/.agent/workflows/"
mkdir -p "$WORKSPACE_ROOT/.agent/skills/para-kit/"

# Install ALL workflows from catalog to .agent/workflows/
# This ensures "Factory Reset" capability and full feature availability
for f in "$WORKSPACE_ROOT/$PROJECT_REL_PATH/Resources/ai-agents/workflows/"*.md; do
    if [ -f "$f" ]; then
        sync_if_newer "$f" "$WORKSPACE_ROOT/.agent/workflows/$(basename "$f")"
    fi
done

# Sync Skill content
for f in "$WORKSPACE_ROOT/$PROJECT_REL_PATH/Resources/ai-agents/skills/para-kit/"*; do
    if [ -f "$f" ]; then
        sync_if_newer "$f" "$WORKSPACE_ROOT/.agent/skills/para-kit/$(basename "$f")"
    fi
done

echo ""
echo "🎉 Installation & Sync complete!"
echo "You can now run './para' from the workspace root."
echo ""
echo "Try running:"
echo "  ./para status"
