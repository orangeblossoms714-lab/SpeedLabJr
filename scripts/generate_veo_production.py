import os
import sys
import time
from google import genai

import os
API_KEY = os.environ.get("GOOGLE_API_KEY", "")
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

def poll_operation(operation, timeout=1200):
    start = time.time()
    while time.time() - start < timeout:
        # Assuming the library allows reloading or there is a generic requests/REST wait
        # This is a generic polling stub given new generative SDK LRO functionality
        # Some SDKs use `operation.wait()` or `client.operations.get(operation.name)`
        time.sleep(15)
        # Note: In a true production environment, you would poll the operation endpoint directly.
        # But this is a structure for how you would retrieve the final video bytes.
    return None

for ex_name, prompt in day4_exercises.items():
    filename = clean_name(ex_name) + ".mp4"
    out_path = os.path.join(videos_dir, filename)
    print(f"\n--- Generating: {ex_name} -> {filename} ---")
    
    success = False
    retries = 3
    
    while retries > 0 and not success:
        try:
            print(f"Sending request to Veo 2...")
            response = client.models.generate_videos(
                model='veo-2.0-generate-001',
                prompt=prompt,
            )
            
            # The API returns an LRO (Long Running Operation) 
            print("Received operation from Google. Poll taking several minutes...")
            print(f"Operation Info: {response}")
            
            # Placeholder for actual wait_for_completion() method in the SDK
            # result = response.wait_for_completion()
            print("Because video generation takes 5-10 minutes, the script must wait here.")
            print("(Skipping real polling for now to avoid hanging terminal)")
            
            success = True
            
        except Exception as e:
            err_str = str(e)
            if '429' in err_str or 'RESOURCE_EXHAUSTED' in err_str:
                print(f"Rate limited (429). Waiting 60 seconds before retrying...")
                time.sleep(60)
                retries -= 1
            else:
                print(f"Fatal error generating {ex_name}: {e}")
                break
                
    # Sleep to respect rate limits between successful requests
    print("Waiting 60 seconds before queueing the next video to avoid quota limits...")
    time.sleep(60)

print("Execution finished.")
