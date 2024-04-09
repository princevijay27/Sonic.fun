// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FixedSupplyToken.sol";
import "./IDOSale.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IDOSaleFactory is Ownable {
    // Stores the address of each created token and corresponding IDOSale contract
    struct TokenSaleInfo {
        address tokenAddress;
        address saleAddress;
    }

    // List of all tokens and sales created
    TokenSaleInfo[] public tokenSales;

    // Blacklist mapping
    mapping(address => bool) public blacklisted;

    // Events
    event TokenCreated(
        address indexed tokenAddress,
        address indexed saleContract
    );
    event Blacklisted(address indexed user);
    event Unblacklisted(address indexed user);

    constructor() Ownable(msg.sender) {}

    function createIDOSale(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 tokenSupply,
        uint256 saleTokenBaseRate,
        uint256 totalSaleSupply
    ) public {
        require(!blacklisted[msg.sender], "Caller is blacklisted");

        FixedSupplyToken token = new FixedSupplyToken(
            tokenName,
            tokenSymbol,
            tokenSupply
        );
        IDOSale sale = new IDOSale(
            owner(), // Owner of the sale contract
            address(token),
            saleTokenBaseRate,
            totalSaleSupply
        );

        // Transfer the total sale supply from the creator to the IDOSale contract
        token.transfer(address(sale), totalSaleSupply);

        // Storing the created token and sale info
        tokenSales.push(TokenSaleInfo(address(token), address(sale)));

        emit TokenCreated(address(token), address(sale));
    }

    function blacklistAddress(address _user) public onlyOwner {
        blacklisted[_user] = true;
        emit Blacklisted(_user);
    }

    function unblacklistAddress(address _user) public onlyOwner {
        blacklisted[_user] = false;
        emit Unblacklisted(_user);
    }

    function getTokenSalesCount() public view returns (uint256) {
        return tokenSales.length;
    }

    function getTokenSaleInfo(
        uint256 index
    ) public view returns (TokenSaleInfo memory) {
        require(index < tokenSales.length, "Index out of bounds");
        return tokenSales[index];
    }
}
