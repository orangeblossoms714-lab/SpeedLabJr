import os
import json
import shutil
import glob

# Paths
brain_dir = "/Users/orangeblossom/.gemini/antigravity/brain/2f9e741b-72aa-4fed-b27a-f4267cc5bb01"
xcassets = "/Users/orangeblossom/SpeedLabJr/SpeedLabJr/Assets.xcassets"
md_file = "/Users/orangeblossom/SpeedLabJr/Exercise_Guides.md"
swift_file = "/Users/orangeblossom/SpeedLabJr/SpeedLabJr/Models/TutorialDatabase.swift"

# 1. Process Assets from Artifact Directory
# We dynamically pull all 13 generated images and convert them into Xcode imagesets
images_map = {
    "leg_swings": "leg_swings",
    "hip_circles": "hip_circles",
    "butt_kicks": "butt_kicks",
    "a_skips": "a_skips",
    "b_skips": "b_skips",
    "falling_starts": "falling_starts",
    "accel_sprints": "accel_sprints",
    "broad_jumps": "broad_jumps",
    "pogo_hops": "pogo_hops",
    "quad_stretch": "quad_stretch",
    "hip_flexor_lunge": "hip_flexor_lunge",
    "hamstring_stretch": "hamstring_stretch",
    "high_knees_step_1": "high_knees_1",
    "squat_step_1": "squat_1",
    "squat_step_2": "squat_2"
}

os.makedirs(xcassets, exist_ok=True)
for p in glob.glob(f"{brain_dir}/*.png"):
    filename = os.path.basename(p)
    
    # Try to map the file to our target names
    for key, val in images_map.items():
        if filename.startswith(key):
            asset_name = val
            imageset_dir = os.path.join(xcassets, f"{asset_name}.imageset")
            os.makedirs(imageset_dir, exist_ok=True)
            shutil.copy2(p, os.path.join(imageset_dir, f"{asset_name}.png"))
            
            contents = {
                "images": [{"idiom": "universal", "filename": f"{asset_name}.png", "scale": "1x"}],
                "info": {"author": "xcode", "version": 1}
            }
            with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
                json.dump(contents, f, indent=2)

# 2. Parse Markdown and Output Native Swift Data Structure
with open(md_file, "r") as f:
    lines = f.readlines()

output_swift = """// TutorialDatabase.swift
// SpeedLabJr

import Foundation

struct ExerciseTutorial {
    let images: [String]
    let instructions: String
}

class TutorialDatabase {
    static let data: [String: ExerciseTutorial] = [
"""

current_name = None
current_instructions = ""

for line in lines:
    line = line.strip()
    if line.startswith("### "):
        if current_name:
            current_images = []
            if "Squat" in current_name: current_images = ["squat_1", "squat_2"]
            elif "High Knees" in current_name: current_images = ["high_knees_1"]
            elif "Leg Swings" in current_name: current_images = ["leg_swings"]
            elif "Hip Circles" in current_name: current_images = ["hip_circles"]
            elif "Butt Kicks" in current_name: current_images = ["butt_kicks"]
            elif "A-Skips" in current_name: current_images = ["a_skips"]
            elif "B-Skips" in current_name: current_images = ["b_skips"]
            elif "Falling Starts" in current_name: current_images = ["falling_starts"]
            elif "Acceleration Sprints" in current_name: current_images = ["accel_sprints"]
            elif "Broad Jumps" in current_name: current_images = ["broad_jumps"]
            elif "Pogo Hops" in current_name: current_images = ["pogo_hops"]
            elif "Standing Quad" in current_name: current_images = ["quad_stretch"]
            elif "Hip Flexor" in current_name: current_images = ["hip_flexor_lunge"]
            elif "Hamstring Stretch (standing)" in current_name: current_images = ["hamstring_stretch"]
            
            inst = current_instructions.strip().replace('"', '\\"')
            imgs = ", ".join(f'"{i}"' for i in current_images)
            output_swift += f'        "{current_name}": ExerciseTutorial(images: [{imgs}], instructions: "{inst}"),\n'
                
        current_name = line[4:].strip()
        current_instructions = ""
    elif line.startswith("**Instructions:**"):
        text = line.replace("**Instructions:** ", "")
        current_instructions += text + "\\n\\n"
    elif line.startswith("**Focus:**"):
        text = line.replace("**Focus:** ", "")
        current_instructions += "**Focus:** " + text + "\\n"

if current_name:
    inst = current_instructions.strip().replace('"', '\\"')
    output_swift += f'        "{current_name}": ExerciseTutorial(images: [], instructions: "{inst}")\n'

output_swift += """    ]
    
    static func tutorial(for exerciseName: String) -> ExerciseTutorial {
        return data[exerciseName] ?? ExerciseTutorial(images: [], instructions: "Instructions coming soon.")
    }
}
"""

with open(swift_file, "w") as f:
    f.write(output_swift)
print("Assets and Data successfully bundled to iOS app!")
