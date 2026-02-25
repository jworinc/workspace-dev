#!/usr/bin/env python3
"""
Heuristic Aside Detection for GTD System
Detects tangential items during conversation and batches them for confirmation
"""

import re
import sys
from typing import List, Tuple

# Trigger phrases (indicates tangential topic)
TRIGGER_PHRASES = [
    r"\balso\b",
    r"\boh\b",
    r"\bby the way\b",
    r"\bby the way\b",
    r"\breminds me of\b",
    r"\bspeaking of\b",
    r"\bshould look into\b",
    r"\bcould explore\b",
    r"\bmight want to\b",
    r"\bwe should\b",
    r"\bon a side note\b",
    r"\btangentially\b",
    r"\bon a related note\b",
    r"\bwhile we're at it\b",
    r"\bwhile i'm thinking\b",
    r"\bidea:\b",
    r"\bthought:\b",
]

# Context signals (indicates non-immediate action)
CONTEXT_SIGNALS = [
    r"\bcould\b",
    r"\bmight\b",
    r"\bwould\b",
    r"\bshould\b",
    r"\bconsider\b",
    r"\bthink about\b",
    r"\blook into\b",
]

# Ignore patterns (false positives)
IGNORE_PATTERNS = [
    r"\balso\b.*?(but|however|although)",  # "also but..." = clarification, not aside
    r"\bspeaking of.*?we were\b",  # "speaking of what we were doing" = continuation
]


def detect_asides(text: str) -> List[Tuple[str, str]]:
    """Detect potential asides in text"""
    asides = []
    sentences = re.split(r'[.!?]+', text)
    
    for sentence in sentences:
        sentence = sentence.strip()
        if not sentence:
            continue
        
        # Check for ignore patterns
        if any(re.search(pattern, sentence, re.IGNORECASE) for pattern in IGNORE_PATTERNS):
            continue
        
        # Check for trigger phrases
        for trigger in TRIGGER_PHRASES:
            if re.search(trigger, sentence, re.IGNORECASE):
                # Infer type
                aside_type = infer_aside_type(sentence)
                asides.append((sentence, aside_type))
                break  # One trigger per sentence
    
    return asides


def infer_aside_type(sentence: str) -> str:
    """Infer aside type (defer vs later)"""
    # Check for project context
    if re.search(r'\bP\d+\b', sentence):
        return "defer (project)"
    
    # Check for immediate action words
    immediate = [
        r"\bneed to\b",
        r"\bmust\b",
        r"\bhave to\b",
        r"\bstart\b",
        r"\bbegin\b",
    ]
    
    if any(re.search(pattern, sentence, re.IGNORECASE) for pattern in immediate):
        return "defer (project)"
    
    # Default: later (standalone idea)
    return "later (standalone)"


def format_aside_prompt(asides: List[Tuple[str, str]]) -> str:
    """Format asides for end-of-turn prompt"""
    if not asides:
        return ""
    
    prompt = "\n📋 Detected Potential Asides:\n"
    
    for i, (sentence, aside_type) in enumerate(asides, 1):
        prompt += f"{i}. \"{sentence}\"\n"
        prompt += f"   → Type: {aside_type}\n"
    
    prompt += "\nActions:\n"
    prompt += "   - Type 'y' to capture all\n"
    prompt += "   - Type 'n' to skip all\n"
    prompt += "   - Type 'edit' to modify before capture\n"
    prompt += "   - Type '1 only' to capture only item 1\n"
    prompt += "   - Type '2 to P003' to change item 2 destination\n"
    prompt += "   - Type 'skip' to skip all\n"
    
    return prompt


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("❌ Usage: heuristic_asides.py [text]")
        return
    
    text = " ".join(sys.argv[1:])
    asides = detect_asides(text)
    
    if asides:
        prompt = format_aside_prompt(asides)
        print(prompt)
        return
    else:
        print("✅ No asides detected")


if __name__ == "__main__":
    main()
