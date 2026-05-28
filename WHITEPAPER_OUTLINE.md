# OTAS Whitepaper Outline — Community Review Draft

> **Status**: High-level outline for community review before deeper drafting.  
> This outline follows the research flow discussed with the OTAS Lab maintainers:  
> **whitepaper → specifications → proof of concept**.

---

## 1. Problem Statement

Global post-trade settlement infrastructure remains fragmented across incompatible ledger implementations, jurisdictional compliance regimes, and asset-class-specific token schemas. This fragmentation creates systemic friction at the intersection of programmable finance and institutional market microstructure.

**Key friction points:**

- No common language for describing tokenized asset behaviors across chains
- Compliance models are ledger-specific and incompatible (ERC-3643 vs SUI DenyList vs Fabric PDC)
- Settlement semantics (DvP, holds, finality) lack standardized on-chain primitives
- Metadata portability — asset identifiers, term data, and lifecycle events don't travel across systems
- No mechanism to verify that implementations on different platforms are semantically equivalent

## 2. Scope and Boundaries

### In Scope (OTAS Lab)

- Protocol-neutral smart contract interface standard
- Composable token primitives (base types, behaviors, metadata)
- Reference implementations for Ethereum (Solidity) and SUI (Move)
- Conformance testing for cross-platform semantic equivalence
- Research report and community whitepaper

### Out of Scope (OpenAssets Platform)

> **Important**: The following capabilities are explicitly outside the OTAS Lab scope and remain within the OpenAssets commercial platform:

- Compliance lifecycle management
- Metadata propagation engines
- Multi-rail settlement orchestration
- Institutional reporting and analytics

## 3. The Four Pillars

OTAS organizes tokenized asset behavior around four pillars. Each pillar defines a domain of concern that every tokenized asset must address, regardless of the underlying ledger.

### 3.1 Identity

- Issuer and holder identity representation
- DID/VC-based claims and attestations
- Legal Entity Identifier (LEI) binding
- Identity-system-agnostic design (not coupled to ONCHAINID or any specific registry)

### 3.2 Compliance

- KYC/AML verification hooks
- Jurisdiction-based transfer restrictions
- Investor accreditation and eligibility
- Sanctions screening integration points
- Transfer rules and holding period enforcement

### 3.3 Asset Structure

- Token base types: Fungible, NonFungible, Partitioned, Composite
- Structured metadata: ISIN, CFI, term sheets, document hashes
- Lifecycle events: issuance, maturity, coupon, redemption, corporate actions
- Oracle integration for dynamic asset state

### 3.4 Settlement

- Delivery versus Payment (DvP) primitives
- Hold/escrow mechanics for pre-trade and margin
- Settlement finality semantics
- Cash leg and asset leg coordination
- Atomic settlement guarantees

## 4. Existing Standards Survey

A comparative analysis of existing tokenization frameworks, evaluating each against the four pillars:

| Category | Standards to Survey |
|----------|-------------------|
| **EVM Token Standards** | ERC-20, ERC-721, ERC-1155, ERC-1400, ERC-3643 (T-REX), ERC-1404, ERC-4626, ERC-7540, ERC-7943 |
| **Modular Frameworks** | CMTAT v3.2 (Swiss Capital Markets Technology Association) |
| **Non-EVM Platforms** | SUI Closed-Loop Token, SUI TransferPolicy/DenyList |
| **Hyperledger Ecosystem** | Fabric Token SDK, Besu EVM compatibility |
| **Interoperability** | SATP (IETF), Hyperledger Cacti |
| **Data Standards** | Chainlink DTA, ISO 20022, ISO 10962 (CFI) |

> **Full matrix**: See [STANDARDS_COMPARISON.md](./STANDARDS_COMPARISON.md) for the detailed comparison across 10 dimensions.

## 5. Gap Analysis

Gaps identified from the standards survey that OTAS primitives aim to address:

1. **No standard binds token → term data** — Metadata is absent, URI-only, or proprietary in all surveyed standards
2. **Compliance hooks are incompatible** — Each framework uses different APIs for the same purpose
3. **No standard DvP settlement primitive** — Atomic DvP is left to application-level logic
4. **Hold semantics not standardized** — CCP-cleared markets need standardized hold/escrow operations
5. **No cross-platform semantic equivalence** — No framework defines how implementations on different chains should behave identically
6. **Event schemas are ad-hoc** — No two standards emit comparable events for the same operation

## 6. Proposed Direction

### 6.1 Schema-First Design

Define behavior at the protocol-neutral schema level (JSON Schema) before implementing on any specific chain. Solidity and Move implementations are *derived from* shared specifications, not the other way around.

### 6.2 Composable Primitives

Five reusable primitives that can be composed to represent any tokenized asset:

| Primitive | Responsibility |
|-----------|---------------|
| `ITokenBase` | Base transfer, supply management, type classification |
| `IComplianceGated` | Pre-transfer eligibility hooks |
| `IHoldable` | Escrow/hold lifecycle for settlement |
| `ISettleable` | Atomic DvP coordination |
| `IMetadataAttachable` | Structured, ISO-aligned metadata binding |

### 6.3 Illustrative Asset Classes

Three asset classes that exercise different combinations of the primitives:

- **Sovereign Bonds**: All 5 primitives (most complex composition)
- **Tokenized Deposits**: 4 primitives (no holds — fungible + compliance + settlement + metadata)
- **IoT-Linked Assets**: 3 primitives (no settlement — nonfungible + compliance + metadata)

### 6.4 Conformance Testing

Platform-independent test vectors that define expected behavior for each primitive. Any implementation (Solidity, Move, Chaincode) that passes all vectors for a primitive is considered "conformant."

## 7. Open Questions for Community Review

> These questions are intentionally left open to invite community input. They represent design decisions that should not be made unilaterally.

1. **Granularity of compliance hooks** — Should `IComplianceGated` be a single `canTransfer` check, or should it expose separate hooks for eligibility, amount limits, and jurisdiction?

2. **Metadata mutability** — Under what conditions should attached metadata (ISIN, term sheets) be updatable after issuance? Who should have authority?

3. **Settlement atomicity across chains** — Can OTAS define on-chain DvP that works within SATP's 2-phase commit model, or are these fundamentally different layers?

4. **Identity resolver pattern** — Should OTAS define a standard `IIdentityResolver` adapter, or leave identity resolution entirely to the platform?

5. **Common layer vs pillar-first organization** — Should the OTAS repo have a shared `common/` layer for definitions used across pillars (asset identifiers, participant roles, lifecycle events), or should each pillar be fully self-contained?

## 8. Next Steps

- [ ] Community review of this outline
- [ ] Detailed drafting of Sections 4-5 (standards survey and gap analysis)
- [ ] Specification drafts for each pillar
- [ ] Reference implementation alignment with specifications
- [ ] Conformance test vector expansion

---

*This outline is offered for community review. Feedback welcome via [Issues](../../issues) or PRs.*
