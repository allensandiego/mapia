# Response body displays corrupted characters instead of JSON

labels: bug, ui, recommended-for-ai

## Issue
When making API requests, the response body displays garbled/corrupted text instead of properly formatted JSON.

## Observed Behavior
Response body shows corrupted characters like: `GRⱷGⅴ◆◆•◆DAℹ›)⅔=BBap ⅈ}◆;•◆◆◆◆◆◆. ◆bⰛ×Ⱂ◆❂◆yⅴ◆›◆'◆nⅧ◆I?`

## Expected Behavior
The response should display as properly formatted and readable JSON.

## Possible Root Cause
- Character encoding/decoding mismatch (UTF-8 issue)
- Font rendering problem
- Response parsing not properly decoding characters before display
- Charset handling in HTTP response

## Status
The API returns 200 OK with valid response, so the issue is in the client-side display/rendering layer.
