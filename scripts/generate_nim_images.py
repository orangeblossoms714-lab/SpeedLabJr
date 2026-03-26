import urllib.request
import json
import base64
import os
import time

import os
API_KEY = os.environ.get("NVIDIA_API_KEY", "")
MODEL = "stabilityai/stable-diffusion-3-medium"
url = f"https://ai.api.nvidia.com/v1/genai/{MODEL}"
brain_dir = "/Users/orangeblossom/.gemini/antigravity/brain/2f9e741b-72aa-4fed-b27a-f4267cc5bb01"
os.makedirs(brain_dir, exist_ok=True)

prompts = {
    "walking_lunges_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner performing walking lunges. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "arm_circles_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner standing and performing arm circles. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "inchworm_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner performing an inchworm walk-out on the ground. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "glute_bridges_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner lying on their back performing a glute bridge. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "single_leg_balance_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner performing a single-leg balance pose. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "dead_bug_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner lying on their back performing a dead bug core exercise. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "plank_hold_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner holding a solid elbow plank. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "side_plank_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner holding a side plank on one elbow. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "childs_pose_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner performing a child's pose stretch on the floor. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "pigeon_pose_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner performing a pigeon pose hip stretch on the floor. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "cat_cow_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner on hands and knees performing a cat-cow spinal stretch. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "easy_jog_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner doing a very relaxed, easy warm-up jog. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "carioca_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner performing a lateral carioca grapevine drill. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "flying_20s_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner sprinting at absolute maximum velocity (top end speed, upright posture). Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "repeats_60m_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner performing a relaxed 60-meter sprint repeat. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "stride_outs_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner bounding smoothly in a relaxing stride-out. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "bounding_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner mid-air executing a massive plyometric bound stride. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "lateral_hops_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner performing side-to-side lateral line hops. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "easy_walk_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner doing a relaxed, walking cool-down. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "seated_hamstring_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner sitting on the track directly reaching forward for a seated hamstring stretch. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "standing_calf_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner leaning forward against an invisible wall for a standing calf stretch. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "worlds_greatest_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner in a deep lunge actively twisting their torso up toward the ceiling for the world's greatest stretch. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "hip_stretch_9090_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner sitting on the floor in a 90/90 hip mobility stretch. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "hip_flexor_reach_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner in a half-kneeling hip flexor lunge actively reaching one arm overhead. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "thread_the_needle_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner on the ground threading one arm under the other for a spinal stretch. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "ankle_circles_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner seated rolling their ankle for ankle circles. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "single_leg_rdl_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner balancing on one leg, leaning forward with the back leg extended straight out for a single-leg RDL. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background.",
    "tightrope_walk_1": "Minimalist 2D flat vector art illustration. A sleek, athletic silhouette of a track runner perfectly balancing walking heel-to-toe on an invisible tightrope line. Dark neon blue and gold color theme. Clean geometry, premium modern fitness app aesthetic. Solid white background."
}

print("Starting generation pipeline over SD3 Medium...")
for name, p in prompts.items():
    print(f"Generating {name}...")
    payload = {
        "prompt": p,
        "cfg_scale": 5,
        "seed": 42,
        "steps": 40
    }
    req = urllib.request.Request(url, json.dumps(payload).encode("utf-8"), headers={
        "Authorization": f"Bearer {API_KEY}",
        "Accept": "application/json",
        "Content-Type": "application/json"
    })
    
    try:
        res = urllib.request.urlopen(req)
        body = json.loads(res.read().decode("utf-8"))
        b64 = body.get("image")
        if b64:
            with open(os.path.join(brain_dir, f"{name}.png"), "wb") as f:
                f.write(base64.b64decode(b64))
            print(" -> Success!")
        else:
            print(" -> Failed: No image attribute found in response.", body.keys())
    except Exception as e:
        if hasattr(e, "read"):
            print(" -> Failed:", e.read().decode("utf-8"))
        else:
            print(" -> Failed:", e)
    
    time.sleep(1) # Minor rate limit buffer

print("All tasks completed.")
