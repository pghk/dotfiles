# Change survey brief

Send this brief to one sub-agent with `<base>`, `<orig>`, the repository root, and the output path `.notes/<slug>/changes.md`. The agent writes the file and returns only its path and the cluster count.

---

You are surveying the net change of a branch so a later reader can map it into concerns without reading diffs. Work in `<repo>`. The range is `<base>..<orig>`; only the net difference matters, not the commit sequence.

Read, in this order:

1. `git diff --stat <base> <orig>` — the complete path list. Every path must appear in a cluster.
2. `git log --reverse --oneline --name-only <base>..<orig>` — which paths changed together, and the author's own words.
3. For a cluster whose purpose is unclear from names and messages, `git diff <base> <orig> -- <path>` for one or two of its files. Never run `git diff <base> <orig>` unqualified.

Write `<output>` with exactly these sections:

```markdown
# Changes <base>..<orig>

## Stat
<verbatim `git diff --stat` output>

## Clusters
### C1 <short name>
- paths: <every path in this cluster, one per line>
- purpose: <one paragraph: what the change does for the reader of the code, in the author's vocabulary from the log>
- defines: <new symbols, classes, CSS classes, routes, components, or files introduced; omit if none>
- depends on: <other cluster ids whose definitions this cluster uses; omit if none>
- evidence: <commit subjects that touched these paths, as a comma list>

### C2 ...

## Shared paths
<paths that belong to more than one cluster, each with the clusters it serves and why>
```

Cluster by purpose, not by directory: a feature's view, CSS, test, and docs belong together; a foundation that several features use (a token, a base component, test infrastructure) is its own cluster. Aim for the smallest number of clusters that keeps each one describable in a sentence. When one file plausibly serves two clusters, list it under both and under Shared paths.

Do not propose commit messages, order, or what to keep. Do not copy diff hunks into the file.
