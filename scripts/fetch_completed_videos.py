import os
import re
import requests

API_KEY = "REDACTED_GOOGLE_API_KEY"

log_path = os.path.join(os.path.dirname(__file__), 'veo_imagetovideo_day4.log')
videos_dir = os.path.join(os.path.dirname(__file__), '../SpeedLabJr/Videos')

def fetch_completed_videos():
    if not os.path.exists(log_path):
        print("Log file not found.")
        return

    with open(log_path, 'r') as f:
        log_content = f.read()

    # Find all filename and operation ID pairs in the log
    file_matches = re.findall(r'Generating:.*?-> (.*?\.mp4)', log_content)
    op_matches = re.findall(r"name='(models/veo-2.0-generate-001/operations/[a-z0-9]+)'", log_content)
    
    if len(file_matches) != len(op_matches):
        print("Mismatch between requested files and operation IDs in log.")
        
    tasks = list(zip(file_matches, op_matches))
    print(f"Found {len(tasks)} video operations to fetch.")
    
    for filename, op_name in tasks:
        out_path = os.path.join(videos_dir, filename)
        print(f"\nChecking operation for {filename}...")
        
        try:
            # Poll the operation endpoint directly via REST API to bypass SDK bugs
            url = f"https://generativelanguage.googleapis.com/v1beta/{op_name}?key={API_KEY}"
            resp = requests.get(url).json()
            
            if resp.get("done"):
                if "error" in resp:
                    print(f"❌ Operation failed: {resp['error']}")
                else:
                    print(f"✅ Video is ready! Downloading to {out_path}...")
                    try:
                        # Extract the download URI
                        video_uri = resp["response"]["generateVideoResponse"]["generatedSamples"][0]["video"]["uri"]
                        
                        # Add API key to the download URI
                        dl_url = f"{video_uri}&key={API_KEY}" if "?" in video_uri else f"{video_uri}?key={API_KEY}"
                        
                        try:
                            video_resp = requests.get(dl_url, stream=True, timeout=60)
                            if video_resp.status_code == 200:
                                total_size = int(video_resp.headers.get('content-length', 0))
                                downloaded = 0
                                with open(out_path, 'wb') as f:
                                    for chunk in video_resp.iter_content(chunk_size=1024*1024):
                                        if chunk:
                                            f.write(chunk)
                                            downloaded += len(chunk)
                                            if total_size > 0:
                                                done = int(50 * downloaded / total_size)
                                                print(f"\r[{'=' * done}{' ' * (50-done)}] {downloaded//1024//1024}MB / {total_size//1024//1024}MB", end='', flush=True)
                                            else:
                                                print(f"\rDownloaded {downloaded//1024//1024}MB...", end='', flush=True)
                                print(f"\nSuccessfully saved {filename}!")
                            else:
                                print(f"Failed to download video bytes. Status code: {video_resp.status_code}")
                        except requests.exceptions.RequestException as req_err:
                            print(f"\nNetwork error during download: {req_err}")
                            
                    except KeyError as e:
                        print(f"Could not extract video URI from response JSON.")
            else:
                print("⏳ Still generating on Google's servers. Check back later!")
                
        except Exception as e:
            print(f"Error checking operation {op_name}: {e}")

if __name__ == "__main__":
    fetch_completed_videos()
