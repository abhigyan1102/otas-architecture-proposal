# Proposed OTAS Research Roadmap

> **Status**: Draft — proposed timeline for community review.  
> This roadmap assumes a June–November 2026 mentorship period and follows the **whitepaper → specifications → POC** flow discussed with the OTAS Lab maintainers.

---

## Overview

```
Phase 1         Phase 2         Phase 3         Phase 4         Phase 5
Research &      Whitepaper      Specification   Exploratory     Conformance &
Survey          Draft           Drafts          POC             Community Review
────────────    ────────────    ────────────    ────────────    ────────────
June            July            Aug–Sep         Oct             Nov
```

---

## Phase 1: Research and Survey (June 2026)

**Goal**: Build a comprehensive understanding of the existing tokenization landscape.

- [ ] Survey existing tokenization frameworks across EVM, SUI, Fabric, and interoperability protocols
- [ ] Identify common primitives, design patterns, and recurring gaps
- [ ] Map each surveyed standard to the four OTAS pillars (Identity, Compliance, Asset Structure, Settlement)
- [ ] Collect and organize community feedback on scope and priorities
- [ ] Set up the OTAS GitHub repository structure (4-pillar directories, issue templates, contribution guidelines)
- [ ] Publish initial research notes as GitHub discussions or issues

**Deliverable**: Updated [STANDARDS_COMPARISON.md](./STANDARDS_COMPARISON.md) with finalized survey results and gap analysis.

---

## Phase 2: Whitepaper Draft (July 2026)

**Goal**: Translate research findings into a structured whitepaper for community review.

- [ ] Draft the problem statement and scope definition
- [ ] Document the four-pillar framework with detailed rationale
- [ ] Write the standards survey section with comparative analysis
- [ ] Present the gap analysis and proposed direction
- [ ] Formulate open questions for community input
- [ ] Submit whitepaper draft for mentor and community review

**Deliverable**: First draft of the OTAS Community Whitepaper, published in the GitHub repository for open review.

---

## Phase 3: Specification Drafts (August–September 2026)

**Goal**: Translate whitepaper findings into precise, implementable specifications.

- [ ] **Identity Specification** — Define identity binding interfaces, DID/VC integration points, and LEI requirements
- [ ] **Compliance Specification** — Define compliance hook API, eligibility checks, transfer restriction patterns
- [ ] **Asset Structure Specification** — Define token base types, metadata schemas, lifecycle event taxonomy
- [ ] **Settlement Specification** — Define DvP primitives, hold mechanics, finality semantics

Each specification should include:
- Normative requirements (MUST, SHOULD, MAY per RFC 2119)
- JSON Schema definitions (protocol-neutral)
- Platform-specific interface mappings (Solidity, Move)
- Conformance criteria

**Deliverable**: Four specification drafts, one per pillar, published for community review.

---

## Phase 4: Exploratory POC (October 2026)

**Goal**: Demonstrate the specifications with working reference implementations.

- [ ] **Solidity/EVM** — Reference implementations for all five primitives on Ethereum
- [ ] **Move/SUI** — Reference implementations for selected primitives on SUI
- [ ] **Asset class examples** — Compose primitives into the three illustrative asset classes:
  - Sovereign Bonds (all 5 primitives)
  - Tokenized Deposits (4 primitives)
  - IoT-Linked Assets (3 primitives)
- [ ] Optional: Fabric/Chaincode examples if community interest exists

**Deliverable**: Working reference implementations in the GitHub repository, clearly marked as research artifacts (not production code).

---

## Phase 5: Conformance and Community Review (November 2026)

**Goal**: Validate cross-platform semantic equivalence and finalize community deliverables.

- [ ] Expand conformance test vectors for all five primitives
- [ ] Verify that Solidity and Move implementations pass the same test vectors
- [ ] Finalize the community whitepaper with implementation learnings
- [ ] Prepare presentation materials for OTAS Lab and LFDT community
- [ ] Document lessons learned and recommendations for future work

**Deliverable**: Final community whitepaper, conformance test suite, and presentation to the OTAS Lab TSC.

---

## Ongoing Throughout All Phases

- Maintain the OTAS GitHub repository (PR reviews, issue triage, documentation updates)
- Participate in OTAS Lab community calls and Discord discussions
- Publish regular progress updates (weekly or biweekly)
- Seek and incorporate community feedback at each phase transition

---

## Dependencies and Risks

| Risk | Mitigation |
|------|-----------|
| Scope creep into commercial platform features | Strict adherence to the in-scope/out-of-scope boundary in WHITEPAPER_OUTLINE.md §2 |
| Community engagement is low during review periods | Proactively share updates in Discord and tag relevant contributors |
| SUI/Move ecosystem changes during the mentorship | Design specifications to be platform-neutral first, with platform-specific mappings as secondary |
| Standards survey becomes outdated as new ERCs emerge | Maintain the comparison matrix as a living document with versioned snapshots |

---

*This roadmap is a proposal for community review. Adjustments expected based on mentor guidance and community priorities.*
