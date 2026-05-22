// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/**
 * @title ISettleable
 * @notice OTAS Layer 3 — Atomic DvP Settlement Interface
 * @dev Defines on-chain Delivery-versus-Payment coordination.
 *      Links the transfer of an asset and payment so that
 *      both succeed or neither does.
 *
 *      This is the first standardized on-chain DvP primitive —
 *      existing standards leave DvP to application-level logic.
 */
interface ISettleable {
    /// @notice DvP lifecycle status
    enum DvPStatus {
        Nonexistent,
        Initiated,
        BuyerCommitted,
        SellerCommitted,
        BothCommitted,
        Finalized,
        Aborted
    }

    /// @notice Terms of a DvP settlement
    struct DvPTerms {
        address assetToken;      // The token being delivered
        uint256 assetAmount;     // Amount of asset to deliver
        address paymentToken;    // The token used for payment
        uint256 paymentAmount;   // Amount of payment
        address buyer;           // Receives the asset, delivers payment
        address seller;          // Delivers the asset, receives payment
        uint256 expiryBlock;     // Block number after which DvP can be aborted
    }

    // ──────────────────────────────────────────────
    // State-Changing Functions
    // ──────────────────────────────────────────────

    /**
     * @notice Initiate a DvP settlement.
     * @dev Creates holds on both the asset (seller) and payment (buyer).
     *      Compliance checks (canTransfer) are run at initiation, not finalization.
     * @param terms The DvP terms
     * @return dvpId Unique identifier for this DvP
     */
    function initDvP(DvPTerms calldata terms) external returns (bytes32 dvpId);

    /**
     * @notice Commit to a DvP settlement.
     * @dev Both buyer and seller must commit. The order doesn't matter.
     * @param dvpId The DvP to commit to
     */
    function commit(bytes32 dvpId) external returns (bool);

    /**
     * @notice Finalize a DvP — atomically execute both legs.
     * @dev Can only be called after both parties have committed.
     *      Executes the asset hold (seller → buyer) and
     *      the payment hold (buyer → seller) atomically.
     * @param dvpId The DvP to finalize
     */
    function finalize(bytes32 dvpId) external returns (bool);

    /**
     * @notice Abort a DvP — release all holds.
     * @dev Can be called by either party after expiry, or by both parties agreeing.
     * @param dvpId The DvP to abort
     */
    function abort(bytes32 dvpId) external returns (bool);

    // ──────────────────────────────────────────────
    // View Functions
    // ──────────────────────────────────────────────

    /// @notice Returns the current status of a DvP
    function dvpStatus(bytes32 dvpId) external view returns (DvPStatus);

    /// @notice Returns the terms of a DvP
    function dvpTerms(bytes32 dvpId) external view returns (DvPTerms memory);

    // ──────────────────────────────────────────────
    // Events — Settlement Category
    // ──────────────────────────────────────────────

    event DvPInitiated(
        bytes32 indexed dvpId,
        address indexed assetToken,
        address indexed paymentToken,
        address buyer,
        address seller
    );

    event DvPCommitted(
        bytes32 indexed dvpId,
        address indexed party
    );

    event DvPFinalized(
        bytes32 indexed dvpId
    );

    event DvPAborted(
        bytes32 indexed dvpId,
        address indexed abortedBy
    );
}
