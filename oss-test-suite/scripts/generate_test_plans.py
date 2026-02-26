#!/usr/bin/env python3
"""
Generate test plans from natural language specs using AI.
This script reads spec files and generates pytest-compatible test cases.
"""

import os
import sys
from openai import OpenAI

# Configuration
BASE_URL = os.getenv("VIBEPROXY_BASE_URL", "http://localhost:8318/v1")
API_KEY = os.getenv("VIBEPROXY_API_KEY", "local-token")
MODEL = os.getenv("VIBEPROXY_MODEL", "zai/glm-4.7")
SPECS_DIR = "specs"
OUTPUT_DIR = "output/test-plans"

client = OpenAI(base_url=BASE_URL, api_key=API_KEY)

def generate_test_plan(spec_text: str) -> str:
    """Generate a test plan from a natural language spec."""
    prompt = f"""
You are an expert QA engineer. Given this specification, generate a comprehensive test plan:

Specification:
{spec_text}

Generate the test plan in the following format:
1. Test Case ID
2. Description
3. Preconditions
4. Test Steps
5. Expected Results
6. Priority (High/Medium/Low)
"""

    response = client.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "system", "content": "You are an expert QA engineer."},
            {"role": "user", "content": prompt}
        ],
        temperature=0.3
    )

    return response.choices[0].message.content

def main():
    """Main function to generate test plans from specs."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    spec_files = [f for f in os.listdir(SPECS_DIR) if f.endswith(".txt")]

    for spec_file in spec_files:
        spec_path = os.path.join(SPECS_DIR, spec_file)
        output_path = os.path.join(OUTPUT_DIR, spec_file.replace(".txt", "_plan.md"))

        with open(spec_path, "r") as f:
            spec_text = f.read()

        print(f"Generating test plan for {spec_file}...")
        plan = generate_test_plan(spec_text)

        with open(output_path, "w") as f:
            f.write(f"# Test Plan: {spec_file}\n\n")
            f.write(f"## Specification\n\n```\n{spec_text}\n```\n\n")
            f.write(f"## AI-Generated Test Plan\n\n{plan}\n")

        print(f"✅ Saved to {output_path}")

    print(f"\n🎉 Generated {len(spec_files)} test plans!")

if __name__ == "__main__":
    main()
