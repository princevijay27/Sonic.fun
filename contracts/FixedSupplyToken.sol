// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract FixedSupplyToken is ERC20, Ownable, Pausable {
    mapping(address => bool) private _blacklisted;

    event Blacklisted(address indexed account);
    event Unblacklisted(address indexed account);

    constructor(
        string memory name,
        string memory symbol,
        uint256 fixedSupply
    ) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, fixedSupply);
    }

    function pause() external onlyOwner {
        _pause();
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner {
        _unpause();
        emit Unpaused(msg.sender);
    }

    function blacklist(address account) external onlyOwner {
        require(!_blacklisted[account], "Account is already blacklisted");
        _blacklisted[account] = true;
        emit Blacklisted(account);
    }

    function unblacklist(address account) external onlyOwner {
        require(_blacklisted[account], "Account is not blacklisted");
        _blacklisted[account] = false;
        emit Unblacklisted(account);
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _blacklisted[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {
        require(!_blacklisted[msg.sender], "Caller is blacklisted");
        require(!_blacklisted[recipient], "Recipient is blacklisted");
        return super.transfer(recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {
        require(!_blacklisted[sender], "Sender is blacklisted");
        require(!_blacklisted[recipient], "Recipient is blacklisted");
        return super.transferFrom(sender, recipient, amount);
    }
}
