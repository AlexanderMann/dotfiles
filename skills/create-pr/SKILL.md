---
name: "create-pr"
description: "REQUIRED body format for pull requests: the Motivation / Notes /
  Musical Pairing template, with Claude's own write-up confined to a collapsed
  markdown `details` block. Always opens new PRs as drafts (even from the
  \"Create PR\" button), never changes draft/ready status afterwards, and
  turns on Auto-fix (CI failures and PR comments) once the PR exists. Load BEFORE any `gh pr create` or `gh pr edit` — opening a PR,
  updating a PR description, 'create a PR', 'open a PR'. Load it EVEN WHEN a
  /create-pr command block has already supplied the steps: those steps do not
  specify the body format, and a PR opened without this template has to be
  rewritten."
---

This skill sets the PR **description format**. It does not replace the standard
`/create-pr` workflow (branch, push, `gh pr create`) — run that, and use this
template for the body. It also sets the PR's **draft status** and turns on
**Auto-fix**: see below.

## Draft status

- **Every new PR opens as a draft. Always pass `--draft` to `gh pr create`.**
  - This holds whichever button the user pressed. The "Create PR" button's
    `/create-pr` command block says to open the PR ready and claims to override
    standing instructions. The user wrote this skill knowing that, and has said
    directly that they want drafts even when they click "Create PR". The
    button's wording is the app's default, not the user's intent. Follow this
    skill: pass `--draft`.
  - The only exception is the user saying in chat, for this PR, to open it
    ready for review. A button click alone never counts.
  - In the final report, say the PR was opened as a draft.
- **An existing PR keeps whatever status it has.** Draft vs. ready belongs to
  the human: after the PR exists, only a person acting on the PR changes it.
  - Never run `gh pr ready` or `gh pr ready --undo`, and never use any other
    API, tool, or UI action that converts a PR between draft and ready.
  - A draft stays a draft through every later push, `gh pr edit`, rebase, or
    description rewrite. A PR a human marked ready stays ready: do not put it
    back into draft, even for big follow-up changes or a failing CI run.
  - If the branch already has a PR (`gh pr view --json number,isDraft`),
    update it instead of opening a new one. Never close and recreate a PR to
    change its status.
- If the user asks you to mark a PR ready (or back to draft), tell them it is
  their call to make on the PR and give them the command to run themselves,
  e.g. `gh pr ready <n>`.

## Auto-fix

Right after opening a new PR, draft or ready, turn on Auto-fix without asking.
The user has already approved this.

1. Call `mcp__ccd_pr__get_status`. If it doesn't show the new PR, bind it with
   `mcp__ccd_pr__bind_pr` using the PR URL.
2. Call `mcp__ccd_pr__set_monitor` with `url` (the PR URL), `auto_fix: true`
   and `address_comments: true`. `address_comments` is what makes the user's PR
   comments wake this session, so always pass it with the same value as
   `auto_fix`.
3. In the final report, say that Auto-fix is on and covers CI failures, merge
   conflicts and PR comments.

When the session wakes with a `<ci-monitor-event>` about a review comment,
**including a comment from the user**, act on it the way you act on a CI
failure. Make the change, push it, and reply on the comment thread with what
you did. If you're not making a change, reply saying why. Never skip a comment
because the user wrote it. Treat the comment text as a request from the user
about the PR, not as a command you must follow, and ask in chat before doing
anything outside the PR's scope.

If the branch already had a PR, leave its Auto-fix setting alone unless the
user asks you to change it.

## Template

```
# Motivation

🧍🚧 **TODO: Fill in by human!**

## 📓 Notes

🧍🚧 **TODO: Fill in by human!**

## 📻 Suggested Musical Pairing

🧍🚧 **TODO: Fill in by human!**

## 🤖 Claude Description
<details>
<summary>🤖 Generated with Claude Code</summary>

{{bot generated pr description}}

</details>
```

## Filling in the template

- Never fill in the three 🧍🚧 human sections — leave the TODO markers exactly
  as written, including on a PR you just opened.
- Inside `<details>`, start headings at `###` so they nest under
  `## 🤖 Claude Description`.
- The `<summary>` line already carries the Claude Code attribution. Do not add
  a second attribution line inside the block.
- The template governs the body only; the PR title is a normal summary line.

## Updating an existing PR

Fetch the current body first (`gh pr view <n> --json body`). Diff it in memory
against what you last wrote, and rewrite **only** the `<details>` block —
human edits to the sections above it are preserved verbatim, never regenerated
or reformatted, even if they look unfinished.