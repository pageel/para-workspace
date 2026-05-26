#!/bin/bash

# Node.js Path Resolver for PARA Workspace (v1.8.13)
# BUG-10: Resolves Node path for non-interactive shells

resolve_node() {
  local ws_root="${1:-$WORKSPACE_ROOT}"
  
  # === Lớp 2: Explicit Override qua preferences.node_path ===
  if [ -n "$ws_root" ] && [ -f "$ws_root/.para-workspace.yml" ]; then
    local custom_node_path
    custom_node_path=$(awk '/^preferences:/ {flag=1; next} /^[a-zA-Z]/ {flag=0} flag && /^[[:space:]]*node_path:/ {print $2}' "$ws_root/.para-workspace.yml" | sed "s/\"//g; s/'//g")
    
    if [ -n "$custom_node_path" ] && [ -d "$custom_node_path" ]; then
      export PATH="$custom_node_path:$PATH"
      return 0
    fi
  fi
  
  # === Lớp 1: Tự động phát hiện (Auto-detect) ===
  
  # 1. NVM (Node Version Manager)
  local nvm_dir_path="${NVM_DIR:-$HOME/.nvm}"
  if [ -d "$nvm_dir_path/versions/node" ]; then
    local latest_nvm_ver
    latest_nvm_ver=$(find "$nvm_dir_path/versions/node" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort -V | tail -n 1)
    if [ -n "$latest_nvm_ver" ]; then
      local nvm_bin="$nvm_dir_path/versions/node/$latest_nvm_ver/bin"
      if [ -d "$nvm_bin" ]; then
        export PATH="$nvm_bin:$PATH"
        return 0
      fi
    fi
  fi
  
  # 2. fnm (Fast Node Manager)
  local fnm_bin="$HOME/.fnm/aliases/default/bin"
  if [ -d "$fnm_bin" ]; then
    export PATH="$fnm_bin:$PATH"
    return 0
  fi
  
  # 3. Volta
  local volta_dir_path="${VOLTA_HOME:-$HOME/.volta}"
  local volta_bin="$volta_dir_path/bin"
  if [ -d "$volta_bin" ]; then
    export PATH="$volta_bin:$PATH"
    return 0
  fi
  
  # 4. System Node check (Nếu đã có sẵn trong PATH)
  if command -v node >/dev/null 2>&1; then
    return 0
  fi
  
  # 5. Warning fallback
  echo "⚠️  Warning: Node.js not found in PATH or common managers." >&2
  return 0
}
