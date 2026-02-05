#!/bin/bash

# PARA Workspace Installer
# Sets up aliases and permissions

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
 # Path: Areas/infra/cli -> Root is 3 levels up
WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")")")"

echo "🚀 Installing PARA Workspace CLI & Standards..."

# 1. Ensure all internal scripts are executable
chmod +x "$SCRIPT_DIR/scaffold.sh"
chmod +x "$SCRIPT_DIR/update.sh"
chmod +x "$SCRIPT_DIR/workflow.sh"
chmod +x "$SCRIPT_DIR/plan.sh"
chmod +x "$SCRIPT_DIR/verify.sh"
chmod +x "$SCRIPT_DIR/status.sh"
chmod +x "$SCRIPT_DIR/migrate.sh"

# 2. Install/Update the root 'para' wrapper
echo "📦 Installing root 'para' wrapper..."
PROJECT_REL_PATH="Projects/para-workspace/repo"
cat > "$WORKSPACE_ROOT/para" <<EOL
#!/bin/bash
# PARA Root Wrapper (Auto-generated)
WS_ROOT="\$(cd "\$(dirname "\$0")" && pwd)"
REAL_CLI_DIR="\$WS_ROOT/$PROJECT_REL_PATH"
export WORKSPACE_ROOT="\$WS_ROOT"
cd "\$REAL_CLI_DIR" && ./para "\$@"
EOL
chmod +x "$WORKSPACE_ROOT/para"

# 3. Sync global rules to root .agent/rules/
echo "⚖️ Syncing global rules to root .agent/rules/..."
mkdir -p "$WORKSPACE_ROOT/.agent/rules/"
cp "$WORKSPACE_ROOT/$PROJECT_REL_PATH/.agent/rules/para-discipline.md" "$WORKSPACE_ROOT/.agent/rules/"
cp "$WORKSPACE_ROOT/$PROJECT_REL_PATH/.agent/rules/artifact-standard.md" "$WORKSPACE_ROOT/.agent/rules/"

# 4. Sync global workflows to Resources/ (for catalog)
echo "📑 Updating workflow catalog in Resources/..."
mkdir -p "$WORKSPACE_ROOT/Resources/ai-agents/workflows/"
cp -r "$WORKSPACE_ROOT/$PROJECT_REL_PATH/Resources/ai-agents/workflows/"* "$WORKSPACE_ROOT/Resources/ai-agents/workflows/"

echo ""
echo "🎉 Installation & Sync complete!"
echo "You can now run './para' from the workspace root."
echo ""
echo "Try running:"
echo "  ./para status"
