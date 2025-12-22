#!/usr/bin/env python3
"""
Script to fix deprecated withOpacity() calls in Flutter code
Replaces .withOpacity(value) with .withValues(alpha: value)
"""

import os
import re
from pathlib import Path

def fix_with_opacity(content):
    """
    Replace withOpacity(value) with withValues(alpha: value)
    Handles both decimal and variable values
    """
    # Pattern to match .withOpacity(0.5) or .withOpacity(variable)
    pattern = r'\.withOpacity\(([^)]+)\)'

    def replace_func(match):
        opacity_value = match.group(1).strip()
        return f'.withValues(alpha: {opacity_value})'

    return re.sub(pattern, replace_func, content)

def process_file(file_path):
    """Process a single Dart file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check if file contains withOpacity
        if '.withOpacity(' not in content:
            return 0

        # Fix the content
        new_content = fix_with_opacity(content)

        # Count replacements
        count = content.count('.withOpacity(')

        # Write back
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)

        return count
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return 0

def main():
    """Main function to process all Dart files"""
    lib_path = Path('lib')

    if not lib_path.exists():
        print("Error: lib directory not found!")
        return

    total_files = 0
    total_replacements = 0

    print("Fixing deprecated withOpacity() calls...")
    print("-" * 60)

    # Process all .dart files
    for dart_file in lib_path.rglob('*.dart'):
        count = process_file(dart_file)
        if count > 0:
            total_files += 1
            total_replacements += count
            print(f"[OK] {dart_file.relative_to(lib_path)}: {count} replacements")

    print("-" * 60)
    print(f"\nComplete!")
    print(f"Files modified: {total_files}")
    print(f"Total replacements: {total_replacements}")
    print("\nAll deprecated withOpacity() calls have been updated!")
    print("Run 'flutter analyze' to verify the changes.")

if __name__ == '__main__':
    main()
