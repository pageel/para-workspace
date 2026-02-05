# /kickoff <project-name>

> Initialize a new PARA project with standard scaffolding and artifacts.

## Steps

1. **Scaffold Project**:
   ```bash
   ./para scaffold <project-name>
   ```

2. **Define Goal**:
   - Update `Projects/<project-name>/project.md` with specific Goals and Done Conditions.

3. **Initialize Task List**:
   - Edit `Projects/<project-name>/artifacts/tasks.md` to reflect the initial roadmap.

4. **Start First Session**:
   - Record the kickoff in `Projects/<project-name>/sessions/$(date +%Y-%m-%d).md`.

## Output Checklist
- [ ] Project folder structure created
- [ ] Registered in `metadata.json`
- [ ] Goals defined in `project.md`
- [ ] `tasks.md` initialized
