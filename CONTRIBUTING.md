# Contributing to OTAS Architecture Proposal

Thank you for your interest in contributing to the OTAS architecture exploration. This repository is a community review draft — all feedback, corrections, and improvements are welcome.

## How to Contribute

### Reporting Issues

Use the issue templates to categorize your contribution:

- **[Research Topic](.github/ISSUE_TEMPLATE/research-topic.md)** — For questions about existing standards, gap analysis, or areas that need deeper investigation
- **[Spec Question](.github/ISSUE_TEMPLATE/spec-question.md)** — For discussions about specification design decisions, primitive semantics, or API design
- **[POC Task](.github/ISSUE_TEMPLATE/poc-task.md)** — For implementation tasks, reference code improvements, or conformance test additions

### Submitting Pull Requests

1. **Fork** the repository
2. **Create a branch** with a descriptive name:
   - `research/erc-3643-deep-dive`
   - `spec/compliance-hook-redesign`
   - `poc/tokenized-deposit-impl`
   - `docs/whitepaper-section-3`
3. **Make your changes** — keep PRs focused on a single concern
4. **Fill out the PR template** — explain what changed and why
5. **Request review** — tag relevant contributors or open for community review

### PR Review Process

All PRs should:

- [ ] Have a clear description of the change and its motivation
- [ ] Follow the existing document structure and formatting
- [ ] Not introduce changes that cross the in-scope/out-of-scope boundary (see [WHITEPAPER_OUTLINE.md §2](./WHITEPAPER_OUTLINE.md#2-scope-and-boundaries))
- [ ] Include relevant test vectors if modifying conformance tests
- [ ] Be reviewed by at least one other contributor before merging

## Contribution Areas

### Research & Documentation

- Expanding the [standards comparison matrix](./STANDARDS_COMPARISON.md) with additional frameworks
- Drafting sections of the [whitepaper outline](./WHITEPAPER_OUTLINE.md)
- Adding real-world case studies to the asset class examples
- Reviewing and correcting existing documentation

### Specifications

- Proposing changes to the five primitive interfaces
- Adding or refining JSON Schema definitions
- Discussing normative requirements (MUST/SHOULD/MAY)

### Reference Implementations

- Adding reference implementations for asset classes (tokenized deposits, IoT-linked assets)
- Implementing Move/SUI modules for additional primitives
- Improving the sovereign bond example

### Conformance Testing

- Adding test vectors to `conformance/vectors/`
- Implementing test harnesses for new platforms
- Verifying cross-platform semantic equivalence

## Repository Organization

This repository follows the four-pillar structure of OTAS:

| Pillar | Key Files |
|--------|----------|
| **Identity** | `IDENTITY_BRIDGE.md`, `IComplianceGated` (identity-related hooks) |
| **Compliance** | `interfaces/solidity/IComplianceGated.sol`, compliance test vectors |
| **Asset Structure** | `interfaces/solidity/ITokenBase.sol`, `IMetadataAttachable.sol`, schemas |
| **Settlement** | `interfaces/solidity/ISettleable.sol`, `IHoldable.sol`, settlement vectors |

## Code of Conduct

This project follows the [LF Decentralized Trust Code of Conduct](https://www.lfdecentralizedtrust.org/). Please be respectful, constructive, and collaborative in all interactions.

## Questions?

- Open a [discussion issue](../../issues) on this repository
- Join the [#opentokenizedassetstandard](https://discord.com/channels/905194001349627914/) channel in the LF Decentralized Trust Discord

---

*This contribution guide is a proposal. As the OTAS Lab develops its own governance, this guide should be aligned with the official OTAS contribution process.*
