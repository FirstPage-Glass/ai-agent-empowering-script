#!/usr/bin/env python3
import argparse
import email
import imaplib
import json
import os
import sys
from datetime import datetime, timedelta, timezone
from email.header import decode_header
from email.utils import parsedate_to_datetime
from html.parser import HTMLParser


IMAP_SERVER = "imap.gmail.com"
IMAP_PORT = 993

URGENT_KEYWORDS = ["urgent", "asap", "❗", "critical", "immediately"]
ACTION_KEYWORDS = ["please review", "could you", "todo", "follow up", "action required", "please do"]
MEETING_KEYWORDS = ["meeting", "call", "schedule", "invite", "zoom", "google meet", "calendar"]


class HTMLStripper(HTMLParser):
    def __init__(self):
        super().__init__()
        self.parts = []

    def handle_data(self, data):
        self.parts.append(data)

    def get_text(self):
        return "".join(self.parts).strip()


def strip_html(html_str):
    stripper = HTMLStripper()
    stripper.feed(html_str)
    return stripper.get_text()


def decode_mime_header(header_val):
    if header_val is None:
        return ""
    parts = decode_header(header_val)
    decoded = []
    for part, charset in parts:
        if isinstance(part, bytes):
            decoded.append(part.decode(charset or "utf-8", errors="replace"))
        else:
            decoded.append(part)
    return " ".join(decoded)


def get_body(msg):
    plain_body = None
    html_body = None
    if msg.is_multipart():
        for part in msg.walk():
            content_type = part.get_content_type()
            disposition = str(part.get("Content-Disposition", ""))
            if "attachment" in disposition:
                continue
            payload = part.get_payload(decode=True)
            if payload is None:
                continue
            charset = part.get_content_charset() or "utf-8"
            text = payload.decode(charset, errors="replace")
            if content_type == "text/plain":
                plain_body = text
            elif content_type == "text/html":
                html_body = text
    else:
        payload = msg.get_payload(decode=True)
        if payload:
            charset = msg.get_content_charset() or "utf-8"
            text = payload.decode(charset, errors="replace")
            if msg.get_content_type() == "text/html":
                html_body = text
            else:
                plain_body = text
    if plain_body:
        return plain_body.strip()
    if html_body:
        return strip_html(html_body)
    return ""


def classify(subject, body):
    text = (subject + " " + body).lower()
    for kw in URGENT_KEYWORDS:
        if kw in text:
            return "URGENT"
    for kw in ACTION_KEYWORDS:
        if kw in text:
            return "Action"
    for kw in MEETING_KEYWORDS:
        if kw in text:
            return "Meeting"
    return "FYI"


def parse_date(date_str):
    if not date_str:
        return None
    try:
        return parsedate_to_datetime(date_str)
    except Exception:
        return None


def fetch_emails(email_addr, password, hours=24):
    mail = imaplib.IMAP4_SSL(IMAP_SERVER, IMAP_PORT)
    mail.login(email_addr, password)
    mail.select("INBOX")

    since_date = (datetime.now(timezone.utc) - timedelta(hours=hours)).strftime("%d-%b-%Y")
    status, data = mail.search(None, f'(SINCE "{since_date}")')

    if status != "OK":
        mail.logout()
        return []

    msg_ids = data[0].split()
    if not msg_ids:
        mail.logout()
        return []

    emails = []
    for mid in msg_ids:
        status, msg_data = mail.fetch(mid, "(RFC822)")
        if status != "OK":
            continue
        raw = msg_data[0][1]
        msg = email.message_from_bytes(raw)
        subj = decode_mime_header(msg.get("Subject"))
        frm = decode_mime_header(msg.get("From"))
        date_str = msg.get("Date", "")
        body = get_body(msg)
        category = classify(subj, body)
        emails.append({
            "from": frm,
            "subject": subj,
            "date": date_str,
            "body": body[:500],
            "category": category,
        })

    mail.logout()
    return emails


def format_summary(emails):
    categories = {"URGENT": [], "Action": [], "Meeting": [], "FYI": []}
    for e in emails:
        categories[e["category"]].append(e)

    lines = []
    lines.append("# Email Action Summary")
    lines.append("")
    lines.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    lines.append(f"Total emails: {len(emails)}")
    lines.append("")

    for cat in ["URGENT", "Action", "Meeting", "FYI"]:
        items = categories[cat]
        icon = {"URGENT": "🔴", "Action": "🟡", "Meeting": "🔵", "FYI": "⚪"}[cat]
        lines.append(f"## {icon} {cat} ({len(items)})")
        lines.append("")
        if not items:
            lines.append("No emails in this category.")
            lines.append("")
            continue
        for e in items:
            lines.append(f"**From:** {e['from']}")
            lines.append(f"**Subject:** {e['subject']}")
            lines.append(f"**Date:** {e['date']}")
            preview = e["body"][:200].replace("\n", " ")
            if preview:
                lines.append(f"**Preview:** {preview}")
            lines.append("")

    return "\n".join(lines)


def print_summary(emails):
    categories = {"URGENT": [], "Action": [], "Meeting": [], "FYI": []}
    for e in emails:
        categories[e["category"]].append(e)

    print(f"\n{'='*60}")
    print(f"  Email Action Summary — {len(emails)} emails")
    print(f"{'='*60}")

    for cat in ["URGENT", "Action", "Meeting", "FYI"]:
        items = categories[cat]
        icon = {"URGENT": "🔴", "Action": "🟡", "Meeting": "🔵", "FYI": "⚪"}[cat]
        print(f"\n  {icon} {cat} ({len(items)})")
        print(f"  {'-'*40}")
        if not items:
            print("    (none)")
            continue
        for e in items:
            print(f"    {e['subject']}")
            print(f"      From: {e['from']}")
            print(f"      Date: {e['date']}")

    print(f"\n{'='*60}\n")


def main():
    parser = argparse.ArgumentParser(description="Classify emails into action categories")
    parser.add_argument("--hours", type=int, default=24, help="Fetch emails from the last N hours (default: 24)")
    parser.add_argument("--json", action="store_true", help="Output as JSON for agent processing")
    parser.add_argument("--save", action="store_true", help="Save output to email_actions.md")
    args = parser.parse_args()

    email_addr = os.environ.get("EMAIL")
    password = os.environ.get("EMAIL_PASSWORD")

    if not email_addr or not password:
        print("Error: Set EMAIL and EMAIL_PASSWORD environment variables.", file=sys.stderr)
        print("  export EMAIL=\"you@example.com\"", file=sys.stderr)
        print("  export EMAIL_PASSWORD=\"your-app-password\"", file=sys.stderr)
        sys.exit(1)

    if not args.json:
        print(f"Connecting to {IMAP_SERVER}...")
    try:
        emails = fetch_emails(email_addr, password, args.hours)
    except imaplib.IMAP4.error as e:
        print(f"Login failed: {e}", file=sys.stderr)
        print("Check your email address and app password.", file=sys.stderr)
        print("Get an app password at: https://myaccount.google.com/apppasswords", file=sys.stderr)
        sys.exit(1)

    if not emails:
        if args.json:
            print("[]")
        else:
            print("No emails found.")
        return

    if args.json:
        print(json.dumps(emails, indent=2))
    else:
        print_summary(emails)

    if args.save:
        md = format_summary(emails)
        with open("email_actions.md", "w") as f:
            f.write(md)
        print("Saved to email_actions.md")


if __name__ == "__main__":
    main()
