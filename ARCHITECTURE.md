# OTAS Architecture — Composable Token Primitives

> **Design Document v0.1** | Abhigyan Singh | May 2026  
> For mentor review by the OTAS Lab Technical Steering Committee

---

## Table of Contents

1. [Design Goals](#1-design-goals)
2. [Architectural Layers](#2-architectural-layers)
3. [Primitive Taxonomy](#3-primitive-taxonomy)
4. [Schema-First Design](#4-schema-first-design)
5. [Interface Specifications](#5-interface-specifications)
6. [Asset Class Mapping](#6-asset-class-mapping)
7. [Cross-Platform Semantic Equivalence](#7-cross-platform-semantic-equivalence)
8. [Integration Surface](#8-integration-surface)
9. [Open Questions](#9-open-questions)

---

## 1. Design Goals

The architecture addresses the OTAS Lab's core mandate: establish a **minimal, protocol-neutral smart contract interface standard** encompassing token base type classifications, core operational behaviors, and event schema specifications.

### Non-Goals (Explicitly Out of Scope)
Per the [OTAS Lab charter](https://github.com/OpenTokenizedAssetStandard/.github):
- Compliance workflow engines
- Metadata propagation logic
- Regulatory reporting pipelines
- Lifecycle orchestration
- Platform-level integrations

### Design Principles

```
┌─────────────────────────────────────────────────────────────────┐
│                    OTAS Design Principles                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. SCHEMA-FIRST     Define behavior in JSON Schema before      │
│                      implementing on any chain                  │
│                                                                 │
│  2. COMPOSABLE       Small primitives that compose into         │
│                      complex instruments via mix-in              │
│                                                                 │
│  3. PROTOCOL-NEUTRAL Semantically equivalent across Ethereum    │
│                      and SUI (and extensible to others)         │
│                                                                 │
│  4. MINIMAL          Reference implementations demonstrate      │
│                      the standard — not deliver it              │
│                                                                 │
│  5. AUDITABLE        Every behavior has a corresponding event   │
│                      schema for on-chain auditability           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Architectural Layers

The architecture is organized in four layers. Each layer has a clear dependency direction: higher layers depend on lower layers, never the reverse.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│   Layer 4: ILLUSTRATIVE ASSET CLASSES                                   │
│   ┌───────────────┐  ┌───────────────────┐  ┌───────────────────────┐  │
│   │ Sovereign Bond │  │ Tokenized Deposit │  │ IoT-Linked Asset     │  │
│   │ (composes:     │  │ (composes:        │  │ (composes:            │  │
│   │  Base+Hold+    │  │  Base+Compliance+ │  │  Base+Metadata+      │  │
│   │  Settle+Meta)  │  │  Settle)          │  │  Compliance)         │  │
│   └───────┬───────┘  └────────┬──────────┘  └──────────┬────────────┘  │
│           │                   │                        │                │
├───────────┼───────────────────┼────────────────────────┼────────────────┤
│           ▼                   ▼                        ▼                │
│   Layer 3: CORE BEHAVIOR INTERFACES                                     │
│   ┌──────────────┐ ┌──────────────────┐ ┌────────────┐ ┌────────────┐  │
│   │ IHoldable    │ │ IComplianceGated │ │ ISettleable│ │ IMetadata  │  │
│   │              │ │                  │ │            │ │ Attachable │  │
│   │ createHold() │ │ canTransfer()    │ │ initDvP()  │ │ attach()   │  │
│   │ releaseHold()│ │ isEligible()     │ │ commit()   │ │ resolve()  │  │
│   │ executeHold()│ │                  │ │ finalize() │ │            │  │
│   └──────┬───────┘ └────────┬─────────┘ └─────┬──────┘ └─────┬──────┘  │
│          │                  │                  │              │          │
├──────────┼──────────────────┼──────────────────┼──────────────┼──────────┤
│          ▼                  ▼                  ▼              ▼          │
│   Layer 2: TOKEN BASE TYPE                                              │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                        ITokenBase                               │   │
│   │                                                                 │   │
│   │  Base Types:  Fungible | NonFungible | Partitioned | Composite │   │
│   │  Operations:  mint() | burn() | transfer() | balanceOf()       │   │
│   │  Events:      Minted | Burned | Transferred                    │   │
│   └─────────────────────────────┬───────────────────────────────────┘   │
│                                 │                                       │
├─────────────────────────────────┼───────────────────────────────────────┤
│                                 ▼                                       │
│   Layer 1: PROTOCOL-NEUTRAL SCHEMA DEFINITIONS                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                    JSON Schema Specifications                    │   │
│   │                                                                 │   │
│   │  token-base-types.schema.json    — Type classifications         │   │
│   │  core-behaviors.schema.json      — Behavior interface specs     │   │
│   │  event-schemas.schema.json       — Event format definitions     │   │
│   │                                                                 │   │
│   │  Platform-independent. Generates Solidity + Move interfaces.    │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Primitive Taxonomy

### 3.1 Token Base Types

Every tokenized financial instrument can be classified into one of four base types:

| Base Type | Description | Financial Examples |
|-----------|-------------|-------------------|
| **Fungible** | Interchangeable units with uniform value | Tokenized deposits, stablecoins, money market fund shares |
| **NonFungible** | Unique assets with distinct identity | Real estate titles, specific bond certificates |
| **Partitioned** | Fungible within partitions, but partitions have different properties | Tranched debt (senior/subordinate), multi-currency deposits |
| **Composite** | Bundles of other tokens treated as a single unit | Structured products, collateral baskets |

### 3.2 Core Behavior Primitives

Each primitive is a single-responsibility interface that can be mixed into any base type:

| Primitive | Responsibility | Key Operations |
|-----------|---------------|----------------|
| **IComplianceGated** | Transfer restriction hooks — the token calls these; the platform fills them | `canTransfer(from, to, amount) → bool`, `isEligible(account) → bool` |
| **IHoldable** | Lock/escrow mechanics for settlement and margin | `createHold(id, amount, notary, expiry)`, `executeHold(id, to)`, `releaseHold(id)` |
| **ISettleable** | Atomic DvP coordination between asset and payment legs | `initDvP(assetToken, paymentToken, parties)`, `commit(dvpId)`, `finalize(dvpId)` |
| **IMetadataAttachable** | Structured, on-chain term data and document references | `attach(tokenId, metadataURI, hash)`, `resolve(tokenId) → Metadata` |

### 3.3 Event Schema

Every state change emits a typed event. Events are the **audit trail** — they must be:
- Structurally consistent across Ethereum and SUI
- Machine-readable (indexed fields for filtering)
- Sufficient for off-chain reconciliation

```
Event Categories:
├── Lifecycle Events      → Minted, Burned, Transferred
├── Compliance Events     → TransferRestricted, EligibilityChanged
├── Hold Events           → HoldCreated, HoldExecuted, HoldReleased, HoldExpired
├── Settlement Events     → DvPInitiated, DvPCommitted, DvPFinalized, DvPAborted
└── Metadata Events       → MetadataAttached, MetadataUpdated
```

---

## 4. Schema-First Design

The key architectural insight is: **define the schema before the code**. JSON Schema serves as the single source of truth from which Solidity interfaces and Move modules are derived.

```
                    ┌─────────────────────────┐
                    │    JSON Schema (Layer 1) │
                    │                         │
                    │  token-base-types.json   │
                    │  core-behaviors.json     │
                    │  event-schemas.json      │
                    └────────┬────────────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
           ┌───────────────┐  ┌──────────────┐
           │   Solidity    │  │     Move     │
           │  Interfaces   │  │   Modules    │
           │  (Ethereum)   │  │    (SUI)     │
           │               │  │              │
           │ ITokenBase.sol│  │ token_base   │
           │ IHoldable.sol │  │  .move       │
           │ ...           │  │ ...          │
           └───────┬───────┘  └──────┬───────┘
                   │                 │
                   ▼                 ▼
           ┌───────────────┐  ┌──────────────┐
           │  Reference    │  │  Reference   │
           │  Impls        │  │  Impls       │
           │               │  │              │
           │ SovereignBond │  │ sovereign_   │
           │  .sol         │  │  bond.move   │
           └───────────────┘  └──────────────┘
```

### Why JSON Schema?

1. **Platform-independent** — No Solidity or Move bias
2. **Machine-validatable** — Automated conformance testing
3. **Community-reviewable** — Non-engineers can review the spec without reading smart contract code
4. **Version-controlled** — Schemas evolve under the Community Specification License 1.0

---

## 5. Interface Specifications

### 5.1 ITokenBase — The Foundation

Every OTAS-compliant token implements `ITokenBase`. It defines the absolute minimum:

```solidity
// Solidity — Layer 2
interface ITokenBase {
    enum BaseType { Fungible, NonFungible, Partitioned, Composite }

    function baseType() external view returns (BaseType);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);

    event Minted(address indexed to, uint256 amount, bytes32 indexed operationId);
    event Burned(address indexed from, uint256 amount, bytes32 indexed operationId);
    event Transferred(address indexed from, address indexed to, uint256 amount);
}
```

```move
// Move (SUI) — Layer 2
module otas::token_base {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    /// Base type classification
    const FUNGIBLE: u8 = 0;
    const NON_FUNGIBLE: u8 = 1;
    const PARTITIONED: u8 = 2;
    const COMPOSITE: u8 = 3;

    /// Core token object
    struct TokenBase<phantom T> has key, store {
        id: UID,
        base_type: u8,
        supply: u64,
    }

    /// Event equivalents
    struct Minted has copy, drop {
        to: address,
        amount: u64,
        operation_id: vector<u8>,
    }

    struct Transferred has copy, drop {
        from: address,
        to: address,
        amount: u64,
    }
}
```

### 5.2 IComplianceGated — The Hook

This is where OTAS meets compliance — but **without implementing compliance**. The interface defines the hook points that production platforms fill:

```solidity
// Solidity — Layer 3
interface IComplianceGated {
    /// @notice Called before every transfer. Returns true if transfer is permitted.
    /// @dev Production platforms implement this with their compliance engine.
    ///      The reference implementation always returns true.
    function canTransfer(
        address from,
        address to,
        uint256 amount
    ) external view returns (bool allowed, bytes32 reasonCode);

    /// @notice Check if an account is eligible to hold this token.
    function isEligible(address account) external view returns (bool);

    /// @notice Emitted when a transfer is restricted by compliance
    event TransferRestricted(
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes32 indexed reasonCode
    );
}
```

### 5.3 IHoldable — Lock/Escrow

```solidity
// Solidity — Layer 3
interface IHoldable {
    enum HoldStatus { Nonexistent, Active, Executed, Released, Expired }

    function createHold(
        bytes32 holdId,
        address holder,
        address notary,
        uint256 amount,
        uint256 expiry
    ) external returns (bool);

    function executeHold(bytes32 holdId, address to) external returns (bool);
    function releaseHold(bytes32 holdId) external returns (bool);
    function holdStatus(bytes32 holdId) external view returns (HoldStatus);
    function heldBalance(address account) external view returns (uint256);

    event HoldCreated(bytes32 indexed holdId, address indexed holder, address notary, uint256 amount, uint256 expiry);
    event HoldExecuted(bytes32 indexed holdId, address indexed to, uint256 amount);
    event HoldReleased(bytes32 indexed holdId, uint256 amount);
    event HoldExpired(bytes32 indexed holdId, uint256 amount);
}
```

### 5.4 ISettleable — Atomic DvP

```solidity
// Solidity — Layer 3
interface ISettleable {
    enum DvPStatus { Nonexistent, Initiated, BuyerCommitted, SellerCommitted, Finalized, Aborted }

    struct DvPTerms {
        address assetToken;
        uint256 assetAmount;
        address paymentToken;
        uint256 paymentAmount;
        address buyer;
        address seller;
        uint256 expiryBlock;
    }

    function initDvP(DvPTerms calldata terms) external returns (bytes32 dvpId);
    function commit(bytes32 dvpId) external returns (bool);
    function finalize(bytes32 dvpId) external returns (bool);
    function abort(bytes32 dvpId) external returns (bool);

    event DvPInitiated(bytes32 indexed dvpId, address indexed assetToken, address indexed paymentToken);
    event DvPCommitted(bytes32 indexed dvpId, address indexed party);
    event DvPFinalized(bytes32 indexed dvpId);
    event DvPAborted(bytes32 indexed dvpId, address indexed abortedBy);
}
```

### 5.5 IMetadataAttachable — Structured Term Data

```solidity
// Solidity — Layer 3
interface IMetadataAttachable {
    struct TokenMetadata {
        bytes32 isin;           // ISO 6166 — International Securities Identification Number
        bytes32 lei;            // ISO 17442 — Legal Entity Identifier of issuer
        bytes32 cfi;            // ISO 10962 — Classification of Financial Instruments
        string  termSheetURI;   // Off-chain document reference
        bytes32 termSheetHash;  // Content hash for integrity verification
    }

    function attach(uint256 tokenId, TokenMetadata calldata metadata) external;
    function resolve(uint256 tokenId) external view returns (TokenMetadata memory);

    event MetadataAttached(uint256 indexed tokenId, bytes32 indexed isin, bytes32 indexed lei);
    event MetadataUpdated(uint256 indexed tokenId, string field, bytes32 previousHash, bytes32 newHash);
}
```

---

## 6. Asset Class Mapping

Each illustrative asset class composes a different subset of primitives:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     PRIMITIVE COMPOSITION MATRIX                        │
├───────────────────────┬──────────┬────────────┬──────────┬────────────┤
│                       │ ICompliance │ IHoldable │ ISettleable │ IMetadata │
│                       │ Gated      │           │            │ Attachable│
├───────────────────────┼──────────┼────────────┼──────────┼────────────┤
│ Sovereign Bond        │    ✓     │     ✓      │    ✓     │     ✓      │
│ (Fungible+Partitioned)│          │  (coupon   │  (DvP    │  (ISIN,    │
│                       │          │   escrow)  │  settle) │   BDT)     │
├───────────────────────┼──────────┼────────────┼──────────┼────────────┤
│ Tokenized Deposit     │    ✓     │     ○      │    ✓     │     ✓      │
│ (Fungible)            │          │  (optional)│  (DvP    │  (LEI,     │
│                       │          │            │  settle) │   issuer)  │
├───────────────────────┼──────────┼────────────┼──────────┼────────────┤
│ IoT-Linked Asset      │    ✓     │     ○      │    ○     │     ✓      │
│ (NonFungible)         │          │            │          │  (device   │
│                       │          │            │          │   oracle)  │
├───────────────────────┼──────────┼────────────┼──────────┼────────────┤
│ ✓ = Required   ○ = Optional                                          │
└───────────────────────────────────────────────────────────────────────┘
```

### 6.1 Sovereign Bond Composition

```
SovereignBond = ITokenBase(Partitioned)
              + IComplianceGated      // investor eligibility per jurisdiction
              + IHoldable             // coupon escrow + margin holds
              + ISettleable           // DvP for primary + secondary trading
              + IMetadataAttachable   // ISIN, ICMA Bond Data Taxonomy
```

Lifecycle:
```
Issuance → Compliance Check → Primary Distribution (DvP)
    → Coupon Record Date (Snapshot) → Coupon Payment (Hold + Execute)
        → Secondary Trading (DvP + Compliance)
            → Maturity Redemption (Burn + Payment)
```

### 6.2 Tokenized Deposit Composition

```
TokenizedDeposit = ITokenBase(Fungible)
                 + IComplianceGated    // KYC-verified holders only
                 + ISettleable         // DvP for interbank settlement
                 + IMetadataAttachable // issuing bank LEI, currency
```

### 6.3 IoT-Linked Asset Composition

```
IoTLinkedAsset = ITokenBase(NonFungible)
              + IComplianceGated        // authorized operators
              + IMetadataAttachable     // device ID, oracle feed, data hash
```

---

## 7. Cross-Platform Semantic Equivalence

A core OTAS requirement is that Solidity and Move implementations are **semantically equivalent** — the same behavior specification produces the same observable effects on both platforms.

### Mapping Table

| Concept | Solidity (Ethereum) | Move (SUI) |
|---------|-------------------|------------|
| Token identity | Contract address | Object UID |
| Ownership | `mapping(address => uint256)` | Object ownership (address-owned) |
| Transfer restriction | `_beforeTokenTransfer` hook | Custom `transfer` function with policy check |
| Events | `event` + `emit` (EVM logs) | `struct` with `copy, drop` + `event::emit` |
| Access control | `modifier onlyOwner` | `TxContext::sender()` check |
| Holds/Escrow | Separate balance mapping | Wrapped object with `Notary` capability |
| Composability | Interface inheritance (`is`) | Module imports + generic type parameters |

### Semantic Equivalence Verification

For each primitive, equivalence is verified by:
1. **Behavioral specification** (JSON Schema) — defines expected inputs, outputs, and state transitions
2. **Test vectors** — a set of (input, expected_output) pairs that both implementations must satisfy
3. **Event parity** — same events (structurally) emitted on both platforms for the same operation

---

## 8. Integration Surface

OTAS reference implementations are intentionally minimal. Production platforms integrate by implementing the interfaces with their own logic:

```
┌─────────────────────────────────────────────────────────────────┐
│                    INTEGRATION BOUNDARY                          │
│                                                                 │
│   OTAS Defines (open source)  │  Platform Provides (proprietary)│
│   ────────────────────────────┼──────────────────────────────── │
│   IComplianceGated interface  │  Compliance engine impl          │
│   IHoldable interface         │  Margin management system        │
│   ISettleable interface       │  Settlement orchestration        │
│   IMetadataAttachable         │  Metadata propagation + storage  │
│   Event schemas               │  Monitoring + reporting          │
│   Reference implementations   │  Production deployments          │
│                               │                                  │
│   License: Apache 2.0         │  Proprietary                    │
│   + CSL 1.0 (specs)           │                                  │
└─────────────────────────────────────────────────────────────────┘
```

This boundary is critical. OTAS defines the **hooks**. Platforms fill them with their compliance engines, metadata propagation, and settlement orchestration — the value layer described in the OTAS Lab scope.

---

## 9. Open Questions for Mentor Review

The following design decisions require TSC input before proceeding to prototype:

### Q1: Partitioned Token Semantics
Should OTAS define a standard partitioning model (like ERC-1400 tranches) or leave partition semantics to the base type implementor? Tranching is critical for sovereign bonds but irrelevant for tokenized deposits.

**My initial position**: Define a `Partitioned` base type with a minimal partition interface (`partitionOf`, `transferByPartition`), but do NOT prescribe how partitions are created or named.

### Q2: Compliance Hook Granularity
Should `canTransfer` receive richer context (jurisdiction, investor category, holding period) or remain a simple `(from, to, amount) → bool`?

**My initial position**: Keep the interface minimal. Rich compliance logic belongs in the platform's implementation. The reference implementation should return `true` always.

### Q3: SUI Object Model Differences
SUI's owned-object model fundamentally differs from Ethereum's account model. Should OTAS define an abstract ownership model, or accept that the Solidity and Move implementations will have structurally different APIs despite semantic equivalence?

**My initial position**: Accept structural divergence. Require semantic equivalence (same test vectors pass) but don't force Ethereum patterns onto SUI.

### Q4: Event Schema Versioning
How should event schemas evolve? Append-only (new events, never modify old ones) or versioned (breaking changes with migration)?

**My initial position**: Append-only. Financial audit trails must never break backward compatibility.

### Q5: ISO Identifier Fields
Should `IMetadataAttachable` require ISO identifiers (ISIN, LEI, CFI) or allow arbitrary key-value metadata?

**My initial position**: Define a structured `TokenMetadata` with ISO fields as recommended-but-optional, plus an extensible `bytes` field for custom metadata.

---

## Next Steps

1. **Mentor review** of this architecture document
2. Implement reference interfaces in Solidity (Week 1)
3. Port to Move/SUI (Week 2)
4. Build the three illustrative asset class examples (Weeks 3-4)
5. Write test vectors for semantic equivalence verification
6. Draft the Technical Specification document

---

*This document is offered as a contribution to OTAS Lab discussion under the Community Specification License 1.0. No prescriptive or regulatory guidance is implied.*
