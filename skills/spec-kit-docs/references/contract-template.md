# Markdown contract template (handover step, optional)

A reverse pass: read the section already built in Figma and export it into a single `<slug>.md`.
Section order is fixed. Never delete an empty section — write `_Not documented._`

```markdown
---
component: <Title from ds-doc-header>
slug: <kebab-case>
chapter: <Chapter>
summary: <Description>
version: <Major.Minor.Patch of the latest entry>
updated: <YYYY-MM-DD>
status: draft | verified | deprecated
figma:
  file: <fileKey>
  section: <node-id of the documentation section>
  source_component: <node-id of the source component set>
platforms: [react, flutter]
open_questions: <N>
---

# <Component>

<summary>

## 1. Specification

### Anatomy
| # | Part | Required | Purpose |

### States
| State | Description | Priority |

## 2. Variants

Matrix `<Y axis>` × `<X axis>`:

| | <X₁> | <X₂> |
|---|---|---|
| **<Y₁>** | ✓ | — |

Property mapping:

| Figma property | Values | prop (react) | prop (flutter) |

Combinations declared in the component set but not drawn: <list or "none">

## 3. Interaction
| Trigger | Reaction | Context |

Motion tokens: <motion.{context}.{direction}.{property} or Q-###>

## 4. Guidelines
**Do** / **Don't**

## 5. Microcopy
| Slot | Rule | ✓ | ✗ |

## 6. Tokens
| Property | Token | Fallback |

## 7. History
| Version | Date | Type | Change | Author |

## 8. Open questions
| ID | Question | Blocking | Recommendation |

## Source
Figma: <links per section> · built <date>, skill `spec-kit-docs`
```

## Rules

- Written in the documentation language of the build. Figma property names and variant values — verbatim, never translated.
- `MUST` / `SHOULD` / `MAY` for normative requirements in sections 1–5.
- An observation from Figma is a fact. A proposed API is an assumption — mark it explicitly.
- Documentation tokens (`space/doc/*`, `color/ds-*`, `typography/*`) never go into the contract — only the component's own tokens.
- Engine defaults (`Title`, `Description`, `State name`, `Label`, `Name Component`) never enter the contract: their presence means an unfilled block → `Q-###`.
