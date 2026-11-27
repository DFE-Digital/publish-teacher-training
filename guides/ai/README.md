# AI guidance

Shared guidance for people using AI coding tools on this repository, and for the agents themselves. It starts small on purpose and will grow as the team agrees more.

## What's here

| File | Purpose |
|:--|:--|
| [/AGENTS.md](/AGENTS.md) | Entry point for every agent: the service, commands, conventions and limits |
| [/CLAUDE.md](/CLAUDE.md) | Points Claude Code at `AGENTS.md` |
| [review-checklist.md](review-checklist.md) | What to check when reviewing a change, and how to report it |
| [known-traps.md](known-traps.md) | Parts of the service that have caught developers out |
| [/.claude/agents/code-reviewer.md](/.claude/agents/code-reviewer.md) | Claude Code reviewer agent, which follows the review checklist |
| [/.cursor/rules/code-review.mdc](/.cursor/rules/code-review.mdc) | Cursor rule that follows the same checklist |

## How it's organised

- **One source for each rule.** Project rules live in `AGENTS.md` and this folder. Tool-specific files only point to them, so they can't drift apart.
- **Project rules only.** Personal workflows, preferences and credentials stay in each person's own tool settings.
- **Nothing restricted.** This repository is public. Don't add secrets, internal URLs, or details of systems that AI tools must not access.
- **Human docs first.** The guides in `/guides` are written for people. These files point agents to them rather than repeating them.

## Planned

Not started yet. Each will be added once the team has agreed it.

- [ ] Working agreement: how the team uses AI tools and who is responsible for what
- [ ] Security boundaries: what AI tools may and may not access
- [ ] Maintenance workflow and definition of done for agent-assisted changes
- [ ] Checklists for changes that often go wrong: adding a table or column, changing the public API, cycle-dependent changes, data scripts
- [ ] A debugging guide pointing to the right logs, dashboards and tools, written alongside the runbooks
- [ ] Tool settings that enforce the boundaries, such as blocking reads of secret files or commands against production, and any agreed MCP servers
- [ ] A few representative maintenance tasks used to check that this guidance actually helps

## Changing this guidance

Change it through a normal pull request. Keep `AGENTS.md` short and move detail into this folder or the guides. When a review finds that the code has moved on from what's written here, fix the docs in a separate change.
