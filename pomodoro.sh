#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TASKS_FILE="tasks.txt"
REPORT_FILE="pomodoro_report.csv"
WORK_TIME=25  # minutes
BREAK_TIME=5  # minutes
LONG_BREAK_TIME=15  # minutes
POMODOROS_BEFORE_LONG_BREAK=4

# Create necessary files if they don't exist
touch "$TASKS_FILE"
if [ ! -f "$REPORT_FILE" ]; then
    echo "datetime,task,completed" > "$REPORT_FILE"
fi

# Function to display progress bar
show_progress() {
    local duration=$1
    local task=$2
    local elapsed=0
    local width=50
    local paused=false
    
    echo -e "\n${BLUE}Current Task: ${NC}$task"
    echo -e "${YELLOW}Time Remaining:${NC}"
    echo -e "${YELLOW}Keyboard shortcuts: F5=Restart, Space=Pause/Resume, Esc=Stop${NC}"
    
    # Function to read input without blocking and handle special keys
    read_input() {
        # Use -N 1 to read exactly one character, including special characters
        if read -t 1 -N 1 input; then
            # Check for special keys
            case "$input" in
                $'\x0a')  # Enter key
                    return 0
                    ;;
                $'\x20')  # Space key
                    return 1
                    ;;
                $'\x1b')  # Escape key
                    return 2
                    ;;
                $'\x1b')  # F5 key (starts with escape)
                    # F5 sends: ESC [ 1 5 ~
                    if read -t 0.1 -N 1 next_char && [ "$next_char" = "[" ]; then
                        if read -t 0.1 -N 3 f5_seq && [ "$f5_seq" = "15~" ]; then
                            return 3
                        fi
                    fi
                    return 2  # Treat as Esc if not F5
                    ;;
            esac
        fi
        return 4  # No input
    }
    
    while [ $elapsed -lt $duration ]; do
        local remaining=$((duration - elapsed))
        local progress=$((elapsed * width / duration))
        local remaining_progress=$((width - progress))
        
        printf "\r["
        printf "%${progress}s" | tr " " "#"
        printf "%${remaining_progress}s" | tr " " "-"
        printf "] %d:%02d" $((remaining / 60)) $((remaining % 60))
        
        # Check for keyboard input
        read_input
        local input_result=$?
        
        case $input_result in
            0)  # Enter key - pause and ask for early completion
                echo -e "\n${YELLOW}Pomodoro paused. Do you want to complete it early? (y/n)${NC}"
                read -p "> " complete_early
                if [[ $complete_early =~ ^[Yy]$ ]]; then
                    echo -e "${GREEN}Completing pomodoro early...${NC}"
                    return 0
                else
                    echo -e "${BLUE}Continuing pomodoro...${NC}"
                    echo -e "${YELLOW}Keyboard shortcuts: F5=Restart, Space=Pause/Resume, Esc=Stop${NC}"
                fi
                ;;
            1)  # Space key - toggle pause/resume
                if [ "$paused" = false ]; then
                    paused=true
                    echo -e "\n${YELLOW}Pomodoro PAUSED. Press Space to resume or Esc to stop${NC}"
                    # Wait for space or escape while paused
                    while [ "$paused" = true ]; do
                        read_input
                        local pause_input=$?
                        case $pause_input in
                            1)  # Space - resume
                                paused=false
                                echo -e "\n${GREEN}Resuming pomodoro...${NC}"
                                ;;
                            2)  # Esc - stop
                                echo -e "\n${RED}Pomodoro stopped by user${NC}"
                                return 1
                                ;;
                        esac
                    done
                fi
                ;;
            2)  # Esc key - stop pomodoro
                echo -e "\n${RED}Pomodoro stopped by user${NC}"
                return 1
                ;;
            3)  # F5 key - restart pomodoro
                echo -e "\n${GREEN}Restarting pomodoro...${NC}"
                return 2  # Special return code for restart
                ;;
        esac
        
        # Only increment elapsed time if not paused
        if [ "$paused" = false ]; then
            elapsed=$((elapsed + 1))
        fi
    done
    echo
    return 0
}

# Function to add a new task
add_task() {
    echo "$1" >> "$TASKS_FILE"
    echo -e "${GREEN}Task added successfully!${NC}"
}

# Function to list all tasks
list_tasks() {
    if [ ! -s "$TASKS_FILE" ]; then
        echo -e "${YELLOW}No tasks available.${NC}"
        return
    fi
    
    echo -e "\n${BLUE}Available Tasks:${NC}"
    nl -w2 -s". " "$TASKS_FILE"
}

# Function to start a pomodoro session
start_pomodoro() {
    local task=$1
    local pomodoro_count=0
    
    while true; do
        echo -e "\n${GREEN}Starting Pomodoro #$((pomodoro_count + 1))${NC}"
        show_progress $((WORK_TIME * 60)) "$task"
        local progress_result=$?
        
        case $progress_result in
            0)  # Completed normally
                # Record the completed pomodoro with date and time
                echo "$(date '+%Y-%m-%d %H:%M:%S'),$task,1" >> "$REPORT_FILE"
                pomodoro_count=$((pomodoro_count + 1))
                ;;
            1)  # Interrupted/stopped
                echo -e "${YELLOW}Pomodoro interrupted.${NC}"
                break
                ;;
            2)  # Restart requested (F5)
                echo -e "${BLUE}Restarting pomodoro for task: $task${NC}"
                continue  # Skip to next iteration without incrementing count
                ;;
        esac
        
        # Check if it's time for a long break
        if [ $((pomodoro_count % POMODOROS_BEFORE_LONG_BREAK)) -eq 0 ]; then
            echo -e "\n${YELLOW}Time for a long break!${NC}"
            show_progress $((LONG_BREAK_TIME * 60)) "Long Break"
            local break_result=$?
            if [ $break_result -eq 1 ] || [ $break_result -eq 2 ]; then
                echo -e "${YELLOW}Break interrupted.${NC}"
                break
            fi
        else
            echo -e "\n${YELLOW}Time for a short break!${NC}"
            show_progress $((BREAK_TIME * 60)) "Short Break"
            local break_result=$?
            if [ $break_result -eq 1 ] || [ $break_result -eq 2 ]; then
                echo -e "${YELLOW}Break interrupted.${NC}"
                break
            fi
        fi
        
        echo -e "\n${BLUE}What would you like to do next?${NC}"
        echo "1. Continue with current task"
        echo "2. Switch to a different task"
        echo "3. End session"
        read -p "Select an option (1-3): " next_action
        
        case $next_action in
            1)
                echo -e "${GREEN}Continuing with current task: $task${NC}"
                ;;
            2)
                list_tasks
                if [ -s "$TASKS_FILE" ]; then
                    read -p "Select task number: " task_num
                    if [[ $task_num =~ ^[0-9]+$ ]] && [ $task_num -gt 0 ]; then
                        task=$(sed -n "${task_num}p" "$TASKS_FILE")
                        echo -e "${GREEN}Switching to task: $task${NC}"
                    else
                        echo -e "${RED}Invalid task number, continuing with current task${NC}"
                    fi
                else
                    echo -e "${YELLOW}No tasks available, continuing with current task${NC}"
                fi
                ;;
            3)
                echo -e "${GREEN}Ending session.${NC}"
                break
                ;;
            *)
                echo -e "${RED}Invalid option, continuing with current task${NC}"
                ;;
        esac
    done
}

# Function to generate report
generate_report() {
    local start_date=$1
    local end_date=$2
    
    if [ -z "$start_date" ] || [ -z "$end_date" ]; then
        echo -e "${RED}Please provide both start and end dates (YYYY-MM-DD)${NC}"
        return
    fi
    
    echo -e "\n${BLUE}Pomodoro Report ($start_date to $end_date)${NC}"
    echo "Date Time,Task,Completed"
    awk -F, -v start="$start_date" -v end="$end_date" '
        # Extract just the date part for comparison
        {date_part = substr($1, 1, 10)}
        date_part >= start && date_part <= end {print $0}
    ' "$REPORT_FILE" | column -t -s,
}

# Main menu
while true; do
    echo -e "\n${BLUE}Pomodoro CLI${NC}"
    echo "1. Add new task"
    echo "2. List all tasks"
    echo "3. Start pomodoro session"
    echo "4. Generate report"
    echo "5. Exit"
    
    read -p "Select an option (1-5): " choice
    
    case $choice in
        1)
            read -p "Enter task description: " task_desc
            add_task "$task_desc"
            ;;
        2)
            list_tasks
            ;;
        3)
            list_tasks
            if [ -s "$TASKS_FILE" ]; then
                read -p "Select task number: " task_num
                if [[ $task_num =~ ^[0-9]+$ ]] && [ $task_num -gt 0 ]; then
                    task=$(sed -n "${task_num}p" "$TASKS_FILE")
                    start_pomodoro "$task"
                else
                    echo -e "${RED}Invalid task number${NC}"
                fi
            fi
            ;;
        4)
            read -p "Enter start date (YYYY-MM-DD): " start_date
            read -p "Enter end date (YYYY-MM-DD): " end_date
            generate_report "$start_date" "$end_date"
            ;;
        5)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
done 