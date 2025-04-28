#!/bin/bash

function list_activities() {
  qdbus org.kde.ActivityManager /ActivityManager/Activities ListActivities | \
    xargs -I{} bash -c 'echo "{}: $(qdbus org.kde.ActivityManager /ActivityManager/Activities ActivityName {})"'
}

# ACTIVITIES on 'pc'
# b1b8ca03-993c-4af2-b6fe-e8315477f822: 1 browsing
# 6d5d5844-6c78-4878-b65d-e8cce82d2b1a: 2 chatting
# 9e5b01ec-a69e-46fc-a354-ba4271f5aa98: 3 CODING
# 38ddb873-0628-41b5-b792-2088ffad095c: 4 writing
# ad8fea51-e974-4b2b-a1df-404faeb344c9: 5 3d Printing
#
# ACTIVITIES on 'laptop'
# c1f3a5b0-33c0-4fd5-acae-a4b6a19a9db6: Browsing
# 238d45f6-1b06-45ed-b8da-62b5b94862f1: Chatting
# 92107dd8-4434-41ab-99d7-d374283a3673: Coding
# 18de0338-2b1a-47bf-ae1c-c7f2b22dc11e: Writing

# Get current hostname
hostname=$(hostname)

# Map activity names to their IDs based on hostname
declare -A activity_ids

if [[ "$hostname" == "laptop" ]]; then
  # Activity IDs for 'laptop'
  activity_ids[browsing]="c1f3a5b0-33c0-4fd5-acae-a4b6a19a9db6"
  activity_ids[chatting]="238d45f6-1b06-45ed-b8da-62b5b94862f1"
  activity_ids[coding]="92107dd8-4434-41ab-99d7-d374283a3673"
  activity_ids[writing]="18de0338-2b1a-47bf-ae1c-c7f2b22dc11e"
else
  # Default activity IDs for 'pc'
  activity_ids[browsing]="b1b8ca03-993c-4af2-b6fe-e8315477f822"
  activity_ids[chatting]="6d5d5844-6c78-4878-b65d-e8cce82d2b1a"
  activity_ids[coding]="9e5b01ec-a69e-46fc-a354-ba4271f5aa98"
  activity_ids[writing]="38ddb873-0628-41b5-b792-2088ffad095c"
  activity_ids["3d printing"]="ad8fea51-e974-4b2b-a1df-404faeb344c9"
fi

activity="$1"

# Check if the provided activity exists in our map
if [[ -z "${activity_ids[$activity]}" ]]; then
  echo "Error: Invalid activity '$activity'."
  echo "Valid options for $hostname are: ${!activity_ids[@]}"
  exit 1
fi

# Switch to the selected activity
qdbus org.kde.ActivityManager /ActivityManager/Activities SetCurrentActivity "${activity_ids[$activity]}"
