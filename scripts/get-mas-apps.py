#!/usr/bin/env python

import subprocess

apps = {
    '1284863847': 'Unsplash Wallpapers',
    '1278508951': 'Trello',
    '412736166': 'piZZa',
    '585829637': 'Todoist',
    '557168941': 'Tweetbot',
    '1091189122': 'Bear',
    '918858936': 'Airmail 2',
    '940526959': 'insTuner',
    '867299399': 'OmniFocus',
    '924726344': 'Deliveries',
    '445189367': 'PopClip',
    '449589707': 'Dash'
}

for (masID, title) in apps.items():
    print subprocess.Popen(
        "mas install " + masID,
        shell=True, stdout=subprocess.PIPE
        ).stdout.read()
