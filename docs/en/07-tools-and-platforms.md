# Part 7: SEO Tools Ecosystem for AI Agents 🛠️

> OpenCode's capabilities can be greatly extended through various tools. Below are the most commonly used tools for an SEO agency, organized by category.
>
> **What is MCP?** MCP (Model Context Protocol) is the standard way AI agents connect to external tools — think of it as a "USB port for AI." Once a tool supports MCP, your agent can use it directly without any custom integration. Many tools below have MCP servers available.

---

## 🔍 SERP Research

### 1. Serper.dev

| Item | Details |
|---|---|
| What it is | Google Search API designed for AI, returns structured SERP results |
| Cost | 2,500 queries/month free, then $0.30/1k queries |
| How to use | Agent can search Google in real-time, retrieve ranking data, Featured Snippets, People Also Ask |
| SEO use case | "Search for the SERP of 'best SEO tools' and list the top 10 results with titles and URLs" |

### 2. Brave Search

| Item | Details |
|---|---|
| What it is | Brave's independent search index, not dependent on Google |
| Cost | 2,000 queries/month free (non-commercial), then $5/1k queries |
| How to use | Agent uses an independent search engine for keyword research, not restricted by Google API limits |
| SEO use case | "Use Brave Search to find the latest AI SEO trend articles" |

### 3. Tavily

| Item | Details |
|---|---|
| What it is | Search engine designed specifically for AI Agents, supports content extraction |
| Cost | 1,000 queries/month free |
| How to use | Agent searches and automatically extracts webpage content, ideal for competitor research |
| SEO use case | "Research competitor.com and find their recent content strategy" |

### 4. Exa

| Item | Details |
|---|---|
| What it is | Neural semantic search engine using Link Prediction to understand search intent |
| Cost | 1,000 queries/month free |
| How to use | Agent finds semantically similar content, performs content gap analysis |
| SEO use case | "Find content similar to our website but ranking higher than us" |

---

## 🕷️ Web Crawling & Technical SEO

### 5. Firecrawl

| Item | Details |
|---|---|
| What it is | Full-site crawler that converts to Markdown, supports structured data extraction |
| Cost | Free tier available, paid from $19/month |
| How to use | Agent crawls competitor websites for full content analysis |
| SEO use case | "Crawl competitor.com and analyze their content structure and heading strategy" |

### 6. Apify

| Item | Details |
|---|---|
| What it is | Web scraping and automation platform with a large library of pre-built Actors |
| Cost | Free tier available, paid based on usage |
| How to use | Agent automates crawling of SERPs, product pages, reviews, social media |
| SEO use case | "Find Google Maps local business data for this keyword" |

### 7. Jina AI

| Item | Details |
|---|---|
| What it is | Prefix any URL with `r.jina.ai/` to instantly convert to Markdown — zero setup |
| Cost | Free tier available |
| How to use | Agent quickly extracts single webpage content for instant analysis |
| SEO use case | "Read this webpage and analyze its meta description and heading tags" |

### 8. Screaming Frog

| Item | Details |
|---|---|
| What it is | Technical SEO crawler, analyzes site architecture and SEO issues |
| Cost | Free version crawls up to 500 URLs, paid £199/year |
| How to use | Agent analyzes site architecture, redirect chains, broken links, meta tags |
| SEO use case | "Analyze this site's redirect chain and find any redirect loops" |

---

## 📊 Google Ecosystem

### 9. gws (Google Workspace CLI) ✅ Installed

| Item | Details |
|---|---|
| What it is | CLI tool for managing Gmail, Google Drive, Calendar, Sheets |
| Cost | Free with Google Workspace account |
| How to use | Agent directly reads/writes Google Sheets, sends/receives email, manages cloud storage |
| SEO use case | "Organize this keyword report and save it to Google Sheets" |

### 10. gcloud (Google Cloud CLI) ✅ Installed

| Item | Details |
|---|---|
| What it is | Google Cloud command-line tool |
| Cost | Free with GCP account |
| How to use | Agent operates Search Console API, GA4 API, Cloud Functions |
| SEO use case | "Download the last 3 months of search query data from Search Console" |

### 11. Google Search Console API

| Item | Details |
|---|---|
| What it is | Google Search Console API interface |
| Cost | Free |
| How to use | Agent queries clicks, impressions, average position, keyword performance |
| SEO use case | "Find keywords with high impressions but low CTR over the past 30 days" |

### 12. Google Analytics Data API

| Item | Details |
|---|---|
| What it is | Google Analytics 4 API interface |
| Cost | Free |
| How to use | Agent analyzes traffic sources, user behavior, conversion rates, page performance |
| SEO use case | "Analyze which landing pages have the highest bounce rate and give improvement suggestions" |

---

## 📈 SEO Platforms

### 13. Ahrefs API

| Item | Details |
|---|---|
| What it is | Ahrefs API, accessing backlinks, keywords, and content data |
| Cost | Requires Ahrefs paid plan, API billed separately |
| How to use | Agent analyzes backlink profiles, competitor domains, keyword difficulty |
| SEO use case | "Analyze competitor.com's top 20 backlinks and understand their link building strategy" |

### 14. Semrush API

| Item | Details |
|---|---|
| What it is | Semrush API, accessing SEO suite data |
| Cost | Requires Semrush paid plan |
| How to use | Agent performs keyword difficulty analysis, site audits, competitor tracking |
| SEO use case | "Run a full site audit on this website and list all technical SEO errors" |

### 15. Frase

| Item | Details |
|---|---|
| What it is | Full-workflow AI SEO Agent: research, writing, optimization, monitoring, correction |
| Cost | From $15/month (Solo), $39/month (Starter) |
| How to use | Agent automates content research, SERP analysis, content generation, rank monitoring |
| SEO use case | "Use Frase to research the topic 'AI SEO tools' and generate a content brief" |

### 16. Surfer SEO

| Item | Details |
|---|---|
| What it is | Content optimization tool using NLP to score content in real-time |
| Cost | From $49/month (billed annually) |
| How to use | Agent analyzes SERP competitor content structure and provides optimization suggestions |
| SEO use case | "Analyze this article against the top 10 SERP results and suggest entity density and heading structure improvements" |

---

## 📝 Content Optimization & Quality Control

### 17. Clearscope

| Item | Details |
|---|---|
| What it is | Content scoring platform analyzing topic coverage and entity usage |
| Cost | From $129/month |
| How to use | Agent analyzes whether content covers enough topic entities, gives A-F grade |
| SEO use case | "Use Clearscope to analyze this article and give a topic coverage report" |

### 18. Originality.ai

| Item | Details |
|---|---|
| What it is | AI content detection tool, checks if articles are AI-generated |
| Cost | From $14.95/month |
| How to use | Agent detects AI generation probability in content, ensures quality standards |
| SEO use case | "Check the AI generation score for these 10 articles and flag high-risk ones" |

### 19. Grammarly

| Item | Details |
|---|---|
| What it is | Writing quality checker |
| Cost | Free version is sufficient, paid from $12/month |
| How to use | Agent checks grammar, tone, readability, and clarity |
| SEO use case | "Check this blog post's readability score and suggest tone consistency improvements" |

### 20. Copyscape

| Item | Details |
|---|---|
| What it is | Plagiarism detection tool, checks for duplicate content |
| Cost | $0.03 per check |
| How to use | Agent checks if content is original, avoids duplicate content issues |
| SEO use case | "Check this new article for originality and ensure it doesn't plagiarize other sites" |

---

## 📊 Rank Tracking & Monitoring

### 21. AccuRanker

| Item | Details |
|---|---|
| What it is | Real-time rank tracking tool with fast update speed |
| Cost | Based on number of keywords |
| How to use | Agent monitors keyword ranking changes, generates real-time reports |
| SEO use case | "Check today's ranking changes for this batch of keywords and highlight significant movements" |

### 22. Nightwatch

| Item | Details |
|---|---|
| What it is | Multi-dimensional rank tracking, supports region, device, and language |
| Cost | Based on number of keywords |
| How to use | Agent tracks ranking differences across regions, devices, and languages |
| SEO use case | "Compare desktop vs mobile rankings for this batch of keywords" |

### 23. Pro Rank Tracker

| Item | Details |
|---|---|
| What it is | Cost-effective rank tracking tool |
| Cost | Based on number of keywords |
| How to use | Agent monitors thousands of keyword rankings daily |
| SEO use case | "Monitor these 500 keywords daily and generate a weekly ranking report" |

---

## ⚡ Site Speed & Core Web Vitals

### 24. Google PageSpeed Insights API

| Item | Details |
|---|---|
| What it is | Official Google site performance analysis API |
| Cost | Free |
| How to use | Agent checks LCP, CLS, INP, and other Core Web Vitals metrics |
| SEO use case | "Check Core Web Vitals for these 10 pages and list the ones needing improvement" |

### 25. Lighthouse

| Item | Details |
|---|---|
| What it is | Google's open-source website auditing tool |
| Cost | Free |
| How to use | Agent automates audits for SEO, performance, accessibility, best practices |
| SEO use case | "Run a full Lighthouse audit on this website and give improvement recommendations" |

### 26. WebPageTest

| Item | Details |
|---|---|
| What it is | Deep website performance testing, supports multiple regions and devices |
| Cost | Free version is sufficient |
| How to use | Agent tests website load speed across multiple regions and devices |
| SEO use case | "Compare this webpage's load speed in the US vs Asia" |

---

## 🤖 AI Search Optimization

### 27. Perplexity

| Item | Details |
|---|---|
| What it is | AI search engine with source citations |
| Cost | Free version is sufficient, Pro $20/month |
| How to use | Agent monitors brand visibility in AI Search, researches competitors |
| SEO use case | "Research how our brand appears in Perplexity and see if we're being cited" |