import os
import sys

try:
    from google import genai
    client = genai.Client(api_key="REDACTED_GOOGLE_API_KEY")
    print("Client initialized")
    models = client.models.list()
    for m in models:
        if 'veo' in m.name.lower() or 'video' in getattr(m, 'supported_generation_methods', []):
            print(f"Found Veo model: {m.name}")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
