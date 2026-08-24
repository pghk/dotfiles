#!/usr/bin/env bash
set -euo pipefail

no_color=false
compact=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-color)
      no_color=true
      ;;
    --compact)
      compact=true
      ;;
    -h|--help)
      echo "Usage: $(basename "$0") [--no-color] [--compact]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $(basename "$0") [--no-color] [--compact]" >&2
      exit 1
      ;;
  esac
  shift
done

if [[ "$no_color" == true ]]; then
  export WKDAYS_NO_COLOR=1
fi
if [[ "$compact" == true ]]; then
  export WKDAYS_COMPACT=1
fi

python3 - <<'PY'
import os
import re
import shutil
import subprocess
from datetime import date

now = date.today()
no_color = os.environ.get('WKDAYS_NO_COLOR') == '1'
compact = os.environ.get('WKDAYS_COMPACT') == '1'

def visible_len(s: str) -> int:
    return len(re.sub(r'\x1b\[[0-9;]*m', '', s))


def pad_visible(s: str, width: int, align: str = 'left') -> str:
    visible = visible_len(s)
    if visible >= width:
        return s
    pad = ' ' * (width - visible)
    if align == 'right':
        return pad + s
    return s + pad

# Weekday totals for the current month.
month_days = []
for week in __import__('calendar').monthcalendar(now.year, now.month):
    month_days.append(week)

weekday_total = 0
weekday_elapsed = 0
for week in month_days:
    for idx, day in enumerate(week):
        if day == 0:
            continue
        if idx in (1, 2, 3, 4, 5):
            weekday_total += 1
            if day <= now.day:
                weekday_elapsed += 1

remaining = max(weekday_total - weekday_elapsed, 0)
percentage_elapsed = 0.0 if weekday_total == 0 else (weekday_elapsed / weekday_total) * 100
percentage_remaining = 0.0 if weekday_total == 0 else (remaining / weekday_total) * 100

# Use the system calendar output directly so the month heading and spacing stay faithful.
cal_output = subprocess.check_output(['cal', str(now.month), str(now.year)], text=True)
calendar_lines = cal_output.splitlines()[1:]

use_color = subprocess.run(['test', '-t', '1'], check=False).returncode == 0 and not no_color
if use_color:
    current_day = str(now.day)
    for i, line in enumerate(calendar_lines):
        if i == 0:
            for weekday in ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']:
                line = re.sub(
                    rf'(?<!\S){re.escape(weekday)}(?=\s|$)',
                    f'\033[2;37m{weekday}\033[0m',
                    line,
                )

        # Highlight today without disturbing the spacing of the native cal output.
        line = re.sub(
            rf'(?<!\d){re.escape(current_day)}(?!\d)',
            f'\033[1;35m{current_day}\033[0m',
            line,
        )
        calendar_lines[i] = line

day_name = now.strftime('%A')
ordinal = now.strftime('%d')
if ordinal.endswith('1') and not ordinal.endswith('11'):
    ordinal_suffix = 'st'
elif ordinal.endswith('2') and not ordinal.endswith('12'):
    ordinal_suffix = 'nd'
elif ordinal.endswith('3') and not ordinal.endswith('13'):
    ordinal_suffix = 'rd'
else:
    ordinal_suffix = 'th'

month_name = now.strftime('%B')
full_month_date = f"{day_name}, {month_name} {int(ordinal)}{ordinal_suffix}, {now.year}"
if use_color:
    reset = '\033[0m'
    blue = '\033[1;36m'
    green = '\033[1;32m'
    yellow = '\033[1;33m'
else:
    reset = ''
    blue = ''
    green = ''
    yellow = ''

stats = [
    f"{blue}{full_month_date}{reset}",
    "",
    f"{yellow}Elapsed: {weekday_elapsed}/{weekday_total} ({percentage_elapsed:.2f}%){reset}",
    f"{green}Remaining: {remaining} weekdays ({percentage_remaining:.2f}%){reset}",
]
stats_text = '\n'.join(stats)

term_width = shutil.get_terminal_size((100, 24)).columns
if compact:
    print(f"Weekdays elapsed in {now.strftime('%b %Y')}: {weekday_elapsed}/{weekday_total} ({percentage_elapsed:.2f}%)")
elif term_width >= 80:
    stats_lines = stats_text.splitlines()
    max_lines = max(len(calendar_lines), len(stats_lines))
    calendar_lines += [''] * (max_lines - len(calendar_lines))
    stats_lines += [''] * (max_lines - len(stats_lines))

    left_width = max(visible_len(line) for line in calendar_lines) + 2
    right_width = max(visible_len(line) for line in stats_lines)
    lines = []
    for cal_line, stats_line in zip(calendar_lines, stats_lines):
        stats_cell = pad_visible(stats_line, right_width, align='left')
        cal_cell = pad_visible(cal_line, left_width, align='left')
        lines.append(f"{cal_cell}  {stats_cell}")
    print('\n' + '\n'.join(lines))
else:
    print('\n' + '\n'.join(calendar_lines) + '\n\n' + stats_text)
PY
