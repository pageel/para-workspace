#!/usr/bin/env python3
"""
PARA Workspace — Conversation Transcript Parser
Parses the Antigravity conversation transcript (JSONL) to extract telemetry,
including tool execution counts, executed commands, files read/written, and model thinking.
Optimized for token efficiency by processing logs locally instead of reading them into context.
"""

import sys
import os
import json

def find_latest_transcript():
    """Locates the most recently modified transcript.jsonl in default directories."""
    home = os.path.expanduser("~")
    possible_dirs = [
        os.path.join(home, ".gemini", "antigravity-ide", "brain"),
        os.path.join(home, ".gemini", "antigravity", "brain")
    ]
    
    latest_time = 0
    latest_transcript = None
    
    for base_dir in possible_dirs:
        if not os.path.exists(base_dir):
            continue
        try:
            for conv_id in os.listdir(base_dir):
                conv_path = os.path.join(base_dir, conv_id)
                if not os.path.isdir(conv_path):
                    continue
                log_file = os.path.join(conv_path, ".system_generated", "logs", "transcript.jsonl")
                if os.path.exists(log_file):
                    mtime = os.path.getmtime(log_file)
                    if mtime > latest_time:
                        latest_time = mtime
                        latest_transcript = log_file
        except Exception:
            pass
                    
    return latest_transcript

def main():
    transcript_path = None
    if len(sys.argv) > 1:
        arg = sys.argv[1]
        if os.path.isfile(arg):
            transcript_path = arg
        elif os.path.isdir(arg):
            # Check common subdirectories
            for rel in ["transcript.jsonl", os.path.join(".system_generated", "logs", "transcript.jsonl")]:
                p = os.path.join(arg, rel)
                if os.path.exists(p):
                    transcript_path = p
                    break
    
    if not transcript_path:
        transcript_path = find_latest_transcript()
        
    if not transcript_path or not os.path.exists(transcript_path):
        print("Error: Could not find transcript.jsonl. Please specify the path as an argument.", file=sys.stderr)
        print("Usage: python3 parse-transcript.py [path_to_transcript_or_directory]", file=sys.stderr)
        sys.exit(1)
        
    print(f"Parsing transcript: {transcript_path}\n")
    
    files_read = set()
    files_mutated = {}
    tools_count = {}
    commands = []
    frictions = []
    
    with open(transcript_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line_num, line in enumerate(f, 1):
            try:
                data = json.loads(line)
                source = data.get("source")
                step_type = data.get("type")
                step_idx = data.get("step_index", line_num)
                content = data.get("content", "")
                
                # Extract tool call usage from MODEL responses
                if source == "MODEL" and step_type == "PLANNER_RESPONSE":
                    tool_calls = data.get("tool_calls")
                    if tool_calls:
                        for tc in tool_calls:
                            tool_name = tc.get("name", "")
                            tools_count[tool_name] = tools_count.get(tool_name, 0) + 1
                            args = tc.get("args", {})
                            
                            if tool_name == "view_file":
                                path = args.get("AbsolutePath")
                                if path:
                                    files_read.add(path)
                            elif tool_name == "grep_search":
                                path = args.get("SearchPath")
                                if path:
                                    files_read.add(path)
                            elif tool_name == "list_dir":
                                path = args.get("DirectoryPath")
                                if path:
                                    files_read.add(path)
                            elif tool_name == "write_to_file":
                                path = args.get("TargetFile")
                                if path:
                                    overwrite = args.get("Overwrite", False)
                                    files_mutated[path] = "Overwritten" if overwrite else "Created"
                            elif tool_name in ["replace_file_content", "multi_replace_file_content"]:
                                path = args.get("TargetFile")
                                if path:
                                    files_mutated[path] = "Modified"
                            elif tool_name == "run_command":
                                cmd = args.get("CommandLine")
                                cwd = args.get("Cwd")
                                commands.append((step_idx, cmd, cwd))
                
                # Track run command outcomes and errors
                if step_type == "RUN_COMMAND":
                    status = data.get("status")
                    if status == "ERROR" or (status == "DONE" and "failed with exit code" in content):
                        lines = content.strip().split("\n") if content else []
                        desc = "Unknown command error"
                        for i, ln in enumerate(lines):
                            stripped = ln.strip()
                            if "failed with exit code" in stripped:
                                desc = stripped
                                for j in range(i + 1, min(i + 4, len(lines))):
                                    out = lines[j].strip()
                                    if out and out != "Output:":
                                        desc += f" — {out}"
                                        break
                                break
                        frictions.append((step_idx, "Command Failure", desc))
            except Exception:
                pass
                
    # Summary stats
    total_tools = sum(tools_count.values())
    friction_rate = f"{len(frictions)}/{len(commands)} ({len(frictions)*100//max(len(commands),1)}%)" if commands else "0"
    print("## Summary")
    print(f"- **Total tool calls:** {total_tools}")
    print(f"- **Files read:** {len(files_read)} | **Mutated:** {len(files_mutated)}")
    print(f"- **Commands:** {len(commands)} | **Friction rate:** {friction_rate}")
    print()
    
    # Output detailed report in Markdown format
    print(f"### 📄 Files Read ({len(files_read)} total)")
    print("| # | File Path |")
    print("| :--- | :--- |")
    for i, path in enumerate(sorted(files_read), 1):
        print(f"| {i} | `{path}` |")
        
    print(f"\n### 🛠️ Tools Invoked")
    print("| Tool | Count |")
    print("| :--- | :--- |")
    for tool, count in sorted(tools_count.items(), key=lambda x: x[1], reverse=True):
        print(f"| {tool} | {count}x |")
        
    print(f"\n**Commands executed ({len(commands)} total):**")
    print("| Step | Command | Cwd |")
    print("| :--- | :--- | :--- |")
    for step, cmd, cwd in commands:
        print(f"| {step} | `{cmd}` | `{cwd}` |")
        
    print(f"\n### 📝 Artifacts Mutated ({len(files_mutated)} total)")
    print("| Action | File Path |")
    print("| :--- | :--- |")
    for path, act in sorted(files_mutated.items()):
        print(f"| {act} | `{path}` |")
        
    print(f"\n### 🚧 Agent Friction ({len(frictions)} total)")
    if frictions:
        print("| Step | Type | Description |")
        print("| :--- | :--- | :--- |")
        for step, typ, desc in frictions:
            print(f"| {step} | {typ} | {desc} |")
    else:
        print("No friction or failed commands detected.")

if __name__ == "__main__":
    main()
