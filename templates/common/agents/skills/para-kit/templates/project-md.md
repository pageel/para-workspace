---
# project.md Template — PARA Workspace v1.6.3+
# All fields documented. Required fields marked with ✅.
# Copy this file to Projects/<project-slug>/project.md

name: ""                    # ✅ Human-readable project name
version: "0.1.0"            # Semantic version (MAJOR.MINOR.PATCH)
status: "active"            # ✅ active | paused | done | archived
created: "YYYY-MM-DD"       # Creation date
goal: ""                    # ✅ Project objective (1-2 sentences)
deadline: ""                # Target date (YYYY-MM-DD) or empty
active_plan: ""             # Relative path to current plan (e.g., "plans/my-plan.md")
strategy: ~                 # ✅ Current strategic approach (~ = not yet defined)
roadmap: ~                  # ✅ Relative path to roadmap plan (~ = none)

# Agent configuration (v1.6.2+ — replaces deprecated has_rules)
agent:
  rules: false              # ✅ true if .agents/rules/ exists with project rules
  skills: false             # ✅ true if .agents/skills/ exists with project skills

# Ecosystem (v1.6.0+)
# type: standard            # standard (default) | ecosystem
# ecosystem: ""             # Parent ecosystem slug (for satellite projects)
# satellites: []            # Child project slugs (for ecosystem projects)

upstream: []                # Projects I depend on
downstream: []              # Dependent project slugs
dod: []                     # Definition of Done criteria
last_reviewed: ""           # Last project review date (YYYY-MM-DD)
tags: []                    # Classification tags

milestones:                 # Feature-first milestone tracking
  # - name: "Core MVP"
  #   status: planned       # done | in-progress | planned
  #   shipped_in: ""        # Version (only for done items)
---

# Project: <project-name>

## Goal

_What is the desired outcome of this project?_

## Scope

_What is included and excluded?_

## Definition of Done

_How do we know this project is complete?_

## Links

- Backlog: `artifacts/tasks/backlog.md`
- Sessions: `sessions/`
