#!/usr/bin/env python3
# -----------------------------------------------------------------------------
#  luka_todo.py
#   - DESCRIPTION: Command Line Todo Application with JSON persistence,
#                  command history support, and additional convenience features.
#   - AUTHOR      : github.com/rxxuzi
#   - LICENSE     : CC0
# -----------------------------------------------------------------------------

import json
import os
import readline
from uuid import uuid4

TODO_FILE = os.path.expanduser("~/.luka_todo.json")
HISTORY_FILE = os.path.expanduser("~/.luka_todo_history")

COLOR = {
    "GREEN": "\033[92m",
    "RESET": "\033[0m",
    "YELLOW": "\033[93m",
    "BLUE": "\033[94m",
    "RED": "\033[91m"
}

def load_tasks():
    if not os.path.exists(TODO_FILE):
        return []
    try:
        with open(TODO_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except json.JSONDecodeError:
        return []

def save_tasks(tasks):
    with open(TODO_FILE, "w", encoding="utf-8") as f:
        json.dump(tasks, f, indent=2)

def print_tasks(tasks):
    if not tasks:
        print("No tasks found.")
        return

    active_tasks = [task for task in tasks if not task["done"]]
    completed_tasks = [task for task in tasks if task["done"]]

    print("Active Tasks:")
    for idx, task in enumerate(active_tasks):
        print(f"{idx+1:2}. [ ] {task['task']}")
    
    if completed_tasks:
        print("\nCompleted Tasks:")
        for idx, task in enumerate(completed_tasks):
            print(f"{idx+1+len(active_tasks):2}. [{COLOR['GREEN']}✓{COLOR['RESET']}] {task['task']}")

def add_task(tasks, description):
    tasks.append({
        "id": str(uuid4()),
        "task": description,
        "done": False
    })
    save_tasks(tasks)
    print(f"Added: {description}")

def edit_task(tasks, task_idx, new_description):
    try:
        tasks[task_idx]["task"] = new_description
        save_tasks(tasks)
        print(f"Updated: {new_description}")
    except IndexError:
        print(f"{COLOR['RED']}Invalid task number{COLOR['RESET']}")

def move_task(tasks, from_idx, to_idx):
    try:
        task = tasks.pop(from_idx)
        tasks.insert(to_idx, task)
        save_tasks(tasks)
        print(f"Moved task {from_idx+1} → {to_idx+1}")
    except IndexError:
        print(f"{COLOR['RED']}Invalid task number{COLOR['RESET']}")

def clear_completed(tasks):
    original_count = len(tasks)
    tasks[:] = [task for task in tasks if not task["done"]]
    removed_count = original_count - len(tasks)
    save_tasks(tasks)
    print(f"Cleared {removed_count} completed tasks")

def show_stats(tasks):
    total = len(tasks)
    completed = sum(1 for t in tasks if t["done"])
    active = total - completed
    if total == 0:
        print("No tasks")
        return
    print(f"Total: {total} | {COLOR['GREEN']}Completed: {completed}{COLOR['RESET']} | "
          f"{COLOR['RED']}Active: {active}{COLOR['RESET']} | "
          f"Progress: {completed/total*100:.1f}%")

def toggle_task_done(tasks, task_idx, done):
    try:
        tasks[task_idx]["done"] = done
        save_tasks(tasks)
        status = "Completed" if done else "Marked as not done"
        print(f"{status}: {tasks[task_idx]['task']}")
    except IndexError:
        print(f"{COLOR['RED']}Invalid task number{COLOR['RESET']}")

def main():
    tasks = load_tasks()
    
    # 履歴のロード
    if os.path.exists(HISTORY_FILE):
        readline.read_history_file(HISTORY_FILE)

    print(f"{COLOR['BLUE']}Luka Todo App{COLOR['RESET']}")
    print("Commands:  add <task>  ls  done <num>  undone <num>  rm <num>  edit <num> <text>")
    print("           mv <from> <to>  clear  stats  exit")

    while True:
        try:
            command = input("> ").strip()
            readline.write_history_file(HISTORY_FILE)

            if not command:
                continue

            parts = command.split()
            cmd = parts[0].lower()

            if cmd == "add":
                if len(parts) < 2:
                    print(f"{COLOR['RED']}Usage: add <task description>{COLOR['RESET']}")
                    continue
                description = " ".join(parts[1:])
                add_task(tasks, description)

            elif cmd in ["done", "undone"]:
                if len(parts) < 2:
                    print(f"{COLOR['RED']}Usage: {cmd} <task_number>{COLOR['RESET']}")
                    continue
                try:
                    task_idx = int(parts[1]) - 1
                    toggle_task_done(tasks, task_idx, done=(cmd == "done"))
                except ValueError:
                    print(f"{COLOR['RED']}Invalid task number{COLOR['RESET']}")

            elif cmd == "rm":
                if len(parts) < 2:
                    print(f"{COLOR['RED']}Usage: rm <task_number>{COLOR['RESET']}")
                    continue
                try:
                    task_idx = int(parts[1]) - 1
                    removed = tasks.pop(task_idx)
                    save_tasks(tasks)
                    print(f"Removed: {removed['task']}")
                except (IndexError, ValueError):
                    print(f"{COLOR['RED']}Invalid task number{COLOR['RESET']}")

            elif cmd == "ls":
                print_tasks(tasks)

            elif cmd == "edit":
                if len(parts) < 3:
                    print(f"{COLOR['RED']}Usage: edit <num> <new_text>{COLOR['RESET']}")
                    continue
                try:
                    task_idx = int(parts[1]) - 1
                    new_desc = " ".join(parts[2:])
                    edit_task(tasks, task_idx, new_desc)
                except (IndexError, ValueError):
                    print(f"{COLOR['RED']}Invalid task number{COLOR['RESET']}")

            elif cmd == "mv":
                if len(parts) < 3:
                    print(f"{COLOR['RED']}Usage: mv <from_num> <to_num>{COLOR['RESET']}")
                    continue
                try:
                    from_idx = int(parts[1]) - 1
                    to_idx = int(parts[2]) - 1
                    move_task(tasks, from_idx, to_idx)
                except (IndexError, ValueError):
                    print(f"{COLOR['RED']}Invalid task number{COLOR['RESET']}")

            elif cmd == "clear":
                clear_completed(tasks)

            elif cmd == "stats":
                show_stats(tasks)

            elif cmd == "exit":
                print(f"{COLOR['YELLOW']}Goodbye!{COLOR['RESET']}")
                break

            else:
                print(f"{COLOR['RED']}Invalid command{COLOR['RESET']}")

        except KeyboardInterrupt:
            print(f"\n{COLOR['YELLOW']}Use 'exit' to quit{COLOR['RESET']}")
        except Exception as e:
            print(f"{COLOR['RED']}Error: {str(e)}{COLOR['RESET']}")

if __name__ == "__main__":
    readline.parse_and_bind("tab: complete")
    readline.set_auto_history(True)
    main()
