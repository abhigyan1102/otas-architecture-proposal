# Identity Bridge — Connecting Identus DIDs/VCs to OTAS Compliance Primitives

> How decentralized identity infrastructure plugs into `IComplianceGated`.

## The Problem

Regulated tokenized assets need **compliance checks** before every transfer:
- Is the recipient KYC-verified?
- Is the recipient in a sanctioned jurisdiction?
- Is the recipient an accredited investor?
- Has the required holding period elapsed?

Traditional approaches (ERC-3643's ONCHAINID) hardcode a specific identity system.
OTAS should be **identity-system-agnostic** — any identity model can fill the compliance hooks.

## The Bridge Pattern

```
┌─────────────────────────────────────────────────────────────────┐
│                    IDENTITY BRIDGE PATTERN                       │
│                                                                 │
│   IComplianceGated.canTransfer(from, to, amount)                │
│         │                                                       │
│         ▼                                                       │
│   ┌─────────────────────┐                                       │
│   │  Identity Resolver  │  ← pluggable adapter                  │
│   └──────────┬──────────┘                                       │
│              │                                                  │
│     ┌────────┴────────────────────────┐                         │
│     │              │                  │                          │
│     ▼              ▼                  ▼                          │
│  ┌────────┐  ┌──────────┐  ┌──────────────┐                    │
│  │ Identus│  │ ONCHAINID│  │  SBT / Role  │                    │
│  │ DID/VC │  │ (ERC-3643│  │  (CMTAT-style)│                   │
│  │        │  │  Claims) │  │              │                     │
│  └────────┘  └──────────┘  └──────────────┘                    │
│                                                                 │
│  Each adapter resolves: "does this address have the required    │
│  compliance claims?"                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## How Identus Fits

[Hyperledger Identus](https://github.com/hyperledger-identus) provides:

| Identus Component | OTAS Relevance |
|-------------------|----------------|
| **DID Methods** (PRISM, peer) | Persistent identifier for token holders and issuers |
| **Verifiable Credentials** | KYC, accreditation, jurisdiction claims issued by trusted parties |
| **SD-JWT** (Selective Disclosure) | Prove "I am KYC-approved" without revealing personal data |
| **Presentation Verification** | On-chain or off-chain verification of holder claims |

### Example Flow: VC-Gated Transfer

```
1. Issuer issues a Verifiable Credential to Alice:
   {
     "type": "KYCVerification",
     "credentialSubject": {
       "did": "did:prism:alice123",
       "kycStatus": "verified",
       "jurisdiction": "US",
       "accredited": true,
       "issuedAt": "2026-01-15"
     },
     "issuer": "did:prism:trustedKYCProvider"
   }

2. Alice's wallet maps did:prism:alice123 → 0xAlice (on-chain address)

3. Token transfer: token.transfer(0xAlice, 0xBob, 100000)

4. IComplianceGated.canTransfer checks:
   a. Resolve 0xBob → did:prism:bob456
   b. Query: does did:prism:bob456 have a valid KYCVerification VC?
   c. Query: is the VC issuer in the trusted issuers list?
   d. Query: is the jurisdiction not sanctioned?
   e. If all pass → return (true, 0x00)
   f. If any fail → return (false, reasonCode)
```

### SD-JWT for Privacy-Preserving Compliance

Using SD-JWT (which I've worked on in Identus PR #556), a holder can selectively disclose:

```
Full credential:
  name: "Alice Smith"
  dateOfBirth: "1990-03-15"
  kycStatus: "verified"
  jurisdiction: "US"
  accredited: true
  ssn: "XXX-XX-XXXX"

Selective disclosure for transfer:
  kycStatus: "verified"     ← disclosed
  jurisdiction: "US"        ← disclosed
  accredited: true          ← disclosed
  (everything else hidden)
```

The token only sees what it needs. The holder controls what is revealed.

## Interface Extension

```solidity
/// @title IIdentityResolver
/// @notice Adapter interface for plugging identity systems into IComplianceGated
interface IIdentityResolver {
    /// @notice Resolve an on-chain address to an identity
    /// @return did The decentralized identifier (or empty if unresolved)
    function resolveIdentity(address account) external view returns (string memory did);

    /// @notice Check if an identity has a specific claim
    /// @param did The decentralized identifier
    /// @param claimType The claim type to check (e.g., "KYCVerification")
    /// @return valid True if the claim exists and is not expired
    /// @return issuer The DID of the claim issuer
    function hasClaim(
        string calldata did,
        string calldata claimType
    ) external view returns (bool valid, string memory issuer);

    /// @notice Check if a claim issuer is trusted for a given claim type
    function isTrustedIssuer(
        string calldata issuer,
        string calldata claimType
    ) external view returns (bool);
}
```

## Why This Matters for OTAS

1. **Identity-agnostic**: OTAS doesn't pick one identity system. The `IIdentityResolver` adapter pattern supports ONCHAINID, Identus DIDs, SBTs, role-based access, or any future system.

2. **Privacy-preserving**: SD-JWT selective disclosure means compliance checks don't require full PII on-chain.

3. **Cross-platform**: The same identity bridge pattern works on Ethereum (Solidity), SUI (Move with capability objects), and Fabric (chaincode with MSP identities).

4. **From contributor experience**: This bridge is informed by hands-on work with Identus DID/VC verification, JWT validation, and SD-JWT temporal checks — not theoretical.

---

*This document describes a proposed extension pattern. The core OTAS primitives (IComplianceGated) work without any specific identity system — the bridge is optional and pluggable.*
