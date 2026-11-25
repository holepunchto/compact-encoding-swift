# TODO

Agent task tracking for this repo. One entry per line:

```markdown
- [ ] **Title** `[role]` - one sentence saying what the work is. (origin)
```

`[role]` is one of `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. Sub-items and findings go in indented bullets beneath an entry. The PR that finishes an entry deletes it; git history is the record of what shipped.

GitHub Issues are the surface for external contributors. A conformance run that finds the corpus wrong rather than this port goes to `compact-encoding-test`, not here.

- [ ] **Provide the integer codecs the corpus covers but this package lacks** `[ready-for-agent]` - the odd widths (`uint24/40/48/56`, `int24/40/48/56`) and the big-endian ones (`uint16be/32be/64be`, `int16be/32be/64be`, `uintbe`, `intbe`): 16 codecs whose 37 cases the conformance run cannot execute. (#23)
