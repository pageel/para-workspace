# Workspace Rules Index

> Agent loads a specific rule ONLY WHEN the current action matches its trigger.
> This index is read by `/open` Step 2.5a (ALWAYS) and `/plan` Step 2.7D.

| Rule                    | Trigger                                                         | File                             |
| :---------------------- | :-------------------------------------------------------------- | :------------------------------- |
| Governance              | Touching kernel/, .para/, or system files                       | rules/governance.md              |
| Hybrid 3-File Integrity | Reading/writing artifacts/tasks/, ad-hoc requests, running /end | rules/hybrid-3-file-integrity.md |
| Context Rules           | Loading context, starting session, detecting project            | rules/context-rules.md           |
| Agent Behavior          | Agent communication, formatting responses                       | rules/agent-behavior.md          |
| PARA Discipline         | Creating/moving files, organizing workspace                     | rules/para-discipline.md         |
| Artifact Standard       | Creating/editing artifacts, plans, walkthroughs                 | rules/artifact-standard.md       |
| Naming                  | Creating files, directories, branches, commits                  | rules/naming.md                  |
| VCS                     | Git commit, push, branch operations                             | rules/vcs.md                     |
| Versioning              | Version bumps, changelog updates, releases                      | rules/versioning.md              |
| Exports Data            | Exporting data, sharing files externally                        | rules/exports-data.md            |
