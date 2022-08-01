pragma solidity ^0.4.24;


contract ERC2000 {
function messageForTransferRestriction (uint8 restrictionCode)
      public
      view
      returns (string message)
  {
      message = messagesAndCodes.messages[restrictionCode];
  }
}
