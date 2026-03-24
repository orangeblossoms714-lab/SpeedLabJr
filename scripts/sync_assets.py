import os, json, shutil, glob

brain_dir = "/Users/orangeblossom/.gemini/antigravity/brain/2f9e741b-72aa-4fed-b27a-f4267cc5bb01"
xcassets = "/Users/orangeblossom/SpeedLabJr/SpeedLabJr/Assets.xcassets"
os.makedirs(xcassets, exist_ok=True)

# Process any PNG file located in the artifact directory
for p in glob.glob(f"{brain_dir}/*.png"):
    fn = os.path.basename(p)
    base = fn.replace(".png", "")
    if "_1_" in base and len(base.split("_1_")) > 1:
        base = base.split("_1_")[0] + "_1"
    
    # Check for specific variations like squat_step_2_ or high_knees...
    if "_2_" in fn: base = fn.split("_2_")[0] + "_2"
    if "high_knees" in base: base = "high_knees_1"
    elif "squat_step_1" in base: base = "squat_1"
    elif "squat_step_2" in base: base = "squat_2"
    elif "reverse_lunges_1" in base: base = "reverse_lunges_1"
    # Wait, the rest are just standard, e.g. worlds_greatest_1, pigeon_pose_1, etc.
    
    asset_name = base
    dir_ = os.path.join(xcassets, f"{asset_name}.imageset")
    os.makedirs(dir_, exist_ok=True)
    shutil.copy2(p, os.path.join(dir_, f"{asset_name}.png"))
    with open(os.path.join(dir_, "Contents.json"), "w") as f:
        json.dump({"images": [{"idiom": "universal", "filename": f"{asset_name}.png", "scale": "1x"}], "info": {"author": "xcode", "version": 1}}, f, indent=2)

print("Dynamically synchronized all assets into Xcode Project!")
