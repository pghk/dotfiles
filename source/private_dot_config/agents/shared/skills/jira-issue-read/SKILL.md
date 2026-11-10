---
name: jira-issue-read
description: Read a Jira issue's fields, description, links or comments with the `jira` CLI and jq. Use for a Jira key such as RAV-1234.
---

# Reading a Jira issue

Fetch once as JSON and select only what the task needs. Comments are the largest part of an issue and are often noise, so read them only when the task asks.

```sh
jira view -t json KEY | jq -r '<filter>'
```

`-r` prints strings with real newlines. Without it, description and comment bodies appear as one line of `\n` escapes. Bodies are Jira wiki markup (`h2.`, `*bold*`, `{code}`).

## Filters

Core fields:

```sh
.fields | {summary, status: .status.name, type: .issuetype.name, assignee: .assignee.displayName, labels, parent: .parent.key, fixVersions: [.fixVersions[].name]}
```

Description:

```sh
.fields.description
```

Subtasks and links:

```sh
.fields | {subtasks: [.subtasks[] | {key, status: .fields.status.name, summary: .fields.summary}], links: [.issuelinks[] | {type: (if .outwardIssue then .type.outward else .type.inward end), key: (.outwardIssue.key // .inwardIssue.key), status: (.outwardIssue // .inwardIssue).fields.status.name}]}
```

Attachments (the URLs may need the Jira login to download):

```sh
.fields.attachment[] | {filename, mimeType, content}
```

Comments:

```sh
.fields.comment.comments[] | "## \(.author.displayName) \(.created) id=\(.id)\n\(.body)"
```

Limit the output by slicing: `.fields.comment.comments[-3:][]` for the latest three, or pipe through `head -c 3000`.

## Reading a whole issue

For a person, `jira view -t issue-md KEY` prints metadata, description, subtasks, links, attachments and comments as markdown, with each comment date linking to that comment.

## Gotchas

- An invalid issue key or a misspelled field in a filter can print nothing and still exit 0. Treat empty output as unconfirmed.
- `null` in the output means the field is unset (for example no assignee).
