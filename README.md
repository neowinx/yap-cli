# YAP-CLI - Yeat Another Pomodoro CLI Application

A simple and efficient command-line Pomodoro timer with task management and reporting capabilities.

## Features

- Create and manage tasks
- Interactive pomodoro timer with visual progress bar
- Pause and early completion options
- Task switching between pomodoros
- Automatic breaks (short and long)
- CSV report generation with date and time tracking
- Color-coded terminal output

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/pomodoro-cli.git
cd pomodoro-cli
```

2. Make the script executable:
```bash
chmod +x pomodoro.sh
```

3. (Optional) Add the script to your PATH for global access:
```bash
sudo ln -s "$(pwd)/pomodoro.sh" /usr/local/bin/pomodoro
```

## Usage

Run the script:
```bash
./pomodoro.sh
```

### Main Menu Options

1. **Add new task**
   - Enter a description for your task
   - Tasks are stored in `tasks.txt`

2. **List all tasks**
   - View all available tasks with their numbers
   - Useful for selecting tasks for pomodoro sessions

3. **Start pomodoro session**
   - Select a task from the list
   - Timer will start with a visual progress bar
   - Press Enter to pause or complete early
   - After each pomodoro, you can:
     - Continue with the current task
     - Switch to a different task
     - End the session

4. **Generate report**
   - Enter a date range (YYYY-MM-DD)
   - View completed pomodoros in CSV format
   - Reports include date, time, and task information

### Timer Controls

- The timer shows a progress bar and remaining time
- **Keyboard shortcuts during timer:**
  - **F5** - Restart the current pomodoro
  - **Space** - Pause/Resume the timer
  - **Esc** - Stop the timer and exit
  - **Enter** - Pause and ask for early completion
- When paused, you can:
  - Complete the pomodoro early (y)
  - Continue the timer (n)

### Break System

- Short breaks (5 minutes) after each pomodoro
- Long breaks (15 minutes) after every 4 pomodoros
- Breaks can be skipped by completing them early

## File Structure

- `pomodoro.sh` - Main script
- `tasks.txt` - Stores task descriptions
- `pomodoro_report.csv` - Stores pomodoro session data

## Report Format

The CSV report includes:
- Date and time of completion
- Task description
- Completion status

Example:
```csv
datetime,task,completed
2024-03-14 10:30:15,Write documentation,1
2024-03-14 11:00:45,Code review,1
```

## Configuration

You can modify these variables in the script to customize your experience:
- `WORK_TIME` - Duration of work sessions (default: 25 minutes)
- `BREAK_TIME` - Duration of short breaks (default: 5 minutes)
- `LONG_BREAK_TIME` - Duration of long breaks (default: 15 minutes)
- `POMODOROS_BEFORE_LONG_BREAK` - Number of pomodoros before a long break (default: 4)

## Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes
4. Commit your changes:
   ```bash
   git commit -m 'Add some feature'
   ```
5. Push to the branch:
   ```bash
   git push origin feature/your-feature-name
   ```
6. Open a Pull Request

### Development Guidelines

- Follow the existing code style
- Add comments for complex logic
- Test your changes thoroughly
- Update the README if necessary
- Keep the script POSIX-compliant for maximum compatibility

### Testing

Before submitting a pull request:
1. Test the script on different shells (bash, zsh)
2. Verify all features work as expected
3. Check for any potential edge cases
4. Ensure the script runs on both Linux and macOS

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by the Pomodoro Technique®
- Thanks to all contributors who have helped improve this tool 