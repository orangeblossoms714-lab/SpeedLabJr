import os
import time
from google import genai
from google.genai import types
from google import genai

API_KEY = "REDACTED_GOOGLE_API_KEY"
client = genai.Client(api_key=API_KEY)

screenshots_dir = os.path.expanduser("~/Documents/video screenshots")

day4 = [
    ("World's Greatest Stretch", "worlds-greatest-stretch.mp4", "A fitness instructor demonstrating the World's Greatest Stretch on a track, maintaining the starting pose exactly as shown.", "worlds greatest stretch.png"),
    ("90/90 Hip Stretch", "90-90-hip-stretch.mp4", "A fitness instructor demonstrating a 90/90 Hip Stretch on a yoga mat. Start exactly in this pose and gently twist.", "90:90 stretch.png"),
    ("Hip Flexor Lunge + Reach", "hip-flexor-lunge-and-reach.mp4", "A fitness instructor demonstrating a Hip Flexor Lunge with a Reach. Start exactly in this lunge position and stretch upward.", "hip flexor lunge reach.png"),
    ("Thread the Needle", "thread-the-needle.mp4", "A fitness instructor demonstrating the Thread the Needle stretch. Start exactly in this pose and stretch the shoulder.", "thread the needle.png"),
    ("Ankle Circles", "ankle-circles.mp4", "A fitness instructor demonstrating ankle circles. Start with this exact pose and rotate the ankle slowly.", "ankle circles.png"),
    ("Single-Leg RDL (bodyweight)", "single-leg-rdl-bodyweight.mp4", "A fitness instructor demonstrating a Single-Leg RDL bodyweight exercise. Start exactly in this balancing pose.", "single-leg RDL.png"),
    ("Heel-to-Toe Walk (tightrope)", "heel-to-toe-walk-tightrope.mp4", "A fitness instructor demonstrating a heel-to-toe tightrope walk. Start exactly in this balanced stance.", "heel-to-toe walk (tightrope).png")
]

log_file = os.path.join(os.path.dirname(__file__), "veo_imagetovideo_day4.log")

def generate():
    with open(log_file, "w") as f:
        f.write("Starting Image-To-Video batch generation...\n")
        
    for name, filename, prompt, img_name in day4:
        img_path = os.path.join(screenshots_dir, img_name)
        if not os.path.exists(img_path):
            print(f"Skipping {name}: Image {img_name} not found.")
            continue
            
        print(f"\n--- Uploading Initial Frame Image for: {name} ---")
        with open(log_file, "a") as f:
            f.write(f"\n--- Generating: {name} -> {filename} ---\n")
        
        try:
            # 1. Load the flat image bytes
            with open(img_path, "rb") as img_file:
                img_bytes = img_file.read()
            
            # 2. Call Veo 2 API using the strict Pydantic Image type
            print(f"Sending request to Veo 2 for {name}...")
            response = client.models.generate_videos(
                model='veo-2.0-generate-001',
                prompt=prompt,
                image=types.Image(image_bytes=img_bytes, mime_type="image/png")
            )
            
            print(f"Received Operation ID from Google: {response.name}")
            with open(log_file, "a") as f:
                f.write(f"Operation Info: name='{response.name}'\n")
            
            print("Waiting 60 seconds before queueing the next video to avoid quota limits...")
            time.sleep(60)
            
        except Exception as e:
            print(f"Error generating {name}: {e}")
            with open(log_file, "a") as f:
                f.write(f"Error: {e}\n")

if __name__ == "__main__":
    generate()
