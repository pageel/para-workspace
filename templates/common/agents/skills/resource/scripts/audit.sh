#!/bin/bash

echo "🔍 Scanning resources..."

TOTAL_RESOURCES=0
STUDIED_COUNT=0
AUDIT_TABLE_ROWS=""

mkdir -p Areas/Learning/Resources
mkdir -p Resources/references

# Find all namespaces by looking for .git directories
repos=$(find Resources/references -type d -name ".git" 2>/dev/null | sed 's/\/.git$//')

for repo in $repos; do
  namespace=${repo#Resources/references/}
  TOTAL_RESOURCES=$((TOTAL_RESOURCES+1))
  
  main_study="Areas/Learning/Resources/${namespace}.md"
  extractions_dir="Areas/Learning/Resources/${namespace}"
  
  status="🔴"
  main_study_mark="-"
  extractions_mark="-"
  last_updated="-"
  
  # Check if main study exists
  if [ -f "$main_study" ]; then
    status="🟢"
    main_study_mark="Yes"
    STUDIED_COUNT=$((STUDIED_COUNT+1))
    last_updated=$(date -r "$main_study" "+%Y-%m-%d" 2>/dev/null || stat -c %y "$main_study" 2>/dev/null | cut -d' ' -f1)
  fi
  
  # Check if partial extractions exist
  if [ -d "$extractions_dir" ]; then
    if find "$extractions_dir" -type f -name "*.md" | grep -q .; then
      extractions_mark="Yes"
      if [ "$status" = "🔴" ]; then
        status="🟡"
        last_updated=$(date -r "$extractions_dir" "+%Y-%m-%d" 2>/dev/null || stat -c %y "$extractions_dir" 2>/dev/null | cut -d' ' -f1)
      fi
    fi
  fi
  
  # Try to extract a short description
  desc="-"
  summary_file="Areas/Learning/Resources/${namespace}/summary.txt"
  if [ -f "$summary_file" ]; then
    extracted=$(head -n 1 "$summary_file" | cut -c 1-55 | tr -d '\n\r`')
    if [ -n "$extracted" ]; then
      desc="${extracted}..."
      desc=${desc//|/ }
    fi
  elif [ -f "$repo/README.md" ]; then
    extracted=$(grep -vE "^[[:space:]]*(#|<|!|\[|\*|=|\||>|-)" "$repo/README.md" 2>/dev/null | grep -v "^$" | head -n 1 | cut -c 1-55 | tr -d '\n\r`')
    if [ -n "$extracted" ]; then
      desc="${extracted}..."
      desc=${desc//|/ }
    fi
  fi
  
  # Format the markdown table row
  row="| $status | \`$namespace\` | $desc | $main_study_mark | $extractions_mark | $last_updated |"
  AUDIT_TABLE_ROWS="${AUDIT_TABLE_ROWS}${row}\n"
done

if [ $TOTAL_RESOURCES -eq 0 ]; then
  COVERAGE_PERCENT=0
else
  COVERAGE_PERCENT=$((STUDIED_COUNT * 100 / TOTAL_RESOURCES))
fi

CURRENT_DATE=$(date "+%Y-%m-%d %H:%M:%S")
TEMPLATE_FILE=".agents/skills/resource/references/audit-dashboard-template.md"
TARGET_FILE="Areas/Learning/Resources/README.md"

if [ -f "$TEMPLATE_FILE" ]; then
  export TOTAL_RESOURCES STUDIED_COUNT COVERAGE_PERCENT CURRENT_DATE
  
  awk -v rows="$(printf '%b' "$AUDIT_TABLE_ROWS")" '
  {
    gsub("{{TOTAL_RESOURCES}}", ENVIRON["TOTAL_RESOURCES"]);
    gsub("{{STUDIED_COUNT}}", ENVIRON["STUDIED_COUNT"]);
    gsub("{{COVERAGE_PERCENT}}", ENVIRON["COVERAGE_PERCENT"]);
    gsub("{{CURRENT_DATE}}", ENVIRON["CURRENT_DATE"]);
    if (index($0, "{{AUDIT_TABLE_ROWS}}") > 0) {
      sub("{{AUDIT_TABLE_ROWS}}", rows);
    }
    print $0
  }' "$TEMPLATE_FILE" > "$TARGET_FILE"
  
  echo "✅ Audit completed! Total: $TOTAL_RESOURCES, Studied: $STUDIED_COUNT ($COVERAGE_PERCENT%)"
  echo "📄 Dashboard saved to $TARGET_FILE"
else
  echo "❌ Error: Template $TEMPLATE_FILE not found."
fi
