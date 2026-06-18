---
name: email-planner
description: >
  Read and classify Gmail/Google Workspace emails from the last 24 hours into
  action categories (URGENT, Action, Meeting, FYI), spot items that need your
  attention, and draft reply emails. Use when the user wants to triage their inbox,
  check unread emails, classify emails by priority, get an email action summary,
  draft email replies, or mentions email planning, inbox management, or
  "what do I need to respond to".
---

# Email Planner

A skill that connects to a Gmail/Google Workspace inbox, reads recent emails, spots anything that needs action, and drafts replies.

## How it works

This skill bundles a pre-built Python script (`scripts/email_planner.py`) that:
- Connects to `imap.gmail.com` over SSL (port 993)
- Fetches emails from the last 24 hours (configurable with `--hours`)
- Extracts: From, Subject, Date, Body
- Classifies each email as: **URGENT**, **Action**, **Meeting**, or **FYI**
- Outputs structured JSON for the agent to analyze

The script uses only the Python standard library — no pip installs needed.

## Workflow

### Phase 1: Fetch emails

**Step 1: Check environment variables**

Before asking the user anything, check if `EMAIL` and `EMAIL_PASSWORD` are already set. If both are present, skip to running the script.

**Step 2: Ask for credentials (only if needed)**

Ask two separate questions using the question tool. Keep each question extremely short — one line only.

**Question 1:**
```
What's your Gmail address?
```

After the user answers, output these instructions as plain text (not a question):

```
To connect to your inbox, I need an app password.
Get one at: https://myaccount.google.com/apppasswords
(Enable 2-Step Verification first if needed. Name it anything → Generate → copy the 16-char password.)
```

**Question 2:**
```
Paste your app password:
```

Do not echo, log, or repeat the password back to the user. Do not add extra explanation to the questions themselves.

**Step 3: Run the script**

Run the bundled script with `--json` to get structured data:

```bash
EMAIL="user@example.com" EMAIL_PASSWORD="xxxxxxxxxxxxxxxx" python3 scripts/email_planner.py --json --hours 24
```

If the user specified a different time range (e.g. "last 48 hours"), pass `--hours 48`.

Parse the JSON output. Each email object has: `from`, `subject`, `date`, `body`, `category`.

### Phase 2: Spot action items

Analyze the fetched emails and identify what needs the user's attention:

1. **URGENT emails** — these always need a response or immediate action. For each one, determine:
   - What specifically needs to be done
   - Who needs a response
   - Any deadlines or time pressure mentioned

2. **Action emails** — review each one and determine:
   - What the sender is asking for
   - Whether a reply is needed or just a task to complete
   - Any deadlines mentioned

3. **Meeting emails** — check for:
   - RSVPs needed
   - Scheduling conflicts
   - Prep materials mentioned

4. **FYI emails** — scan briefly for anything actionable that the keyword classifier might have missed. If something looks important despite being classified as FYI, flag it.

Skip categories that have zero emails — don't mention them.

### Phase 3: Suggest actions and draft replies

For each email that needs attention, present:

1. **The email** — one-line summary (from + subject)
2. **Suggested action** — what the user should do (e.g. "Reply confirming attendance", "Review the attached document by Friday")
3. **Draft reply** — a ready-to-send email draft that the user can copy, edit, or send as-is

Drafts should be:
- Short and professional
- Match the tone of the original email (formal → formal, casual → casual)
- Address the specific ask in the email
- Include placeholders in brackets for things the user needs to fill in (e.g. `[date]`, `[your answer]`)

**Output format:**

```
📬 Found 12 emails in the last 24 hours.

🔴 URGENT (1)

  1. Server outage — ops@company.com
     → Action: Reply confirming you're investigating
     → Draft:
       "Hi team, I'm on it. Investigating the root cause now
        and will update within the hour."

🟡 Action (2)

  2. Q3 budget proposal — finance@company.com
     → Action: Review the proposal and reply with feedback by [date]
     → Draft:
       "Hi, thanks for sending this over. I'll review the proposal
        and get back to you with feedback by [date]."

  3. Client follow-up — sales@company.com
     → Action: Reply to confirm next steps
     → Draft:
       "Hi [name], thanks for the call earlier. To confirm, our
        next steps are: [list steps]. Let me know if I missed anything."

🔵 Meeting (1)

  4. Team standup Tuesday — calendar@company.com
     → Action: Confirm attendance (no reply needed if auto-accepted)

⚪ FYI (8) — no action needed
```

After presenting the results, offer to:
- Save all drafts to a file (`email_drafts.md`)
- Adjust any draft's tone or content
- Re-run with a different time range

## Error handling

- **Login failed**: Tell the user to check their email and app password. Direct them to https://myaccount.google.com/apppasswords again.
- **No emails found**: Let the user know there are no emails in the last 24 hours. Offer to try `--hours` with a larger value.
- **Missing env vars**: The script will print an error. Ask the user for credentials as in Phase 1 Step 2.

## Security

- Never echo or log the password in plain text
- Never write the password to any file
- Pass credentials only via environment variables
- Remind the user that app passwords can be revoked anytime at https://myaccount.google.com/apppasswords
