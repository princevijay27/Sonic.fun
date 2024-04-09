// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract IDOSale is ReentrancyGuard, Pausable {
    using SafeMath for uint256;

    address public tokenAddress;
    address public admin;
    address public owner;
    mapping(address => bool) private _blacklist;

    uint256 public totalSupply;
    uint256 public saleTokenBaseRate;
    uint256 public saleTokenCurrentRate;

    event AdminChanged(address newAdmin);
    event TokenRateChanged(uint256 newRate);
    event BuyToken(address buyer, uint256 amount, uint256 value);
    event SellToken(address seller, uint256 amount, uint256 value);
    event Blacklisted(address account);
    event Unblacklisted(address account);

    modifier isTokenHolder(uint256 _tokenCount) {
        require(
            IERC20(tokenAddress).balanceOf(msg.sender) >= _tokenCount,
            "Not enough tokens"
        );
        _;
    }

    modifier onlyAdmin() {
        require(admin == msg.sender, "Caller is not an admin");
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not the owner");
        _;
    }

    modifier notBlacklisted() {
        require(!_blacklist[msg.sender], "Caller is blacklisted");
        _;
    }

    constructor(
        address _owner,
        address _tokenAddress,
        uint256 _saleTokenBaseRate,
        uint256 _totalSupply
    ) {
        tokenAddress = _tokenAddress;
        saleTokenBaseRate = _saleTokenBaseRate;
        totalSupply = _totalSupply;
        saleTokenCurrentRate = _saleTokenBaseRate;
        owner = _owner;
    }

    function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
        emit AdminChanged(_admin);
    }

    function setsaleTokenCurrentRate(
        uint256 _saleTokenCurrentRate
    ) external onlyAdmin {
        saleTokenCurrentRate = _saleTokenCurrentRate;
        emit TokenRateChanged(_saleTokenCurrentRate);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function blacklistAddress(address account) external onlyOwner {
        _blacklist[account] = true;
        emit Blacklisted(account);
    }

    function unblacklistAddress(address account) external onlyOwner {
        _blacklist[account] = false;
        emit Unblacklisted(account);
    }

    function buy() external payable whenNotPaused notBlacklisted nonReentrant {
        require(saleTokenCurrentRate > 0, "Current rate not defined");
        require(msg.value > 0, "Not enough ETH sent");

        uint256 tokenCount = msg.value.mul(saleTokenCurrentRate);
        require(
            IERC20(tokenAddress).balanceOf(address(this)) >= tokenCount,
            "Insufficient tokens available"
        );

        IERC20(tokenAddress).transfer(msg.sender, tokenCount);
        emit BuyToken(msg.sender, tokenCount, msg.value);
    }

    function sell(
        uint256 _tokenCount
    )
        external
        whenNotPaused
        notBlacklisted
        nonReentrant
        isTokenHolder(_tokenCount)
    {
        require(saleTokenCurrentRate > 0, "Current rate not defined");

        uint256 coinAmount = _tokenCount.div(saleTokenCurrentRate);
        require(
            address(this).balance >= coinAmount,
            "Insufficient ETH available"
        );

        IERC20(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            _tokenCount
        );
        (bool success, ) = msg.sender.call{value: coinAmount}("");
        require(success, "Refund failed");

        emit SellToken(msg.sender, _tokenCount, coinAmount);
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _blacklist[account];
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function getContractCoinBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getContractTokenBalance() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getAdmin() public view returns (address) {
        return admin;
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}
