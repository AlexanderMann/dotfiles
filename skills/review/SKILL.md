---
name: review
description: Review a GitHub PR and post inline comments as a single PR review. Use when asked to review a PR link. Takes the PR URL plus optional focus notes (e.g. spec or story names the PR should satisfy).
argument-hint: <pr-url> [what to focus on, e.g. a spec or story name]
---

# /review

Arguments: `$ARGUMENTS`

The first argument is the PR URL. Anything after it is extra focus from the user.

Spawn one `general-purpose` agent with the brief below, filling in the PR URL and focus. Wait for it, then relay the review URL and a one-line count of comments by category.

## Agent brief

You are reviewing `<PR_URL>`. Extra focus: `<FOCUS or "none">`.

### 1. Gather context

```bash
gh pr view <PR_URL> --json number,title,body,baseRefName,headRefName,headRefOid,files
gh pr diff <PR_URL>
```

If the current directory isn't a checkout of the PR's repo, shallow-clone the head branch into a temp dir: `gh repo clone <owner>/<repo> <tmp> -- --depth 1 --branch <headRefName>`.

Read the full changed files, not just hunks: whether a variable is unused or a function could be private depends on the rest of the file and its callers (`grep` the repo). If the focus names specs or stories, find them in the repo (or the PR body/linked issues) and check the PR actually does what they ask.

### 2. Look for

Only comment on lines this PR adds or changes. Skip anything a linter or type checker would already flag.

- **Unused code**: variables, params, imports, exports, or functions nothing reads.
- **Single-use named constants**: a value pulled into a constant only to avoid a "magic number", used once. Usually clearer inline with a short comment: `setTimeout(fn, 300) // matches CSS fade`.
- **Visibility**: exported/public functions only used in their own module (tests don't count as a reason to export). Suggest making them private.
- **Mutation across boundaries**: a function mutating an argument, or a shared/module object, that the caller owns. Local mutation inside a function is fine; leaking it out is not. Suggest returning a new value.
- **Tautological tests**: tests that mirror the implementation line for line, assert on internal calls or exact call order, snapshot incidental structure, or mock so heavily they only test the mocks. These lock the code in place so any refactor fails tests without a behaviour change. Prefer asserting observable behaviour at the module boundary. Very high coverage built from such tests is a smell, not a win.
- **Verbosity**: comments that restate the code, narrate history ("now we…", "previously…"), or run several lines where one would do; code with needless intermediate variables, defensive branches for impossible states, or wrappers that add nothing. Suggest the shorter version.
- **Spec gaps** (only with focus): behaviour the named spec/story requires that the PR misses or contradicts.

### 3. Write comments

- One issue per comment, tied to the exact line. One or two sentences. Use a ```` ```suggestion ```` block when the fix fits on the commented lines.
- No praise, no summaries of what the code does, no hedging filler.
- If the same issue repeats, comment on the first instance and note "same in X, Y".
- Fewer, sharper comments beat exhaustive ones. If nothing is worth flagging, say so and post no review.

### 4. Post one review

Build a JSON payload and post it in a single call so the author gets one notification:

```json
{
  "commit_id": "<headRefOid>",
  "event": "COMMENT",
  "body": "<1-3 lines: overall take, plus spec coverage if focus was given>",
  "comments": [
    { "path": "src/foo.ts", "line": 42, "side": "RIGHT", "body": "..." },
    { "path": "src/foo.ts", "start_line": 10, "line": 14, "side": "RIGHT", "body": "..." }
  ]
}
```

```bash
gh api repos/<owner>/<repo>/pulls/<number>/reviews --method POST --input <payload.json>
```

`line` is the line number in the new file and must fall inside a diff hunk, or GitHub rejects the whole review with 422. If that happens, drop or move the offending comment and retry. Always use `event: COMMENT`, never `APPROVE` or `REQUEST_CHANGES`.

Return the review's `html_url` and the number of comments per category.
