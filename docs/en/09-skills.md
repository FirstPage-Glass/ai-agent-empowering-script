# Part 9: Skills 🧩

> Skills are reusable instruction packs that turn your AI agent into a specialist. Drop one into your project and the agent picks it up automatically.

---

## What are Skills? 🤔

Think of skills like **job descriptions** for your AI agent.

Without a skill, every time you ask the agent to do something, you have to explain everything from scratch. With a skill, you write the instructions once — and the agent remembers them forever.

**Example:** Instead of explaining every day:
```
Connect to my Gmail, read unread emails, classify them by urgency...
```

You install the **email-planner** skill once, and next time you just say:
```
Check my inbox
```

The agent knows exactly what to do.

---

## How Skills Work ⚙️

A skill is just a folder with two things:

```
email-planner/
├── SKILL.md          ← Instructions for the agent
└── scripts/
    └── email_planner.py  ← Pre-built script (optional)
```

**`SKILL.md`** tells the agent:
- 🏷️ **Name** — what the skill is called
- 📝 **Description** — when to use it (this is how the agent decides to activate the skill)
- 📋 **Instructions** — step-by-step what to do

**`scripts/`** (optional) contains pre-built code the agent runs directly — no code generation needed.

> 💡 **Tip:** The agent reads the description to decide if a skill matches your request. A good description = the skill triggers at the right time.

---

## Skill Anatomy 🔬

Every `SKILL.md` starts with a YAML frontmatter block:

```yaml
---
name: email-planner
description: >
  Read and classify unread Gmail emails into action categories.
  Use when the user wants to triage their inbox or check unread emails.
---
```

Then comes the markdown body with detailed instructions:

```markdown
# Email Planner

## Workflow

### Step 1: Check environment variables
...

### Step 2: Ask for credentials
...

### Step 3: Run the script
...
```

---

## Walkthrough: Email Planner Skill 📬

Let's walk through a real skill that ships with this project.

### What it does

The **email-planner** skill does three things:

1. 📬 **Fetches** emails from the last 24 hours (configurable)
2. 🔍 **Spots** anything that needs your attention
3. ✍️ **Drafts** reply emails ready for you to send

It classifies emails into four categories:

| Category | Icon | Triggers on |
|---|---|---|
| URGENT | 🔴 | "urgent", "asap", "critical" |
| Action | 🟡 | "please review", "could you", "follow up" |
| Meeting | 🔵 | "meeting", "call", "schedule", "zoom" |
| FYI | ⚪ | Everything else |

### How to use it

The skill is **auto-installed** when you run the install script. Just open opencode and say:

```
Check my inbox
```

Or:

```
What emails do I need to respond to?
```

The agent will:
1. 📧 Ask for your email and app password (one time)
2. ⚡ Fetch and classify your emails
3. 🎯 Spot what needs action
4. ✍️ Draft replies for each action item

### Getting an app password

The skill needs an **app password** to connect to Gmail (not your regular password):

1. Go to https://myaccount.google.com/apppasswords
2. Enable 2-Step Verification if prompted
3. Name it "Email Planner" → Generate
4. Copy the 16-character password

> ⚠️ Your app password is only used to connect to your inbox. It is never stored, logged, or echoed by the agent.

### Example output

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

---

## Create Your Own Skill 🛠️

Making a skill is simple. Here's a template:

### Step 1: Create the folder

```bash
mkdir -p skills/my-skill/scripts
```

### Step 2: Write SKILL.md

```yaml
---
name: my-skill
description: >
  What the skill does. Use when the user asks to...
  Also triggers when they mention...
---

# My Skill

## Workflow

### Step 1: Ask the user for...
### Step 2: Run the script...
### Step 3: Present results...
```

### Step 3: Add a script (optional)

If your skill needs to run code, put it in `scripts/`:

```
skills/my-skill/
├── SKILL.md
└── scripts/
    └── my_script.py
```

The agent will run it directly — no code generation needed.

### Step 4: Test it

Open your project in OpenCode and ask something that matches your skill's description. The agent should pick it up automatically.

> 💡 **Tip:** Make your description "pushy" — include multiple ways a user might phrase the request. This helps the agent trigger the skill more reliably.

---

## Tips for Good Skills ✨

**1️⃣ Be specific in the description** 🎯
- ❌ "Does stuff with data"
- ✅ "Reads CSV files, calculates totals, and generates a summary report. Use when the user mentions data analysis, CSV processing, or report generation."

**2️⃣ Pre-build scripts when possible** 📦
- If the agent always writes the same helper script, bundle it in `scripts/` instead
- Pre-built scripts are faster and more reliable than generated code

**3️⃣ Handle errors gracefully** 🛡️
- Tell the agent what to do when things go wrong
- E.g., "If login fails, direct the user to regenerate their app password"

**4️⃣ Keep instructions lean** ✂️
- Explain the **why** instead of rigid step-by-step rules
- The agent is smart — give it context, not a straitjacket

**5️⃣ Test with real prompts** 🧪
- Try 2-3 different ways of asking for the same thing
- "Check my inbox" / "What emails do I have?" / "Triage my mail"

---

## Where to Put Skills 📁

**User scope** (available in every project) — this is where the install script puts them:

```
~/.config/opencode/skills/
├── email-planner/
│   ├── SKILL.md
│   └── scripts/
│       └── email_planner.py
└── my-other-skill/
    └── SKILL.md
```

**Project scope** (available only in that project):

```
my-project/
├── skills/
│   └── my-skill/
│       └── SKILL.md
├── src/
└── ...
```

The agent automatically discovers skills in both locations.

> 💡 **Tip:** User-scope skills are great for personal tools you use everywhere (like the email planner). Project-scope skills are better for project-specific workflows.
