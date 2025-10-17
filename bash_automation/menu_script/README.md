# Menu Script — Bash Automation Tool

This is a simple yet powerful menu-driven Bash script to automate common Linux system tasks like viewing system info, monitoring processes, checking disk usage, and cleaning temporary files.
This is a Stage 1 portfolio project focused on clean scripting, error handling, and structured code.

## Features

- System information — date, hostname, user, uptime

- Monitor multiple processes — check if they’re running or not

- Disk usage report — check the size of any directory

- Cleanup .tmp files — delete temporary files while preserving important ones

- Exit easily with q, Q, or 5

- Proper error handling for empty inputs and invalid paths

- Built-in --help flag for usage instructions

## Usage
./menu_script.sh


Optional:

./menu_script.sh --help


Menu Options

1) Show system info
2) Monitor processes
3) Disk usage report
4) Cleanup temp files
5) Exit

Example run:

```
********************************
1) Show system info
2) Monitor processes
3) Disk usage report
4) Cleanup temp files
5) Exit
********************************

Enter any number between 1 to 5 based on above options: 1
############## SYSTEM INFORMATION ##############
Date: Thu Oct 17 18:20:32 IST 2025
Hostname: dhamo-VirtualBox
User: root
Uptime: up 1 hour, 25 minutes
✅ Task completed. Returning to menu...
```

## Struggles Faced

Initially, I tried to implement the cleanup logic using a for loop to list all files and manually filter out .tmp files.
This worked — but it was unnecessarily long and messy.

After experimenting, I discovered the find command.
Even there, I faced another small hurdle: find prints full file paths, which isn’t user-friendly.
Finally, I learned how to filter only the filename using -printf "%f\n".

## Learnings

For every requirement, I tried to build the logic on my own first.
Then I searched for better or cleaner ways to achieve the same thing.
It would be a lie if I said I came up with every logic myself 😂 — but this approach helped me understand why each syntax works, not just copy it.

## Small Intro About Me

This is my first script that can actually solve common real-world problems.
I learned a lot of Bash syntax, shortcuts, and professional scripting techniques just through this project.

Even though I have 3 years of experience working with Redfish at the application layer in embedded systems, I’ve always been curious about what’s happening under the hood in Linux.

This project is the first step in that journey.

Short-term goal: Build more advanced Bash scripts and master Linux automation.

Long-term goal: Solve bigger problems and deploy large-scale Linux projects.

This is more than just a beginner script for me — it’s the foundation of my freelancing journey in Linux automation.
