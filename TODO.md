# TODO

Agent task tracking for this repo. One entry per line:

```markdown
- [ ] **Title** `[role]` - one sentence saying what the work is. (origin)
```

`[role]` is one of `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. Sub-items and findings go in indented bullets beneath an entry. The PR that finishes an entry deletes it; git history is the record of what shipped.

GitHub Issues are the surface for external contributors. A conformance run that finds the corpus wrong rather than this port goes to `compact-encoding-test`, not here.

- [ ] **Provide the codecs the corpus covers but this package lacks** `[ready-for-agent]` - the fixed widths, `raw`, `optionalBuffer`, the odd-width integers and the big-endian integers: 24 codecs whose 59 cases the conformance run cannot execute. (#23)
