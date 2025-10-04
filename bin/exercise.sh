#!/bin/bash

# Exercise Logger
# Track exercise routine completion

PROD_HOME="${HOME}/.productivity"
DATA_DIR="${PROD_HOME}/data"
BIN_DIR="${PROD_HOME}/bin"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# Exercise routine definition
declare -A EXERCISES=(
    ["boo-staff-head"]="Boo Staff - Head 2x"
    ["boo-staff-rotate"]="Boo Staff - Rotate Back 10x"
    ["boo-staff-legs"]="Boo Staff - Legs 10x"
    ["big-sword-updown"]="Big Sword - Up/Down Each Hand 10x"
    ["big-sword-ups"]="Big Sword - Up Moves 10x"
    ["big-sword-infinite"]="Big Sword - Infinite 10x"
    ["small-sword-updown"]="Small Sword - Up/Down Each Hand 10x"
    ["small-sword-ups"]="Small Sword - Up Moves 10x"
    ["small-sword-infinite"]="Small Sword - Infinite 10x"
    ["fishing"]="Fishing 10x"
    ["pushups"]="Push-ups 10x"
    ["punch"]="Punches 10x"
    ["kicks"]="Kicks 10x"
    ["clowns"]="Clowns 40x"
    ["skipping"]="Skipping 40x"
    ["squats"]="Sentadillas 10x"
)

# Log an exercise
log_exercise() {
    local exercise_name=$1
    
    if [ -z "$exercise_name" ]; then
        echo "Usage: exercise log <exercise_name>"
        echo "Available exercises:"
        for key in "${!EXERCISES[@]}"; do
            echo "  $key - ${EXERCISES[$key]}"
        done
        exit 1
    fi
    
    if [ -z "${EXERCISES[$exercise_name]}" ]; then
        echo "Unknown exercise: $exercise_name"
        echo "Use 'exercise list' to see available exercises"
        exit 1
    fi
    
    python3 << PYEOF
import json
from datetime import datetime

today = datetime.now().strftime('%Y-%m-%d')
now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# Load exercise log
try:
    with open('${DATA_DIR}/exercise-log.json', 'r') as f:
        log = json.load(f)
except:
    log = []

# Add entry
entry = {
    'date': now,
    'exercise': '${exercise_name}',
    'description': '${EXERCISES[$exercise_name]}',
    'complete': False
}

log.append(entry)

with open('${DATA_DIR}/exercise-log.json', 'w') as f:
    json.dump(log, f, indent=2)

print(f"✓ Logged: ${EXERCISES[$exercise_name]}")

# Count today's exercises
today_count = len([x for x in log if x['date'].startswith(today)])
total_exercises = ${#EXERCISES[@]}
print(f"Progress: {today_count}/{total_exercises} exercises logged today")
PYEOF
}

# Mark full routine complete
complete_routine() {
    python3 << PYEOF
import json
from datetime import datetime

today = datetime.now().strftime('%Y-%m-%d')
now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# Load exercise log
try:
    with open('${DATA_DIR}/exercise-log.json', 'r') as f:
        log = json.load(f)
except:
    log = []

# Add completion entry
entry = {
    'date': now,
    'exercise': 'COMPLETE',
    'description': 'Full routine completed',
    'complete': True
}

log.append(entry)

with open('${DATA_DIR}/exercise-log.json', 'w') as f:
    json.dump(log, f, indent=2)

# Update habits
try:
    with open('${DATA_DIR}/habits.json', 'r') as f:
        habits = json.load(f)
except:
    habits = {}

if today not in habits:
    habits[today] = {}

habits[today]['exercise_complete'] = True

with open('${DATA_DIR}/habits.json', 'w') as f:
    json.dump(habits, f, indent=2)

print("🏋️  Exercise routine complete! Great work! 💪")
PYEOF
    
    # Auto-sync
    if [ -f "${BIN_DIR}/sync.sh" ]; then
        bash "${BIN_DIR}/sync.sh" push silent
    fi
}

# Show exercise status
show_status() {
    python3 << 'PYEOF'
import json
from datetime import datetime

today = datetime.now().strftime('%Y-%m-%d')

try:
    with open('${DATA_DIR}/exercise-log.json', 'r') as f:
        log = json.load(f)
    
    today_logs = [x for x in log if x['date'].startswith(today)]
    
    print("\n🏋️  Today's Exercise Progress")
    print("═" * 60)
    
    if not today_logs:
        print("No exercises logged yet today")
        print("\nStart with: exercise log <name>")
    else:
        complete = any(x.get('complete', False) for x in today_logs)
        
        if complete:
            print("✓ COMPLETE! Full routine done! 🎉")
        else:
            print(f"In Progress: {len(today_logs)} exercises logged")
        
        print("\nLogged exercises:")
        for entry in today_logs:
            time = entry['date'].split()[1]
            print(f"  [{time}] {entry['description']}")
    
    print()
    
except Exception as e:
    print("No exercise data yet")
PYEOF
}

# List all exercises
list_exercises() {
    echo -e "\n${BOLD}Available Exercises:${NC}"
    echo "═" * 60
    echo ""
    echo -e "${BLUE}BOO STAFF:${NC}"
    echo "  boo-staff-head    - Head 2x"
    echo "  boo-staff-rotate  - Rotate Back 10x"
    echo "  boo-staff-legs    - Legs 10x"
    echo ""
    echo -e "${BLUE}BIG SWORD:${NC}"
    echo "  big-sword-updown    - Up/Down Each Hand 10x"
    echo "  big-sword-ups       - Up Moves 10x"
    echo "  big-sword-infinite  - Infinite 10x"
    echo ""
    echo -e "${BLUE}SMALL SWORD:${NC}"
    echo "  small-sword-updown    - Up/Down Each Hand 10x"
    echo "  small-sword-ups       - Up Moves 10x"
    echo "  small-sword-infinite  - Infinite 10x"
    echo ""
    echo -e "${BLUE}GENERAL:${NC}"
    echo "  fishing    - Fishing 10x"
    echo "  pushups    - Push-ups 10x"
    echo "  punch      - Punches 10x"
    echo "  kicks      - Kicks 10x"
    echo "  clowns     - Clowns 40x"
    echo "  skipping   - Skipping 40x"
    echo "  squats     - Sentadillas 10x"
    echo ""
    echo "Usage: exercise log <name>"
    echo "Example: exercise log pushups"
    echo ""
}

# Quick log shortcut
quick_log() {
    local short=$1
    case $short in
        1) log_exercise "boo-staff-head" ;;
        2) log_exercise "boo-staff-rotate" ;;
        3) log_exercise "boo-staff-legs" ;;
        4) log_exercise "big-sword-updown" ;;
        5) log_exercise "big-sword-ups" ;;
        6) log_exercise "big-sword-infinite" ;;
        7) log_exercise "small-sword-updown" ;;
        8) log_exercise "small-sword-ups" ;;
        9) log_exercise "small-sword-infinite" ;;
        10) log_exercise "fishing" ;;
        11) log_exercise "pushups" ;;
        12) log_exercise "punch" ;;
        13) log_exercise "kicks" ;;
        14) log_exercise "clowns" ;;
        15) log_exercise "skipping" ;;
        16) log_exercise "squats" ;;
        *) echo "Unknown number. Use 1-16 or exercise name" ;;
    esac
}

# Main command handler
case "${1}" in
    log)
        if [[ "${2}" =~ ^[0-9]+$ ]]; then
            quick_log "${2}"
        else
            log_exercise "${2}"
        fi
        ;;
    
    complete)
        complete_routine
        ;;
    
    status)
        show_status
        ;;
    
    list)
        list_exercises
        ;;
    
    *)
        cat << 'EOF'
Exercise Logger Commands:

  exercise log <name>    - Log a specific exercise
  exercise log <number>  - Quick log by number (1-16)
  exercise complete      - Mark full routine complete
  exercise status        - Show today's progress
  exercise list          - List all exercises

Examples:
  exercise log pushups
  exercise log 11
  exercise complete

EOF
        ;;
esac

exit 0