#!/usr/bin/env python3
"""
Create GitHub issues from markdown files.

Usage:
    python create_github_issue.py <markdown_file> [--token TOKEN] [--repo OWNER/REPO]

Environment variables:
    GITHUB_PERSONAL_ACCESS_TOKEN - GitHub API token
    GITHUB_REPO - Default repo in format OWNER/REPO
"""

import os
import sys
import re
import base64
import argparse
import json
import requests
from pathlib import Path


def parse_markdown_issue(md_file):
    """
    Parse markdown file into GitHub issue components.
    
    Expected format:
    # Issue Title
    
    labels: bug, ui, recommended-for-ai
    
    Issue body content here...
    ![alt text](image.png)
    """
    with open(md_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    lines = content.split('\n')
    title = None
    labels = []
    body_lines = []
    in_body = False
    md_dir = Path(md_file).parent
    
    for line in lines:
        # Extract title from first H1
        if line.startswith('# ') and title is None:
            title = line[2:].strip()
            in_body = True
            continue
        
        # Extract labels if present
        if line.startswith('labels:'):
            labels_str = line.split(':', 1)[1].strip()
            labels = [label.strip() for label in labels_str.split(',')]
            continue
        
        # Skip empty lines before body starts
        if not in_body and not line.strip():
            continue
        if not in_body and line.strip():
            in_body = True
        
        if in_body:
            body_lines.append(line)
    
    body = '\n'.join(body_lines).strip()
    
    # Process images in body
    body = process_images(body, md_dir)
    
    if not title:
        raise ValueError("Markdown file must start with a level 1 heading (# Title)")
    
    return {
        'title': title,
        'body': body,
        'labels': labels
    }


def process_images(body, base_dir):
    """
    Process images in markdown body.
    Converts local image paths to embedded base64 or leaves URLs as-is.
    """
    def replace_image(match):
        alt_text = match.group(1)
        image_path = match.group(2)
        
        # Skip URLs
        if image_path.startswith('http://') or image_path.startswith('https://'):
            return match.group(0)
        
        # Process local files
        full_path = base_dir / image_path
        if full_path.exists():
            with open(full_path, 'rb') as f:
                image_data = base64.b64encode(f.read()).decode('utf-8')
            
            # Determine MIME type from extension
            ext = full_path.suffix.lower()
            mime_types = {
                '.png': 'image/png',
                '.jpg': 'image/jpeg',
                '.jpeg': 'image/jpeg',
                '.gif': 'image/gif',
                '.webp': 'image/webp',
            }
            mime_type = mime_types.get(ext, 'application/octet-stream')
            
            return f'![{alt_text}](data:{mime_type};base64,{image_data})'
        else:
            print(f"Warning: Image not found: {full_path}", file=sys.stderr)
            return match.group(0)
    
    # Replace markdown image syntax
    return re.sub(r'!\[([^\]]*)\]\(([^)]+)\)', replace_image, body)


def create_github_issue(title, body, labels, repo, token):
    """
    Create a GitHub issue via API.
    
    Args:
        title: Issue title
        body: Issue body (markdown)
        labels: List of label strings
        repo: Repository in format OWNER/REPO
        token: GitHub API token
    """
    if '/' not in repo:
        raise ValueError(f"Invalid repo format: {repo}. Expected OWNER/REPO")
    
    owner, repo_name = repo.split('/', 1)
    
    url = f'https://api.github.com/repos/{owner}/{repo_name}/issues'
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
    }
    
    payload = {
        'title': title,
        'body': body,
    }
    
    if labels:
        payload['labels'] = labels
    
    response = requests.post(url, json=payload, headers=headers)
    
    if response.status_code == 201:
        issue_data = response.json()
        return {
            'number': issue_data['number'],
            'url': issue_data['html_url'],
            'status': 'success'
        }
    else:
        return {
            'status': 'error',
            'error': response.json().get('message', 'Unknown error'),
            'status_code': response.status_code
        }


def main():
    parser = argparse.ArgumentParser(
        description='Create GitHub issues from markdown files'
    )
    parser.add_argument(
        'markdown_file',
        help='Path to markdown file containing issue details'
    )
    parser.add_argument(
        '--token',
        help='GitHub API token (or use GITHUB_PERSONAL_ACCESS_TOKEN env var)',
        default=os.getenv('GITHUB_PERSONAL_ACCESS_TOKEN')
    )
    parser.add_argument(
        '--repo',
        help='GitHub repository (OWNER/REPO format, or use GITHUB_REPO env var)',
        default=os.getenv('GITHUB_REPO')
    )
    
    args = parser.parse_args()
    
    # Validate inputs
    if not os.path.exists(args.markdown_file):
        print(f"Error: File not found: {args.markdown_file}", file=sys.stderr)
        sys.exit(1)
    
    if not args.token:
        print("Error: GitHub token required. Set GITHUB_PERSONAL_ACCESS_TOKEN or use --token", file=sys.stderr)
        sys.exit(1)
    
    if not args.repo:
        print("Error: Repository required. Set GITHUB_REPO or use --repo", file=sys.stderr)
        sys.exit(1)
    
    try:
        # Parse markdown
        print(f"Parsing {args.markdown_file}...")
        issue_data = parse_markdown_issue(args.markdown_file)
        
        print(f"Title: {issue_data['title']}")
        print(f"Labels: {', '.join(issue_data['labels']) if issue_data['labels'] else 'None'}")
        print(f"Body length: {len(issue_data['body'])} characters")
        
        # Create issue
        print(f"\nCreating issue in {args.repo}...")
        result = create_github_issue(
            issue_data['title'],
            issue_data['body'],
            issue_data['labels'],
            args.repo,
            args.token
        )
        
        if result['status'] == 'success':
            print(f"✓ Issue created successfully!")
            print(f"  Issue #{result['number']}: {result['url']}")
            return 0
        else:
            print(f"✗ Error creating issue: {result['error']}", file=sys.stderr)
            return 1
            
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
