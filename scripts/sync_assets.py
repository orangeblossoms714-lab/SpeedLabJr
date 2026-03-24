import os, json, shutil, glob
brain_dir = "/Users/orangeblossom/.gemini/antigravity/brain/2f9e741b-72aa-4fed-b27a-f4267cc5bb01"
xcassets = "/Users/orangeblossom/SpeedLabJr/SpeedLabJr/Assets.xcassets"
os.makedirs(xcassets, exist_ok=True)
images_map = {
    "leg_swings": "leg_swings", "hip_circles": "hip_circles", "butt_kicks": "butt_kicks", 
    "a_skips": "a_skips", "b_skips": "b_skips", "falling_starts": "falling_starts", 
    "accel_sprints": "accel_sprints", "broad_jumps": "broad_jumps", "pogo_hops": "pogo_hops", 
    "quad_stretch": "quad_stretch", "hip_flexor_lunge": "hip_flexor_lunge", 
    "hamstring_stretch": "hamstring_stretch", "high_knees_step_1": "high_knees_1", 
    "squat_step_1": "squat_1", "squat_step_2": "squat_2", "reverse_lunges_1": "reverse_lunges_1"
}

for p in glob.glob(f"{brain_dir}/*.png"):
    fn = os.path.basename(p)
    base = fn.split("_1_")[0]
    if "_2_" in fn: base = fn.split("_2_")[0] + "_2"
    if "high_knees" in base: base = "high_knees_1"
    elif "squat_step_1" in base: base = "squat_1"
    elif "squat_step_2" in base: base = "squat_2"
    elif "reverse_lunges" in base: base = "reverse_lunges_1"
    
    asset_name = base
    if asset_name in images_map.values():
        dir_ = os.path.join(xcassets, f"{asset_name}.imageset")
        os.makedirs(dir_, exist_ok=True)
        shutil.copy2(p, os.path.join(dir_, f"{asset_name}.png"))
        with open(os.path.join(dir_, "Contents.json"), "w") as f:
            json.dump({"images": [{"idiom": "universal", "filename": f"{asset_name}.png", "scale": "1x"}], "info": {"author": "xcode", "version": 1}}, f, indent=2)
print("done syncing assets")
