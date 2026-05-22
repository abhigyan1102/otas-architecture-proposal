// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/**
 * @title IComplianceGated
 * @notice OTAS Layer 3 — Compliance Hook Interface
 * @dev Defines the hook points that production compliance engines fill.
 *      OTAS defines the interface; platforms implement the logic.
 *
 *      The reference implementation returns `true` for all checks —
 *      compliance enforcement is explicitly out of OTAS scope.
 *
 * @custom:relation-to-erc3643
 *      Generalizes ERC-3643's ModularCompliance pattern to be
 *      identity-system-agnostic. Any identity model (ONCHAINID,
 *      W3C DID, SBT, role-based) can implement this interface.
 */
interface IComplianceGated {
    // ──────────────────────────────────────────────
    // View Functions
    // ──────────────────────────────────────────────

    /**
     * @notice Called before every transfer to check if it is permitted.
     * @param from   The sender address
     * @param to     The recipient address
     * @param amount The transfer amount
     * @return allowed    True if the transfer is permitted
     * @return reasonCode Reason code if rejected (0x0 if allowed)
     *
     * @dev Reason codes follow a standardized format:
     *      0x01 — Sender not eligible
     *      0x02 — Recipient not eligible
     *      0x03 — Amount exceeds limit
     *      0x04 — Jurisdiction restriction
     *      0x05 — Holding period not met
     *      0x06 — Max holders exceeded
     *      0xFF — Custom (platform-specific)
     */
    function canTransfer(
        address from,
        address to,
        uint256 amount
    ) external view returns (bool allowed, bytes32 reasonCode);

    /**
     * @notice Check if an account is eligible to hold this token.
     * @param account The address to check
     * @return True if the account is eligible
     */
    function isEligible(address account) external view returns (bool);

    // ──────────────────────────────────────────────
    // Events — Compliance Category
    // ──────────────────────────────────────────────

    /// @notice Emitted when a transfer is rejected by compliance
    event TransferRestricted(
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes32 indexed reasonCode
    );

    /// @notice Emitted when an account's eligibility status changes
    event EligibilityChanged(
        address indexed account,
        bool eligible,
        bytes32 indexed reasonCode
    );
}
