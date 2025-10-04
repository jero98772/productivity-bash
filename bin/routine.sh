#!/bin/bash

# Routine Scheduler
# Manage morning study and evening exercise routines

PROD_HOME="${HOME}/.productivity"
DATA_DIR="${PROD_HOME}/data"
BIN_DIR="${PROD_HOME}/bin"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Pomodoro timer
pomodoro_timer() {
    local duration=$1
    local message=$2
    
    echo -e "${GREEN}Timer started: ${duration} minutes${NC}"
    echo -e "${CYAN}$message${NC}"
    echo ""
    
    # Calculate end time
    local end_time=$(date -d "+${duration} minutes" '+%H:%M')
    echo "Will complete at: $end_time"
    echo ""
    echo "Press Ctrl+C to stop timer"
    
    # Timer loop
    local seconds=$((duration * 60))
    local elapsed=0
    
    while [ $elapsed -lt $seconds ]; do
        local remaining=$((seconds - elapsed))
        local mins=$((remaining / 60))
        local secs=$((remaining % 60))
        
        printf "\r⏱  Time remaining: %02d:%02d  " $mins $secs
        sleep 1
        elapsed=$((elapsed + 1))
    done
    
    echo ""
    echo ""
    echo -e "${GREEN}${BOLD}✓ Timer complete! Great work!${NC}"
    
    # Play a sound if available
    if command -v paplay &> /dev/null; then
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
    elif command -v afplay &> /dev/null; then
        afplay /System/Library/Sounds/Glass.aiff 2>/dev/null &
    fi
}

# Start morning routine
start_morning() {
    local block=${1:-1}
    
    echo -e "${BOLD}╔════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║${NC}    🌅 MORNING STUDY ROUTINE 📚        ${BOLD}║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Block $block of 4"
    echo ""
    echo "Schedule:"
    echo "  Block 1: 6:00 - 6:25 (25 min)"
    echo "  Break:   6:25 - 6:30 (5 min)"
    echo "  Block 2: 6:30 - 6:55 (25 min)"
    echo "  Break:   6:55 - 7:00 (5 min)"
    echo "  Block 3: 7:00 - 7:25 (25 min)"
    echo "  Break:   7:25 - 7:30 (5 min)"
    echo "  Block 4: 7:30 - 7:55 (25 min)"
    echo ""
    
    read -p "Start Block $block? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Start time tracking
        if [ -f "${HOME}/bin/tt" ] || command -v tt &> /dev/null; then
            tt in courses "Morning Study Block $block"
        fi
        
        pomodoro_timer 25 "Focus time! Study block $block"
        
        # Stop time tracking
        if [ -f "${HOME}/bin/tt" ] || command -v tt &> /dev/null; then
            tt out
        fi
        
        echo ""
        echo -e "${YELLOW}Take a 5-minute break!${NC}"
        
        if [ $block -lt 4 ]; then
            read -p "Start next block? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sleep 5
                start_morning $((block + 1))
            fi
        else
            echo -e "${GREEN}Morning routine complete! 🎉${NC}"
        fi
    fi
}

# Start exercise routine
start_exercise() {
    echo -e "${BOLD}╔════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║${NC}    🏋️  EVENING EXERCISE ROUTINE 💪     ${BOLD}║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Your routine:"
    echo ""
    echo "BOO STAFF:"
    echo "  1. Head 2x"
    echo "  2. Rotate back 10x"
    echo "  3. Legs 10x"
    echo ""
    echo "BIG SWORD:"
    echo "  4. Up/down each hand 10x"
    echo "  5. Up moves 10x"
    echo "  6. Infinite 10x"
    echo ""
    echo "SMALL SWORD:"
    echo "  7. Up/down each hand 10x"
    echo "  8. Up moves 10x"
    echo "  9. Infinite 10x"
    echo "  10. Fishing 10x"
    echo ""
    echo "GENERAL:"
    echo "  11. Push-ups 10x"
    echo "  12. Punches 10x"
    echo "  13. Kicks 10x"
    echo "  14. Clowns 40x"
    echo "  15. Skipping 40x"
    echo "  16. Sentadillas 10x"
    echo ""
    echo "Log each exercise with: exercise log <number>"
    echo "Example: exercise log 11"
    echo ""
    
    pomodoro_timer 60 "Exercise time! Do as many as you can in 1 hour"
    
    echo ""
    read -p "Did you complete the full routine? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash "${BIN_DIR}/exercise.sh" complete
    else
        echo "Partial completion recorded. Keep going tomorrow!"
    fi
}

# Walking reminder
start_walk() {
    echo -e "${CYAN}🚶 Time for your evening walk!${NC}"
    echo "Duration: 1 hour (8:00 - 9:00 PM)"
    echo ""
    
    pomodoro_timer 60 "Walking time! Get some fresh air 🌙"
    
    echo ""
    echo -e "${GREEN}Walk complete! Time for a bath and language learning!${NC}"
}

# Skip routine (uses a life)
skip_routine() {
    echo -e "${YELLOW}Skipping routine today...${NC}"
    bash "${BIN_DIR}/habit.sh" break routine
}

# Show routine schedule
show_schedule() {
    echo -e "${BOLD}📅 Daily Routine Schedule${NC}"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo -e "${CYAN}MORNING (6:00 - 8:00):${NC}"
    echo "  6:00 - 6:25  Study Block 1 (25 min)"
    echo "  6:25 - 6:30  Break (5 min)"
    echo "  6:30 - 6:55  Study Block 2 (25 min)"
    echo "  6:55 - 7:00  Break (5 min)"
    echo "  7:00 - 7:25  Study Block 3 (25 min)"
    echo "  7:25 - 7:30  Break (5 min)"
    echo "  7:30 - 7:55  Study Block 4 (25 min)"
    echo "  7:55 - 8:00  Break (5 min)"
    echo ""
    echo -e "${CYAN}EVENING (7:00 PM - 9:00 PM):${NC}"
    echo "  7:00 - 8:00 PM  Exercise Routine (1 hour)"
    echo "  8:00 - 9:00 PM  Evening Walk (1 hour)"
    echo "  9:00 PM+        Bath & Language Learning"
    echo ""
}

# Check current time and suggest action
suggest_action() {
    local hour=$(date +%H)
    local minute=$(date +%M)
    
    echo -e "${BOLD}⏰ Current Time: $(date '+%H:%M')${NC}"
    echo ""
    
    if [ $hour -ge 6 ] && [ $hour -lt 8 ]; then
        echo "It's morning study time! 📚"
        echo "Run: routine start morning"
    elif [ $hour -ge 19 ] && [ $hour -lt 20 ]; then
        echo "It's exercise time! 🏋️"
        echo "Run: routine start exercise"
    elif [ $hour -ge 20 ] && [ $hour -lt 21 ]; then
        echo "It's walking time! 🚶"
        echo "Run: routine start walk"
    elif [ $hour -ge 21 ]; then
        echo "Time for bath and language learning! 🌙"
    else
        echo "Free time! Keep up the good work! 💪"
    fi
}

# Main command handler
case "${1}" in
    start)
        case "${2}" in
            morning|m)
                start_morning
                ;;
            exercise|ex)
                start_exercise
                ;;
            walk|w)
                start_walk
                ;;
            *)
                suggest_action
                echo ""
                echo "Usage: routine start [morning|exercise|walk]"
                ;;
        esac
        ;;
    
    skip)
        skip_routine
        ;;
    
    schedule|s)
        show_schedule
        ;;
    
    suggest)
        suggest_action
        ;;
    
    complete)
        bash "${BIN_DIR}/habit.sh" complete
        ;;
    
    *)
        cat << 'EOF'
Routine Scheduler Commands:

  routine start morning   - Start morning study routine
  routine start exercise  - Start evening exercise
  routine start walk      - Start walking timer
  routine skip            - Skip today (uses a life)
  routine schedule        - Show full schedule
  routine suggest         - Get suggestion based on time
  routine complete        - Mark full routine complete

Examples:
  routine start morning
  routine start exercise
  routine schedule

EOF
        ;;
esac

exit 0