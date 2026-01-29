import requests
import json
import sys
import os

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "llama3.2:1b"

def convert_code(source_code, target_lang="typescript"):
    prompt = f"""
    You are an expert QA Automation Engineer.
    Task: Convert the provided Selenium Java code to Playwright {target_lang}.
    Rules:
    1. ONLY output the code. No explanations.
    2. Use async/await.
    3. Use page.locator() and standard Playwright assertions.

    Source Code:
    {source_code}
    """
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "options": {"temperature": 0}
    }
    
    try:
        response = requests.post(OLLAMA_URL, json=payload)
        response.raise_for_status()
        result = response.json()
        return result.get("response", "")
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python ollama_converter.py <file_path>")
        sys.exit(1)
        
    file_path = sys.argv[1]
    with open(file_path, "r") as f:
        code = f.read()
        
    converted = convert_code(code)
    print(converted)
