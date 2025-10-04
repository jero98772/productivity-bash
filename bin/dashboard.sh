#!/bin/bash

# Productivity Dashboard
# Main entry point for the productivity tracking system

PROD_HOME="${HOME}/.productivity"
DATA_DIR="${PROD_HOME}/data"
BIN_DIR="${PROD_HOME}/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Initialize data files if they don't exist
init_data() {
    mkdir -p "${DATA_DIR}"
    
    if [ ! -f "${DATA_DIR}/streaks.json" ]; then
        cat > "${DATA_DIR}/streaks.json" << 'EOF'
{
  "porn_free": {
    "current": 0,
    "best": 0,
    "last_check": "",
    "start_date": ""
  },
  "routine": {
    "current": 0,
    "best": 0,
    "last_check": "",
    "start_date": ""
  },
  "github": {
    "current": 0,
    "best": 0,
    "last_check": "",
    "start_date": ""
  },
  "lives": 0,
  "max_lives": 3
}
EOF
    fi
    
    if [ ! -f "${DATA_DIR}/habits.json" ]; then
        echo '{}' > "${DATA_DIR}/habits.json"
    fi
    
    if [ ! -f "${DATA_DIR}/exercise-log.json" ]; then
        echo '[]' > "${DATA_DIR}/exercise-log.json"
    fi
    
    if [ ! -f "${DATA_DIR}/config.json" ]; then
        cat > "${DATA_DIR}/config.json" << 'EOF'
{
  "routine_level": 1,
  "github_username": "",
  "timezone": "America/Bogota",
  "timelog_path": "~/logtime/timelog.ldg"
}
EOF
    fi
}

# Get streak data
get_streak() {
    local streak_type=$1
    python3 -c "
import json
with open('${DATA_DIR}/streaks.json', 'r') as f:
    data = json.load(f)
    print(data['${streak_type}']['current'])
"
}

get_streak_best() {
    local streak_type=$1
    python3 -c "
import json
with open('${DATA_DIR}/streaks.json', 'r') as f:
    data = json.load(f)
    print(data['${streak_type}']['best'])
"
}

get_lives() {
    python3 -c "
import json
with open('${DATA_DIR}/streaks.json', 'r') as f:
    data = json.load(f)
    print(data['lives'])
"
}

# Get today's progress
get_today_study_blocks() {
    local today=$(date '+%Y/%m/%d')
    local count=0
    
    if [ -f "${HOME}/logtime/timelog.ldg" ]; then
        count=$(grep "^i ${today}" "${HOME}/logtime/timelog.ldg" | grep -i "course" | wc -l)
    fi
    echo $count
}

get_today_exercise_status() {
    local today=$(date '+%Y-%m-%d')
    python3 -c "
import json
from datetime import datetime
try:
    with open('${DATA_DIR}/exercise-log.json', 'r') as f:
        data = json.load(f)
        today_logs = [x for x in data if x.get('date', '').startswith('${today}')]
        if any(x.get('complete', False) for x in today_logs):
            print('complete')
        elif today_logs:
            print('partial')
        else:
            print('none')
except:
    print('none')
"
}

# Get week time breakdown
get_week_time() {
    local category=$1
    
    if ! command -v tt &> /dev/null; then
        echo "0m"
        return
    fi
    
    # Get balance output from tt
    local bal_output=$(tt bal 2>/dev/null)
    
    # Parse the output for the category
    # tt bal output format:
    #   9s  Coding:bash:productivity
    #   3s  test:example1
    # We want to match lines that start with the category (case-insensitive)
    
    local time_str=$(echo "$bal_output" | grep -i "^[[:space:]]*[0-9].*${category}" | head -1 | awk '{print $1}')
    
    if [ -z "$time_str" ]; then
        echo "0m"
        return
    fi
    
    # Convert time string to human readable
    # Formats: 9s, 45m, 2.5h, 1.2d
    if [[ $time_str =~ ^([0-9.]+)s$ ]]; then
        echo "${BASH_REMATCH[1]}s"
    elif [[ $time_str =~ ^([0-9.]+)m$ ]]; then
        echo "${BASH_REMATCH[1]}m"
    elif [[ $time_str =~ ^([0-9.]+)h$ ]]; then
        echo "${BASH_REMATCH[1]}h"
    elif [[ $time_str =~ ^([0-9.]+)d$ ]]; then
        local days=${BASH_REMATCH[1]}
        local hours=$(echo "$days * 24" | bc 2>/dev/null || echo "0")
        printf "%.1fh" $hours
    else
        echo "$time_str"
    fi
}

# Get time for display with progress bar
get_time_with_bar() {
    local category=$1
    local time_str=$(get_week_time "$category")
    local max_hours=40  # Max hours for bar calculation
    
    # Extract numeric value for bar
    local hours=0
    if [[ $time_str =~ ^([0-9.]+)h$ ]]; then
        hours=${BASH_REMATCH[1]}
    elif [[ $time_str =~ ^([0-9.]+)m$ ]]; then
        hours=$(echo "${BASH_REMATCH[1]} / 60" | bc -l 2>/dev/null || echo "0")
    elif [[ $time_str =~ ^([0-9.]+)s$ ]]; then
        hours=$(echo "${BASH_REMATCH[1]} / 3600" | bc -l 2>/dev/null || echo "0")
    fi
    
    # Calculate percentage for bar (0-100)
    local percent=$(echo "scale=0; ($hours / $max_hours) * 100" | bc 2>/dev/null || echo "0")
    [ $percent -gt 100 ] && percent=100
    
    # Format output with padding
    printf "%-8s" "$time_str"
    draw_bar $percent 100
}

# Draw progress bar
draw_bar() {
    local current=$1
    local total=$2
    local width=20
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "${GREEN}"
    for i in $(seq 1 $filled); do printf "█"; done
    printf "${NC}"
    for i in $(seq 1 $empty); do printf "░"; done
}

# Show waffle plot (simplified)
show_waffle() {
    echo -e "\n${BOLD}📅 LAST 100 DAYS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    python3 << 'PYEOF'
import json
from datetime import datetime, timedelta

try:
    with open('${DATA_DIR}/habits.json', 'r') as f:
        habits = json.load(f)
    
    today = datetime.now()
    colors = {
        'complete': '\033[0;32m█\033[0m',  # Green
        'partial': '\033[1;33m█\033[0m',   # Yellow
        'missed': '\033[0;31m█\033[0m',    # Red
        'life_used': '\033[0;34m█\033[0m', # Blue
        'future': '\033[0;37m░\033[0m'     # Gray
    }
    
    for week in range(10):
        row = ""
        for day in range(10):
            days_ago = 99 - (week * 10 + day)
            date = today - timedelta(days=days_ago)
            date_str = date.strftime('%Y-%m-%d')
            
            if days_ago < 0:
                row += colors['future']
            elif date_str in habits:
                status = habits[date_str].get('status', 'missed')
                row += colors.get(status, colors['missed'])
            else:
                row += colors['missed']
            row += " "
        print(row)
    
    print("\n🟢 Complete  🟡 Partial  🔴 Missed  🔵 Life Used")
except Exception as e:
    print("No historical data yet")
PYEOF
}

# Main dashboard display
show_dashboard() {
    clear
    
    # Sync data first
    if [ -f "${BIN_DIR}/sync.sh" ]; then
        bash "${BIN_DIR}/sync.sh" pull silent
    fi
    
    local porn_free=$(get_streak "porn_free")
    local porn_free_best=$(get_streak_best "porn_free")
    local routine=$(get_streak "routine")
    local routine_best=$(get_streak_best "routine")
    local github=$(get_streak "github")
    local github_best=$(get_streak_best "github")
    local lives=$(get_lives)
    
    local study_blocks=$(get_today_study_blocks)
    local exercise_status=$(get_today_exercise_status)
    
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║${NC}     ${PURPLE}PRODUCTIVITY DASHBOARD${NC} - $(date '+%b %d, %Y')        ${BOLD}║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${BOLD}🔥 STREAKS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "  ${GREEN}Porn-Free:${NC}        🔥 ${BOLD}%3d days${NC}  (Best: %d)\n" $porn_free $porn_free_best
    printf "  ${CYAN}Routine Complete:${NC} 🔥 ${BOLD}%3d days${NC}  (Best: %d)\n" $routine $routine_best
    printf "  ${BLUE}GitHub Active:${NC}    🔥 ${BOLD}%3d days${NC}  (Best: %d)\n" $github $github_best
    
    echo -e "\n${BOLD}💾 Lives Available:${NC}"
    printf "  "
    for i in $(seq 1 $lives); do printf "❤️  "; done
    for i in $(seq $((lives + 1)) 3); do printf "⚫  "; done
    printf "(%d/3)\n" $lives
    
    echo -e "\n${BOLD}📊 TODAY'S PROGRESS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "  Morning Study:  "
    for i in $(seq 1 $study_blocks); do printf "⬛"; done
    for i in $(seq $((study_blocks + 1)) 4); do printf "⬜"; done
    printf " %d/4 blocks\n" $study_blocks
    
    printf "  Exercise:       "
    case $exercise_status in
        complete) echo -e "${GREEN}✓ Complete${NC}" ;;
        partial)  echo -e "${YELLOW}⚡ In Progress${NC}" ;;
        none)     echo -e "${RED}⏱  Not Started${NC} (7PM reminder)" ;;
    esac
    
    echo -e "\n${BOLD}⏱️  WEEK TIME BREAKDOWN${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    tt bal
    
    show_waffle
    
    echo -e "\n${BOLD}📝 QUICK COMMANDS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  habit check porn-free    - Mark today as porn-free"
    echo "  routine start morning    - Start morning routine"
    echo "  exercise log             - Log exercise session"
    echo "  sync push                - Sync to GitHub"
    echo "  dashboard help           - Show all commands"
    echo ""
}

# Quick view
show_quick() {
    local porn_free=$(get_streak "porn_free")
    local routine=$(get_streak "routine")
    local lives=$(get_lives)
    
    echo -e "${GREEN}🔥 Porn-Free: ${porn_free}d${NC} | ${CYAN}📅 Routine: ${routine}d${NC} | ${RED}❤️  Lives: ${lives}${NC}"
}

# Show help
show_help() {
    cat << 'EOF'
Productivity Dashboard Commands:

DASHBOARD:
  dashboard              Show full dashboard
  dashboard quick        Quick streak view
  dashboard help         Show this help

HABITS:
  habit check porn-free  Mark today as porn-free
  habit break <streak>   Use a life to save a streak
  habit status           Show habit status

ROUTINE:
  routine start          Start routine timer
  routine complete       Mark routine complete
  routine skip           Skip today (uses a life)

EXERCISE:
  exercise log <name>    Log specific exercise
  exercise complete      Mark full routine done
  exercise status        Show exercise progress

SYNC:
  sync pull              Pull from GitHub
  sync push              Push to GitHub  
  sync setup             Setup GitHub sync

TIME TRACKING (use your existing 'tt' script):
  tt in courses "Python"  Clock into courses
  tt in work "Project"    Clock into work
  tt out                  Clock out

EOF
}

# Main entry point
case "${1:-show}" in
    show|"")
        init_data
        show_dashboard
        ;;
    quick)
        init_data
        show_quick
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'dashboard help' for usage"
        exit 1
        ;;
esac

exit 0