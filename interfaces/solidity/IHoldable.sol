// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/**
 * @title IHoldable
 * @notice OTAS Layer 3 — Hold/Escrow Interface
 * @dev Standardized hold semantics for post-trade settlement.
 *      Supports both CCP-instructed margin holds and bilateral DvP holds.
 *
 *      A "hold" locks a portion of a holder's balance, making it
 *      unavailable for transfer but still owned by the holder.
 *      A designated "notary" can execute or release the hold.
 */
interface IHoldable {
    /// @notice Hold lifecycle status
    enum HoldStatus {
        Nonexistent,
        Active,
        Executed,
        Released,
        Expired
    }

    // ──────────────────────────────────────────────
    // State-Changing Functions
    // ──────────────────────────────────────────────

    /**
     * @notice Create a hold on the caller's tokens.
     * @param holdId  Unique identifier for this hold
     * @param holder  The account whose tokens are held
     * @param notary  The account authorized to execute/release
     * @param amount  The amount to hold
     * @param expiry  Block timestamp after which the hold can be reclaimed
     * @return True if the hold was created successfully
     */
    function createHold(
        bytes32 holdId,
        address holder,
        address notary,
        uint256 amount,
        uint256 expiry
    ) external returns (bool);

    /**
     * @notice Execute a hold — transfers the held amount to a destination.
     * @dev Can only be called by the notary.
     * @param holdId The hold to execute
     * @param to     The destination address
     */
    function executeHold(bytes32 holdId, address to) external returns (bool);

    /**
     * @notice Release a hold — returns the held amount to the holder.
     * @dev Can be called by the notary or the holder.
     */
    function releaseHold(bytes32 holdId) external returns (bool);

    // ──────────────────────────────────────────────
    // View Functions
    // ──────────────────────────────────────────────

    /// @notice Returns the current status of a hold
    function holdStatus(bytes32 holdId) external view returns (HoldStatus);

    /// @notice Returns the total held (locked) balance for an account
    function heldBalance(address account) external view returns (uint256);

    /// @notice Returns the available (transferable) balance for an account
    function availableBalance(address account) external view returns (uint256);

    // ──────────────────────────────────────────────
    // Events — Hold Category
    // ──────────────────────────────────────────────

    event HoldCreated(
        bytes32 indexed holdId,
        address indexed holder,
        address notary,
        uint256 amount,
        uint256 expiry
    );

    event HoldExecuted(
        bytes32 indexed holdId,
        address indexed to,
        uint256 amount
    );

    event HoldReleased(
        bytes32 indexed holdId,
        uint256 amount
    );

    event HoldExpired(
        bytes32 indexed holdId,
        uint256 amount
    );
}
