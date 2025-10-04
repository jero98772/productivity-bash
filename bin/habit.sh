#!/bin/bash

# Habit Tracker
# Track daily habits and streaks

PROD_HOME="${HOME}/.productivity"
DATA_DIR="${PROD_HOME}/data"
BIN_DIR="${PROD_HOME}/bin"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

# Update streak data
update_streak() {
    local streak_type=$1
    local action=$2  # check or break
    
    python3 << PYEOF
import json
from datetime import datetime, timedelta

with open('${DATA_DIR}/streaks.json', 'r') as f:
    data = json.load(f)

today = datetime.now().strftime('%Y-%m-%d')
streak = data['${streak_type}']

if '${action}' == 'check':
    last_check = streak.get('last_check', '')
    
    if last_check == today:
        print("Already checked today!")
        exit(0)
    
    # Check if we missed yesterday
    if last_check:
        last_date = datetime.strptime(last_check, '%Y-%m-%d')
        yesterday = datetime.now() - timedelta(days=1)
        
        if last_date.date() < yesterday.date():
            # Streak broken
            print(f"Streak broken! Was at {streak['current']} days")
            streak['current'] = 1
        else:
            # Continue streak
            streak['current'] += 1
    else:
        # First check
        streak['current'] = 1
        streak['start_date'] = today
    
    streak['last_check'] = today
    
    # Update best
    if streak['current'] > streak['best']:
        streak['best'] = streak['current']
    
    # Award lives every 7 days
    if streak['current'] % 7 == 0 and data['lives'] < data['max_lives']:
        data['lives'] += 1
        print(f"🎉 New life earned! You now have {data['lives']} lives")
    
    print(f"✓ Streak updated: {streak['current']} days")

elif '${action}' == 'break':
    if data['lives'] > 0:
        data['lives'] -= 1
        streak['last_check'] = today
        print(f"Life used! Streak saved. Lives remaining: {data['lives']}")
    else:
        print("No lives available! Streak will break if you don't complete today.")
        exit(1)

with open('${DATA_DIR}/streaks.json', 'w') as f:
    json.dump(data, f, indent=2)

# Update habits log
with open('${DATA_DIR}/habits.json', 'r') as f:
    habits = json.load(f)

if today not in habits:
    habits[today] = {}

habits[today]['${streak_type}'] = True
habits[today]['status'] = 'partial'  # Will be updated when routine completes

with open('${DATA_DIR}/habits.json', 'w') as f:
    json.dump(habits, f, indent=2)
PYEOF
}

# Check porn-free
check_porn_free() {
    echo -e "${GREEN}Checking in: Porn-Free${NC}"
    update_streak "porn_free" "check"
    
    # Auto-sync
    if [ -f "${BIN_DIR}/sync.sh" ]; then
        bash "${BIN_DIR}/sync.sh" push silent
    fi
}

# Break streak using a life
use_life() {
    local streak_type=$1
    
    echo -e "${YELLOW}Using a life to save ${streak_type} streak...${NC}"
    update_streak "${streak_type}" "break"
    
    # Auto-sync
    if [ -f "${BIN_DIR}/sync.sh" ]; then
        bash "${BIN_DIR}/sync.sh" push silent
    fi
}

# Show habit status
show_status() {
    python3 << 'PYEOF'
import json
from datetime import datetime

with open('${DATA_DIR}/streaks.json', 'r') as f:
    streaks = json.load(f)

with open('${DATA_DIR}/habits.json', 'r') as f:
    habits = json.load(f)

today = datetime.now().strftime('%Y-%m-%d')
today_habits = habits.get(today, {})

print("\n📊 Today's Habit Status")
print("═" * 50)

# Porn-free
if today_habits.get('porn_free'):
    print("✓ Porn-Free: Checked ✓")
else:
    print("⚠ Porn-Free: Not checked yet")

# Routine
if today_habits.get('routine_complete'):
    print("✓ Routine: Complete ✓")
else:
    print("⚠ Routine: Not complete")

# Exercise
if today_habits.get('exercise_complete'):
    print("✓ Exercise: Complete ✓")
else:
    print("⚠ Exercise: Not complete")

print("\n🔥 Current Streaks")
print("═" * 50)
for name, data in streaks.items():
    if name not in ['lives', 'max_lives']:
        print(f"  {name.replace('_', ' ').title()}: {data['current']} days (Best: {data['best']})")

print(f"\n💾 Lives: {streaks['lives']}/{streaks['max_lives']}")
print()
PYEOF
}

# Mark routine complete
complete_routine() {
    python3 << PYEOF
import json
from datetime import datetime

today = datetime.now().strftime('%Y-%m-%d')

# Update streaks
with open('${DATA_DIR}/streaks.json', 'r') as f:
    streaks = json.load(f)

# Check routine streak
update_streak "routine" "check" >/dev/null 2>&1

# Update habits
with open('${DATA_DIR}/habits.json', 'r') as f:
    habits = json.load(f)

if today not in habits:
    habits[today] = {}

habits[today]['routine_complete'] = True
habits[today]['status'] = 'complete'

with open('${DATA_DIR}/habits.json', 'w') as f:
    json.dump(habits, f, indent=2)

print("✓ Routine marked as complete!")
print("Great job! Keep the streak going! 🔥")
PYEOF
    
    # Auto-sync
    if [ -f "${BIN_DIR}/sync.sh" ]; then
        bash "${BIN_DIR}/sync.sh" push silent
    fi
}

# Main command handler
case "${1}" in
    check)
        case "${2}" in
            porn-free|pf)
                check_porn_free
                ;;
            *)
                echo "Usage: habit check porn-free"
                exit 1
                ;;
        esac
        ;;
    
    break)
        streak_type="${2//-/_}"
        if [ -z "$streak_type" ]; then
            echo "Usage: habit break <streak_type>"
            echo "Example: habit break porn-free"
            exit 1
        fi
        use_life "$streak_type"
        ;;
    
    status)
        show_status
        ;;
    
    complete)
        complete_routine
        ;;
    
    *)
        cat << 'EOF'
Habit Tracker Commands:

  habit check porn-free  - Mark today as porn-free
  habit break <streak>   - Use a life to save a streak
  habit status           - Show today's habit status
  habit complete         - Mark full routine as complete

Examples:
  habit check porn-free
  habit break porn-free
  habit status

EOF
        ;;
esac

exit 0