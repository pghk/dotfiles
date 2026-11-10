# go-jira

Searches, output shapes and pickers for the `jira` CLI, composed as `jira ls -n <query> -t <template> | pick-keyed | <command on issue keys>`. go-jira reads `~/.jira.d`, which is a symlink to `~/.config/go-jira`.

| Layer | Lives in | Owns |
|---|---|---|
| Queries | `queries:` in `config.yml` | JQL that selects issues. `{{.project}}` expands from the config's `project`, so a query names no project. Top-level keys such as `status_today` hold reusable JQL fragments, which a query includes with `{{.status_today}}`. |
| Templates | `templates/` | How each result prints. One per object type and output purpose. |
| Aliases | `source/private_dot_config/zsh/dot_zshrc` | Picking rows with fzf and printing their keys. `pick-keyed` serves any `keyed-tsv` output. |

## Local ownership

`config.yml` is seeded once from `create_config.yml.tmpl` and is never overwritten, because the endpoint, user and project differ per machine. A query added to the seed reaches a machine that already has a config only when it is added to that machine's `config.yml`.

## `keyed-tsv` contract

One row per issue. The first column is the issue key, which the picker reads, and the remaining columns are tab-separated display text. Rows contain no blank lines and no tabs or newlines inside a field. Fields the template reads must be in the query fields (`assignee`, `issuetype`, `status` and `summary` are in the default set).

## `jira-md`

`jira-md KEY` prints one issue as markdown: YAML front matter (key, summary, url, type, project, status, people, dates, and labels, components, fix versions, parent, active sprint ids and links as `relation`/`key` pairs when set), then Description, Subtasks, Links, Attachments and Comments, with each comment date linking to that comment. It is `jira view -t issue-wiki KEY | jira-wiki-to-md`. The `issue-wiki` template renders the whole issue as Jira wiki markup, and the `jira-wiki-to-md` alias runs `pandoc` to convert it to markdown, so the description and comment bodies convert with the headings. `jira-md.lua` is the pandoc filter that turns the template's `{code:frontmatter}` block into front matter and removes the blank lines the Jira reader puts between list items. Jira smart-links come out as raw `<a>` HTML.

## Aliases

`pick-keyed` formats `keyed-tsv` rows into aligned columns, picks rows with fzf, and prints each chosen issue key on its own line. Any command that takes issue keys can follow it. `jira browse` takes one issue per call, so it needs `-n1`.

```sh
jira ls -n sprint -t keyed-tsv | pick-keyed | xargs -r -n1 jira browse
```

`jira-search <term>` runs a text search over summaries, descriptions and comments in the configured project, newest first. It stops before the template so any arguments after the term go to `jira ls`.

```sh
jira-search modal -t keyed-tsv | pick-keyed | xargs -r -n1 jira browse
```

## Adding to it

- A new selection of issues is a new entry under `queries:`.
- A new action on issues is a command on the keys `pick-keyed` prints, with no new alias.
- A new object type (anything other than issues) gets its own template. `pick-keyed` reads its output unchanged as long as the template puts the key first. go-jira can only reach issues through `ls`, so other types need `jira request` against the REST API.
