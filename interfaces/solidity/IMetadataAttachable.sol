// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/**
 * @title IMetadataAttachable
 * @notice OTAS Layer 3 — Structured Metadata Interface
 * @dev Attaches structured, on-chain term data to tokens.
 *      Uses ISO identifiers (ISIN, LEI, CFI) as recommended fields.
 *
 *      This addresses Gap 1 in the standards comparison:
 *      no existing standard defines structured on-chain metadata
 *      with ISO financial identifiers.
 */
interface IMetadataAttachable {
    /// @notice Structured metadata conforming to ISO financial standards
    struct TokenMetadata {
        bytes32 isin;           // ISO 6166 — International Securities Identification Number
        bytes32 lei;            // ISO 17442 — Legal Entity Identifier of issuer
        bytes32 cfi;            // ISO 10962 — Classification of Financial Instruments
        string  termSheetURI;   // Off-chain document reference (IPFS, HTTPS, etc.)
        bytes32 termSheetHash;  // Content hash for integrity verification
        bytes   extensions;     // Extensible field for asset-class-specific data
    }

    // ──────────────────────────────────────────────
    // State-Changing Functions
    // ──────────────────────────────────────────────

    /**
     * @notice Attach metadata to a token.
     * @dev For fungible tokens, tokenId is typically 0 (global metadata).
     *      For non-fungible tokens, each tokenId has its own metadata.
     * @param tokenId The token to attach metadata to
     * @param metadata The structured metadata
     */
    function attach(uint256 tokenId, TokenMetadata calldata metadata) external;

    /**
     * @notice Update a specific metadata field.
     * @param tokenId The token whose metadata to update
     * @param field   The field name being updated
     * @param data    The new value (ABI-encoded)
     */
    function updateField(uint256 tokenId, string calldata field, bytes calldata data) external;

    // ──────────────────────────────────────────────
    // View Functions
    // ──────────────────────────────────────────────

    /// @notice Resolve the full metadata for a token
    function resolve(uint256 tokenId) external view returns (TokenMetadata memory);

    // ──────────────────────────────────────────────
    // Events — Metadata Category
    // ──────────────────────────────────────────────

    event MetadataAttached(
        uint256 indexed tokenId,
        bytes32 indexed isin,
        bytes32 indexed lei
    );

    event MetadataUpdated(
        uint256 indexed tokenId,
        string field,
        bytes32 previousHash,
        bytes32 newHash
    );
}
