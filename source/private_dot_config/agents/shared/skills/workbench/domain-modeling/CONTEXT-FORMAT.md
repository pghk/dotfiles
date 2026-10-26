# CONTEXT.md format

```md
# {Context name}

{One or two sentences: what this context is and why it exists.}

## Language

**Order**:
A customer's request for goods, from placement to delivery.
_Avoid_: purchase, transaction

**Customer**:
A person or organization that places orders.
_Avoid_: client, buyer, account
```

- **Be opinionated.** When several words exist for one concept, pick one and
  list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences that say what the thing is.
- **Include only project-specific terms.** General programming concepts don't
  belong, however often the project uses them.
- **Group under subheadings** when clusters emerge; a flat list is fine
  otherwise.
- **Several contexts:** a root `CONTEXT-MAP.md` lists each context's
  `CONTEXT.md` and how the contexts relate.
