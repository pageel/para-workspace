#!/usr/bin/env bash
# validator.sh — Parse catalog.yml and validate kernel compatibility
# Usage: source cli/lib/validator.sh
#        validate_catalog "$catalog_file" "$kernel_version"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Compare semver: returns 0 if $1 >= $2
semver_gte() {
  local v1="$1" v2="$2"
  # Strip anything after the semver core (e.g., -build.6)
  v1="${v1%%-*}"
  v2="${v2%%-*}"

  IFS='.' read -r v1_major v1_minor v1_patch <<< "$v1"
  IFS='.' read -r v2_major v2_minor v2_patch <<< "$v2"

  v1_major=${v1_major:-0}; v1_minor=${v1_minor:-0}; v1_patch=${v1_patch:-0}
  v2_major=${v2_major:-0}; v2_minor=${v2_minor:-0}; v2_patch=${v2_patch:-0}

  if (( v1_major > v2_major )); then return 0; fi
  if (( v1_major < v2_major )); then return 1; fi
  if (( v1_minor > v2_minor )); then return 0; fi
  if (( v1_minor < v2_minor )); then return 1; fi
  if (( v1_patch >= v2_patch )); then return 0; fi
  return 1
}

# Validate a single catalog file against the workspace kernel version
# Usage: validate_catalog "/path/to/catalog.yml" "1.4.0"
validate_catalog() {
  local catalog_file="$1"
  local kernel_version="$2"

  if [[ ! -f "$catalog_file" ]]; then
    echo -e "${YELLOW}⚠ Warning: catalog not found: $catalog_file${NC}"
    return 1
  fi

  local library_name
  library_name=$(grep "^library:" "$catalog_file" | head -1 | awk '{print $2}')

  echo -e "  Checking ${library_name:-unknown} catalog..."

  local errors=0
  local items=0

  # Simple YAML parsing for kernel_min fields
  while IFS= read -r line; do
    if [[ "$line" =~ kernel_min:\ *\"?([0-9]+\.[0-9]+\.[0-9]+)\"? ]]; then
      local min_ver="${BASH_REMATCH[1]}"
      ((items++))
      if ! semver_gte "$kernel_version" "$min_ver"; then
        echo -e "    ${RED}✗ Item requires kernel >=$min_ver, workspace has $kernel_version${NC}"
        ((errors++))
      fi
    fi
  done < "$catalog_file"

  if (( errors > 0 )); then
    echo -e "    ${RED}✗ $errors/$items items incompatible${NC}"
    return 1
  elif (( items > 0 )); then
    echo -e "    ${GREEN}✓ $items items compatible${NC}"
    return 0
  else
    echo -e "    ${YELLOW}⚠ No items found in catalog${NC}"
    return 0
  fi
}

# Validate all catalogs in a directory
# Usage: validate_all_catalogs "/path/to/templates/common/agent" "1.4.0"
validate_all_catalogs() {
  local base_dir="$1"
  local kernel_version="$2"
  local total_errors=0

  echo "Validating library catalogs (kernel=$kernel_version)..."

  for lib_dir in workflows rules skills; do
    local catalog="$base_dir/$lib_dir/catalog.yml"
    if [[ -f "$catalog" ]]; then
      if ! validate_catalog "$catalog" "$kernel_version"; then
        ((total_errors++))
      fi
    fi
  done

  if (( total_errors > 0 )); then
    echo -e "${RED}✗ $total_errors library catalogs have incompatible items${NC}"
    return 1
  fi

  echo -e "${GREEN}✓ All library catalogs are compatible${NC}"
  return 0
}
