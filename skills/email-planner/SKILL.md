---
name: email-planner
description: >
  Read and classify unread Gmail/Google Workspace emails into action categories
  (URGENT, Action, Meeting, FYI). Use when the user wants to triage their inbox,
  check unread emails, classify emails by priority, get an email action summary,
  or mentions email planning, inbox management, or email organization.
---

# Email Planner

A skill that connects to a Gmail/Google Workspace inbox via IMAP, reads unread emails, and classifies them into action categories.

## How it works

This skill bundles a pre-built Python script (`scripts/email_planner.py`) that:
- Connects to `imap.gmail.com` over SSL (port 993)
- Fetches unread emails (or emails from the last N hours)
- Extracts: From, Subject, Date, Body
- Classifies each email as: **URGENT**, **Action**, **Meeting**, or **FYI**
- Prints a grouped summary to the terminal
- Optionally saves the summary to `email_actions.md`

The script uses only the Python standard library — no pip installs needed.

## Workflow

### Step 1: Check environment variables

Before asking the user anything, check if `EMAIL` and `EMAIL_PASSWORD` are already set in the environment. If both are present, skip to Step 3 and run the script immediately.

### Step 2: Ask for credentials (only if needed)

Ask the user for their Gmail address and app password in a single prompt:

> To connect to your Gmail inbox, I need two things:
>
> **1. Your email address** (e.g. `you@company.com`)
>
> **2. An app password** — get one here: https://myaccount.google.com/apppasswords
> - If 2-Step Verification isn't on yet, you'll need to enable it first
> - Name it anything (e.g. "Email Planner") → Generate → copy the 16-char password
>
> Paste them both below (e.g. `you@company.com xxxx xxxx xxxx xxxx`). Your password is never stored or logged.

### Step 3: Run the script

Run the bundled script with the credentials as environment variables:

```bash
EMAIL="user@example.com" EMAIL_PASSWORD="xxxxxxxxxxxxxxxx" python3 scripts/email_planner.py
```

**Flags:**
- `--hours N` — fetch emails from the last N hours instead of just unread
- `--save` — also write the summary to `email_actions.md`

If the user asked to check recent emails (e.g. "last 24 hours"), pass `--hours 24`. If they asked to save the results, pass `--save`.

### Step 4: Present results

Show the user the terminal output. If they want to save it and `--save` wasn't used, offer to re-run with `--save`.

## Error handling

- **Login failed**: Tell the user to check their email and app password. Direct them to https://myaccount.google.com/apppasswords again.
- **No emails found**: Let the user know there are no unread emails (or none in the time range). Offer to try `--hours` with a larger value.
- **Missing env vars**: The script will print an error. Ask the user for credentials as in Step 2.

## Security

- Never echo or log the password in plain text
- Never write the password to any file
- Pass credentials only via environment variables
- Remind the user that app passwords can be revoked anytime at https://myaccount.google.com/apppasswords
