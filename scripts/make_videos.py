import os
import re
import shutil
import urllib.request

src_file = os.path.join(os.path.dirname(__file__), '../SpeedLabJr/Models/WorkoutProgram.swift')
videos_dir = os.path.join(os.path.dirname(__file__), '../SpeedLabJr/Videos')

os.makedirs(videos_dir, exist_ok=True)

# Download a sample mp4 if we don't have one
sample_mp4 = os.path.join(videos_dir, 'sample.mp4')
if not os.path.exists(sample_mp4):
    urllib.request.urlretrieve("https://www.w3schools.com/html/mov_bbb.mp4", sample_mp4)

with open(src_file, 'r') as f:
    text = f.read()

# Extract 'name: "..."'
exercises = []
for line in text.split('\n'):
    match = re.search(r'Exercise\(name:\s*"([^"]+)"', line)
    if match:
        exercises.append(match.group(1))

print(f"Found {len(exercises)} exercises. Copying videos...")

def clean_name(name):
    # Match the Swift computed property logic
    n = name.lower()
    n = n.replace(" ", "-")
    n = n.replace("/", "-")
    n = n.replace("(", "")
    n = n.replace(")", "")
    n = n.replace("+", "and")
    n = n.replace("'", "")
    n = n.replace("---", "-")
    n = n.replace("--", "-")
    return n

for ex in exercises:
    filename = clean_name(ex) + ".mp4"
    out_path = os.path.join(videos_dir, filename)
    if not os.path.exists(out_path):
        shutil.copy(sample_mp4, out_path)
        print(f"Copied {filename}")

print("Done copying wrapper videos!")
