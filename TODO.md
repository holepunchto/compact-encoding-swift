# TODO

- [ ] **Provide the codecs the corpus covers but this package lacks** `[ready-for-agent]` - the fixed widths, `raw`, `optionalBuffer`, the odd-width integers and the big-endian integers: 24 codecs whose 59 cases the conformance run cannot execute. (#23)
- [ ] **Decide whether `Record` should sort by the key bytes** `[needs-triage]` - it sorts by Swift `String` comparison, which agrees with every case the corpus carries but is a different rule once normalisation differs, and the package exports no unsorted record for the corpus's `record`. (#23)
