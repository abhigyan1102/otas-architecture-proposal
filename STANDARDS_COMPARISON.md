# Standards Comparison Matrix

> Comparative survey of existing tokenization frameworks evaluated against the OTAS primitive taxonomy.
> This matrix is the foundation for the Research Report deliverable.

## Comparison Dimensions

Each standard is evaluated across 10 dimensions relevant to the OTAS Lab's scope:

| # | Dimension | Description |
|---|-----------|-------------|
| 1 | **Base Type** | Fungible / NonFungible / Partitioned / Composite |
| 2 | **Compliance Model** | Off-chain / On-chain / Hybrid / Hook-based |
| 3 | **Identity Binding** | Address / DID / Claim / Role / None |
| 4 | **Transfer Restriction** | Allowlist / Modular / Pre-hook / None |
| 5 | **Hold/Escrow** | Native / Ad-hoc / None |
| 6 | **DvP Support** | Atomic / Application-level / None |
| 7 | **Metadata Model** | Structured / URI-only / None |
| 8 | **Event Schema** | Standardized / Ad-hoc / Minimal |
| 9 | **Platform Support** | EVM / SUI / Fabric / Multi |
| 10 | **ISO Alignment** | ISIN / LEI / ISO 20022 / None |

## Matrix

| Standard | Base Type | Compliance | Identity | Transfer Restriction | Hold | DvP | Metadata | Events | Platform | ISO |
|----------|-----------|------------|----------|---------------------|------|-----|----------|--------|----------|-----|
| **ERC-20** | Fungible | None | Address | None | None | None | None | Minimal (Transfer, Approval) | EVM | None |
| **ERC-721** | NonFungible | None | Address | None | None | None | URI-only (tokenURI) | Minimal | EVM | None |
| **ERC-1155** | Fungible+NFT | None | Address | None | None | None | URI-only | Minimal | EVM | None |
| **ERC-1400** | Partitioned | Hybrid | Off-chain keys | Pre-hook (`canTransfer`) | None | None | Document mgmt | Partitioned Transfer events | EVM | None |
| **ERC-3643 (T-REX)** | Fungible | On-chain | ONCHAINID Claims | Modular (`ModularCompliance`) | None | None | None | Rich (compliance events) | EVM | None |
| **ERC-1404** | Fungible | Hook-based | Address | Pre-hook (`detectTransferRestriction`) | None | None | None | Minimal + reason codes | EVM | None |
| **CMTAT v3.2** | Fungible | Role-based | AccessControl roles | Modular (pause, snapshot, enforce) | None | None | Snapshot | Module-level events | EVM+Tezos | Partial (Swiss law) |
| **ERC-4626** | Fungible (vault) | None | Address | None | Async (ERC-7540) | None | None | Deposit/Withdraw events | EVM | None |
| **ERC-7943** | Fungible | Hook-based | — | — | — | — | — | — | EVM | — |
| **Fabric Token SDK** | Fungible+NFT | App-level | Wallet ID | PDC-based | None | App-level | None | Chaincode events | Fabric | None |
| **SUI Closed-Loop** | Fungible | Policy-based | Address | `DenyList` + TransferPolicy | None | None | Object metadata | SUI events | SUI | None |
| **SATP (IETF)** | Transport-level | None | Gateway ID | None | Gateway escrow | 2-phase commit | Asset identifier only | Protocol messages | Multi | None |
| **Chainlink DTA** | N/A (standard) | Oracle-based | — | — | — | — | — | — | Multi | Partial |

## Key Gaps Identified

### Gap 1: No Standard Binds Token → Term Data
None of the existing standards define a structured on-chain metadata model that includes ISO identifiers (ISIN, LEI, CFI). Metadata is either absent, URI-only, or proprietary. **OTAS `IMetadataAttachable` addresses this.**

### Gap 2: Compliance Hooks Are Incompatible
ERC-3643's `ModularCompliance`, ERC-1400's `canTransfer`, ERC-1404's `detectTransferRestriction`, and SUI's `TransferPolicy` all serve the same purpose but with incompatible APIs. **OTAS `IComplianceGated` provides a minimal common interface.**

### Gap 3: No Standard DvP Settlement Primitive
Atomic DvP is left to application-level logic in every existing standard. SATP defines transport-level coordination but not the on-chain settlement interface. **OTAS `ISettleable` defines the first standardized on-chain DvP primitive.**

### Gap 4: Hold Semantics Are Not Standardized
CCP-cleared markets need standardized hold/escrow operations. Only ERC-7540 (async vaults) approaches this, but for DeFi, not post-trade. **OTAS `IHoldable` fills this gap.**

### Gap 5: No Cross-Platform Semantic Equivalence
No existing framework defines how a Solidity interface and a SUI Move module should be "semantically equivalent." **OTAS's schema-first approach with shared test vectors is novel.**

### Gap 6: Event Schemas Are Ad-Hoc
Each standard defines its own event structure. No two standards emit comparable events for the same operation. **OTAS event schemas provide a consistent audit trail format.**

---

## Mapping Existing Standards to OTAS Primitives

```
Existing Standard    →  OTAS Primitive Coverage
─────────────────────────────────────────────────
ERC-3643             →  IComplianceGated (partial — ONCHAINID-coupled)
ERC-1400             →  ITokenBase(Partitioned) + IComplianceGated (partial)
CMTAT                →  ITokenBase(Fungible) + IComplianceGated (role-based)
ERC-4626 + ERC-7540  →  IHoldable (vault semantics, not post-trade holds)
SUI Closed-Loop      →  IComplianceGated (DenyList pattern)
SATP                 →  ISettleable (transport-level, not on-chain)
None                 →  IMetadataAttachable with ISO fields
None                 →  Cross-platform event schema standard
```

---

*This comparison is offered for community review. Corrections and additions welcome via PR.*
