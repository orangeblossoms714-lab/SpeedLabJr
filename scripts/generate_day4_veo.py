import os
import sys
import time
import requests
from google import genai
from google.genai import types

API_KEY = "REDACTED_GOOGLE_API_KEY"

# Initialize Client
client = genai.Client(api_key=API_KEY)

day4_exercises = {
    "Easy Jog or Brisk Walk": "Cinematic 4k realistic footage of a track athlete doing a very light, easy jog to warm up. Smooth tracking shot, natural lighting.",
    "World's Greatest Stretch": "Cinematic 4k realistic footage of an athlete performing the 'World's Greatest Stretch'. They are in a deep lunge position, rotating their torso, and reaching one arm high into the air. Good form.",
    "90/90 Hip Stretch": "Cinematic 4k footage of an athlete sitting on the floor performing a 90/90 hip mobility stretch. Both legs are bent at 90-degree angles on the ground. Calm, stable wide shot.",
    "Hip Flexor Lunge + Reach": "Cinematic footage of an athlete in a low kneeling lunge, pushing their hips gently forward to stretch the hip flexor, while reaching one arm up and extending slightly backward.",
    "Thread the Needle": "Cinematic 4k realistic footage of an athlete on their hands and knees 'threading the needle' by passing one arm underneath their body to stretch their upper back.",
    "Ankle Circles": "Close-up 4k cinematic footage of an athlete standing and balancing on one leg, slowly rotating their raised ankle in circles.",
    "Single-Leg RDL (bodyweight)": "Cinematic footage of an athlete performing a single-leg Romanian deadlift with bodyweight only. They balance on one leg, hinge at the hips, keeping the back straight, and slowly return to standing.",
    "Heel-to-Toe Walk (tightrope)": "Cinematic footage of an athlete performing a strict heel-to-toe walk in a straight line, arms slightly extended for balance, focusing on core control."
}

def clean_name(name):
    n = name.lower()
    for c in [" ", "/"]: n = n.replace(c, "-")
    for c in ["(", ")", "'"]: n = n.replace(c, "")
    n = n.replace("+", "and")
    n = n.replace("---", "-").replace("--", "-")
    return n

videos_dir = os.path.join(os.path.dirname(__file__), '../SpeedLabJr/Videos')

for ex_name, prompt in day4_exercises.items():
    filename = clean_name(ex_name) + ".mp4"
    out_path = os.path.join(videos_dir, filename)
    print(f"Generating: {ex_name} -> {filename}")
    
    try:
        # Note: 'veo-2.0-generate-001' or 'veo-001' are typical names, we'll try 'veo-2.0-generate-001'
        print(f"  Sending prompt: {prompt}")
        response = client.models.generate_videos(
            model='veo-2.0-generate-001',
            prompt=prompt,
        )
        
        # Typically the google-genai response for videos returns an LRO (Long Running Operation) 
        # or a direct video payload. Assuming the SDK handles it or returns bytes:
        if hasattr(response, 'generated_videos') and response.generated_videos:
            video_bytes = response.generated_videos[0].video.video_bytes
            with open(out_path, 'wb') as f:
                f.write(video_bytes)
            print(f"  Saved to {out_path}!")
        else:
            print("  Warning: No video bytes returned in response.")
            print(response)
            
    except Exception as e:
        print(f"  Error generating {ex_name}: {e}")
        break # stop on first error to prevent useless loop
        
print("Execution finished.")
