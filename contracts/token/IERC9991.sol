// pragma solidity ^0.6.0;

/**
 * @dev Required interface of an IERC9991 compliant contract.
 */

interface IERC9991 is IERC165 {
  /**
   * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
   */
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
}
