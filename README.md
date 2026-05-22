# OTAS Architecture Proposal — Composable Token Primitives

> **Proposed by**: [Abhigyan Singh](https://github.com/abhigyan1102) — LFX Mentorship Applicant  
> **For**: [OTAS Lab](https://github.com/OpenTokenizedAssetStandard) under LF Decentralized Trust  
> **Mentorship Issue**: [#88 — Researching Composable Token Primitives](https://github.com/LF-Decentralized-Trust-Mentorships/mentorship-program/issues/88)  
> **Status**: Draft for mentor review

---

## Purpose

This repository presents a proposed architecture for the Open Tokenized Asset Standard (OTAS) — specifically, the **protocol-neutral smart contract interface standard** described in the [OTAS Lab scope](https://github.com/OpenTokenizedAssetStandard/.github).

The goal is to demonstrate how a small set of composable token primitives — base types, core behaviors, and event schemas — can serve as a convergence layer across Ethereum and SUI, covering the three illustrative asset classes identified by the OTAS Lab:

1. **Sovereign Bonds** — fixed-income instruments with coupon schedules and maturity
2. **Tokenized Deposits** — bank-issued tokenized claims on fiat deposits
3. **IoT-Linked Assets** — tokens whose state depends on real-world data feeds

All artifacts in this repository are offered as a **contribution to community discussion** — not a prescriptive standard. They are intended to inform the OTAS Lab's research and prototype development.

## Repository Structure

```
otas-architecture-proposal/
├── README.md                          # This file
├── ARCHITECTURE.md                    # Full architecture document with diagrams
├── STANDARDS_COMPARISON.md            # Comparative survey matrix
├── schemas/                           # Protocol-neutral JSON Schema definitions
│   ├── token-base-types.schema.json   # Base type classification schema
│   ├── core-behaviors.schema.json     # Behavioral interface schema
│   └── event-schemas.schema.json      # Event specification schema
├── interfaces/
│   ├── solidity/                      # Ethereum reference interfaces
│   │   ├── ITokenBase.sol             # Base token interface
│   │   ├── IComplianceGated.sol       # Compliance hook interface
│   │   ├── IHoldable.sol              # Hold/escrow interface
│   │   ├── ISettleable.sol            # DvP settlement interface
│   │   └── IMetadataAttachable.sol    # Structured metadata interface
│   └── move/                          # SUI reference interfaces
│       ├── token_base.move            # Base token module
│       └── compliance_gated.move      # Compliance hook module
├── examples/
│   ├── sovereign-bond/                # Illustrative asset class 1
│   │   ├── SovereignBond.sol
│   │   └── README.md
│   ├── tokenized-deposit/             # Illustrative asset class 2
│   │   ├── TokenizedDeposit.sol
│   │   └── README.md
│   └── iot-linked-asset/              # Illustrative asset class 3
│       ├── IoTLinkedAsset.sol
│       └── README.md
└── LICENSE                            # Apache 2.0
```

## Architecture Philosophy

The architecture follows three design principles drawn from the OTAS Lab scope:

1. **Protocol-Neutral First** — Define behavior at the schema level before implementing on any chain. Solidity and Move implementations are *derived from* a shared JSON Schema specification, not the other way around.

2. **Composable Over Monolithic** — Each primitive does one thing. Complex financial instruments are assembled by composing primitives, not by extending a god-contract.

3. **Reference, Not Production** — Implementations demonstrate the standard. Platform capabilities (compliance engines, metadata propagation, settlement orchestration) remain out of scope per the OTAS Lab charter.

## Relation to Existing Standards

| Standard | Relationship to OTAS Primitives |
|----------|-------------------------------|
| ERC-3643 (T-REX) | OTAS `IComplianceGated` generalizes ERC-3643's `ModularCompliance` pattern to be identity-system-agnostic |
| ERC-1400 | OTAS `ITokenBase` with partitioning support covers ERC-1400's tranche model without off-chain dependencies |
| CMTAT | Closest philosophical match — OTAS extends CMTAT's modular approach to be cross-platform |
| Fabric Token SDK | OTAS schemas enable semantic equivalence between Solidity and Chaincode implementations |
| SUI Closed-Loop Token | OTAS `IComplianceGated` maps to SUI's `DenyList` + policy pattern |

See [STANDARDS_COMPARISON.md](./STANDARDS_COMPARISON.md) for the full comparative matrix.

## Licensing

- **Architecture documents and schemas**: Offered for consideration under [Community Specification License 1.0](https://github.com/OpenTokenizedAssetStandard/community-specification-template)
- **Code artifacts**: [Apache License 2.0](./LICENSE)

## Contact

Abhigyan Singh — [abhigyansingh664@gmail.com](mailto:abhigyansingh664@gmail.com) | [@abhigyan1102](https://github.com/abhigyan1102)
