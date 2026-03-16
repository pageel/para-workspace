# /config Workflow

> **Version**: 1.5.0

Manage workspace configuration stored in `.para-workspace.yml`.

## Commands

```
/config show              # Display current config
/config update            # Update a value
/config add-project       # Register a new project
```

## Actions

### show

Reads `.para-workspace.yml` and displays workspace name, version, language, and registered projects.

### update

Prompts for key to update, shows current value, applies new value, confirms.

### add-project

Prompts for project name, verifies directory exists, adds to config, confirms.

## Related

- [Workflow /para](./para.md)
- [Workflow /open](./open.md)
- [Workflow /new-project](./new-project.md)

---

_Updated in v1.5.0_
