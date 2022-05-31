// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KINR is ERC20, ERC20Burnable, Pausable, Ownable {
    address[] public admins;

    constructor() ERC20("KINR", "KINR") {
        addAdmin(msg.sender);
    }

    ///@notice that the owner can add admin and validates is the new admin is an admin already.

    function addAdmin(address _newAdmin) public onlyOwner {
        require(!isAdmin(_newAdmin), "Error: This address is already an admin");
        admins.push(_newAdmin);
    }

    ///@notice that an address can be removed as an admin by the owner

    function removeAdmin(address _admin) public onlyOwner {
        admins[getAdminIndex(_admin)] = admins[admins.length - 1];
        admins.pop();
    }

    function getAdminIndex(address element)
        internal
        view
        returns (uint256 index)
    {
        for (uint256 i = 0; i < admins.length; i++) {
            if (admins[i] == element) index = i;
        }
        return index;
    }

    ///@notice this function validates if an address is already an admin

    function isAdmin(address caller) internal view returns (bool admin) {
        admin = false;
        for (uint256 i = 0; i < admins.length; i++) {
            if (admins[i] == caller) admin = true;
        }
        return admin;
    }

    ///@notice that the contract can be paused and unpaused by the owner

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    ///@notice that only an admin address can create more tokens
    // The idea behind this is that only autorizhed oracles can perform the minting

    function mint(address to, uint256 amount) public {
        require(
            isAdmin(msg.sender),
            "This address doens't has the proper permissios"
        );
        _mint(to, amount);
    }

    ///@notice that only an admin address can buirn tokens

    function burn(uint256 amount) public override {
        require(
            isAdmin(msg.sender),
            "This address doens't has the proper permissios"
        );
        super.burn(amount);
    }

    function burnFrom(address from, uint256 amount) public override {
        require(
            isAdmin(msg.sender),
            "This address doens't has the proper permissios"
        );
        super.burnFrom(from, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}
