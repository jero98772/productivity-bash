# Personal Productivity & Habit Tracking System

A comprehensive bash-based productivity system with habit tracking, streak management, exercise logging, and multi-computer synchronization via GitHub.

## 🌟 Features

- **📊 Dashboard**: Beautiful terminal dashboard showing all your stats
- **🔥 Streak Tracking**: Track porn-free days, routine completion, and GitHub activity
- **💾 Life System**: Earn lives every 7 days to save broken streaks
- **🏋️ Exercise Logger**: Track your complete workout routine
- **📚 Study Blocks**: Pomodoro-style morning study sessions (4x25min blocks)
- **⏱️ Time Tracking**: Integration with your existing `tt` script
- **🔒 Encrypted Sync**: Sync data across computers via GitHub (GPG encrypted)
- **📈 Visualizations**: Waffle plot showing last 100 days of progress
- **🎯 Incremental Approach**: Gradually build your routine over time

## 📋 Requirements

- **OS**: Linux or macOS
- **Dependencies**:
  - `bash` (4.0+)
  - `python3`
  - `git`
  - `gpg` (for encryption)
  - `ledger` (optional, for time tracking)

## 🚀 Quick Installation

### 1. Download and Install

```bash

git clone https://github.com/jero98772/productivity-bash
sudo apt install ledger -y
bash install.sh

cp -r bin/ ~/.productivity
sudo cp bin/tt.sh /usr/bin/tt
sudo chmod 777 /usr/bin/tt

```

### 2. Reload Shell

```bash
source ~/.bashrc  # or restart your terminal
```

### 3. First Time Setup

```bash
# View the dashboard
dashboard

# Set up GitHub sync (optional but recommended)
sync setup

# Start tracking!
habit check porn-free
```

## 📖 Complete Usage Guide

### Dashboard Commands

```bash
dashboard              # Show full dashboard with all stats
dashboard quick        # Quick view (streaks only)
dashboard help         # Show help
```

The dashboard shows:
- Current streaks (porn-free, routine, GitHub)
- Lives available
- Today's progress (study blocks, exercise)
- Week time breakdown
- 100-day waffle plot

### Habit Tracking

```bash
# Mark today as porn-free
habit check porn-free

# Use a life to save a broken streak
habit break porn-free

# View habit status
habit status

# Mark full routine complete (earns routine streak)
habit complete
```

**Streak Rules:**
- Check in daily to maintain streaks
- Missing a day breaks the streak (unless you use a life)
- Earn 1 life every 7 consecutive days
- Maximum 3 lives can be stored

### Morning Routine (6:00 AM - 8:00 AM)

```bash
# Start morning study routine
routine start morning

# This will guide you through:
# - Block 1: 6:00-6:25 (25 min study)
# - Break: 5 min
# - Block 2: 6:30-6:55 (25 min study)
# - Break: 5 min
# - Block 3: 7:00-7:25 (25 min study)
# - Break: 5 min
# - Block 4: 7:30-7:55 (25 min study)

# View schedule
routine schedule

# Get time-based suggestion
routine suggest
```

**Features:**
- Built-in Pomodoro timer (25 min work, 5 min break)
- Automatic time tracking integration
- Progress notifications
- Sound alerts (if available)

### Exercise Routine (7:00 PM - 8:00 PM)

Your exercise routine:

**Boo Staff:**
1. Head 2x
2. Rotate back 10x
3. Legs 10x

**Big Sword:**
4. Up/down each hand 10x
5. Up moves 10x
6. Infinite 10x

**Small Sword:**
7. Up/down each hand 10x
8. Up moves 10x
9. Infinite 10x
10. Fishing 10x

**General:**
11. Push-ups 10x
12. Punches 10x
13. Kicks 10x
14. Clowns 40x
15. Skipping 40x
16. Sentadillas 10x

```bash
# Start exercise session with timer
routine start exercise

# Log individual exercises
exercise log pushups        # By name
exercise log 11            # By number (1-16)

# View list of all exercises
exercise list

# Check today's progress
exercise status

# Mark full routine complete
exercise complete
```

### Evening Walk (8:00 PM - 9:00 PM)

```bash
# Start walking timer (60 min)
routine start walk
```

### Time Tracking Integration

Uses your existing `tt` script:

```bash
# Clock into activities
tt in courses:python
tt in work:project
tt in uni:data
tt in coding:personal

# Clock out
tt out

# View time balance
tt bal

# View today's hours
tt hours
```

The dashboard automatically shows weekly time breakdown by category.

### Multi-Computer Sync

#### First Computer Setup

```bash
# 1. Create a private GitHub repo
# Go to github.com and create: productivity-data (private)

# 2. Setup sync
sync setup
# Enter repo URL: git@github.com:yourusername/productivity-data.git
# Enter encryption password: [create a strong password]

# 3. Your data is now syncing!
```

#### Additional Computer Setup

```bash
# 1. Install the system (same as first computer)
bash install.sh

# 2. Setup sync with SAME repo and password
sync setup
# Enter repo URL: git@github.com:yourusername/productivity-data.git
# Enter encryption password: [same password as first computer]

# 3. Data will sync automatically!
```

#### Sync Commands

```bash
sync push          # Push local changes to GitHub
sync pull          # Pull latest from GitHub
sync force         # Full sync (pull + push)
sync status        # Check sync status
```

**Auto-sync:**
- Dashboard auto-pulls on open
- Habit checks auto-push after update
- Exercise logs auto-push after completion

### Advanced Features

#### Skip Days (Using Lives)

```bash
# Skip today's routine (uses 1 life)
routine skip

# Or use a life for specific streak
habit break porn-free
```

#### Incremental Routine Builder

The system supports gradual routine building:

**Level 1** (Weeks 1-2):
- 1 study block
- 3 exercise sets
- Basic tracking

**Level 2** (Weeks 3-4):
- 2 study blocks
- 5 exercise sets
- Porn-free tracking added

**Level 3** (Weeks 5-6):
- 3 study blocks
- Full exercise routine
- GitHub tracking added

**Level 4** (Weeks 7+):
- Full routine (4 blocks)
- All features active

Edit `~/.productivity/data/config.json` to set your level:
```json
{
  "routine_level": 1
}
```

## 📁 File Structure

```
~/.productivity/
├── bin/
│   ├── dashboard.sh       # Main dashboard
│   ├── habit.sh          # Habit tracking
│   ├── exercise.sh       # Exercise logger
│   ├── routine.sh        # Routine scheduler
│   └── sync.sh           # Sync system
├── data/
│   ├── streaks.json      # Streak data
│   ├── habits.json       # Daily habits log
│   ├── exercise-log.json # Exercise records
│   └── config.json       # Configuration
├── .encrypted/           # Encrypted data for GitHub
├── repo/                 # Git repository
└── aliases.sh            # Command aliases

~/.productivity-key       # Encryption password (NOT in git)
~/logtime/timelog.ldg    # Time tracking log (your tt script)
```

## 🎨 Dashboard Output Example

```
╔════════════════════════════════════════════════════════════╗
║           PRODUCTIVITY DASHBOARD - Oct 4, 2025            ║
╚════════════════════════════════════════════════════════════╝

🔥 STREAKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Porn-Free:        🔥  42 days  (Best: 42)
  Routine Complete: 🔥  12 days  (Best: 18) 
  GitHub Active:    🔥   8 days  (Best: 23)
  
💾 Lives Available: ❤️  ❤️  ⚫  (2/3)

📊 TODAY'S PROGRESS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Morning Study:  ⬛⬛⬛⬜  3/4 blocks
  Exercise:       ⏱  Not Started (7PM reminder)
  
⏱️  WEEK TIME BREAKDOWN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Courses:        8h 45m
  Work:          12h 30m
  Uni:            5h 15m
  Coding:        10h 20m
  
📅 LAST 100 DAYS (Waffle Plot)
█ █ █ █ █ █ █ █ █ █ 
█ █ █ █ █ █ █ █ █ █ 
█ █ █ █ █ ░ █ █ █ █ 
...

🟢 Complete  🟡 Partial  🔴 Missed  🔵 Life Used
```

## 🔧 Configuration

Edit `~/.productivity/data/config.json`:

```json
{
  "routine_level": 1,
  "github_username": "your_username",
  "timezone": "America/Bogota",
  "timelog_path": "~/logtime/timelog.ldg"
}
```

## 🔒 Security Notes

- All data is encrypted with GPG (AES256) before pushing to GitHub
- Encryption password stored locally in `~/.productivity-key` (chmod 600)
- Never commit unencrypted data
- Use a strong, unique password for encryption
- Keep your `~/.productivity-key` file secure

## 🐛 Troubleshooting

### Dashboard not showing on terminal open

```bash
# Add to ~/.bashrc or ~/.zshrc
if [[ $- == *i* ]] && [ -f "$HOME/.productivity/bin/dashboard.sh" ]; then
    bash "$HOME/.productivity/bin/dashboard.sh" quick
fi
```

### Sync failing

```bash
# Check status
sync status

# Try force sync
sync force

# Re-setup if needed
sync setup
```

### Time tracking not working

Make sure your `tt` script is in PATH:
```bash
which tt
# Should show: /home/user/bin/tt

# Or add to PATH in ~/.bashrc:
export PATH="$HOME/bin:$PATH"
```

## 🎯 Daily Workflow

### Morning (6:00 AM)
1. Terminal opens → Dashboard shows automatically
2. `habit check porn-free` - Check in for the day
3. `routine start morning` - Start first study block
4. Complete all 4 blocks with breaks

### Evening (7:00 PM)
1. `routine start exercise` - Start 60-min exercise session
2. Log exercises as you complete them: `exercise log 11`
3. `exercise complete` when done

### Night (8:00 PM)
1. `routine start walk` - 60-min evening walk
2. Bath and language learning (9:00 PM+)

### Anytime
- `tt in <category>:<description>` - Track time
- `tt out` - Stop tracking
- `dashboard` - Check progress
- Auto-syncs to GitHub throughout the day

## 📈 Tips for Success

1. **Start Small**: Begin with routine_level: 1
2. **Be Consistent**: Check in daily, even if you don't complete everything
3. **Use Lives Wisely**: Save them for genuine emergencies
4. **Track Everything**: The more data, the better insights
5. **Review Weekly**: Look at your waffle plot every Sunday
6. **Sync Regularly**: Ensure data is backed up
7. **Celebrate Streaks**: Acknowledge your progress!

## 🤝 Contributing

This is a personal productivity system, but feel free to:
- Fork and customize for your needs
- Share improvements
- Report issues

## 📄 License

Personal use. Modify as needed for your workflow.

## 🙏 Acknowledgments

- Inspired by Duolingo's streak system
- Pomodoro Technique for time management
- Your existing `tt` time tracking script
- GitHub contribution graph visualization

---

**Remember**: The goal isn't perfection, it's progress. Every day you check in is a win! 🎉

