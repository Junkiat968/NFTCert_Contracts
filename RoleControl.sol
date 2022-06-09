// SPDX-License-Identifier: GPL3

pragma solidity ^0.8.0;

// Import the OpenZeppelin AccessControl contract
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

// create control that extends OpenZeppelin Access Control
contract RoleControl is AccessControlEnumerable {
    // keccak256 to create hash that identify constant in contract
    bytes32 public constant FACULTY_ROLE = keccak256("FACULTY"); // hash FACULTY as role constant

    /*
    * @dev Add 'root' to admin role.
    */
    constructor (address root) {
        // give msg.sender roles 
        _setupRole(DEFAULT_ADMIN_ROLE, root);
        // Set role hierarchy
        _setRoleAdmin(FACULTY_ROLE, DEFAULT_ADMIN_ROLE);
    }


    // Check to see if address has the ADMIN role
    function isAdmin(address account) public virtual view returns(bool)
    {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    // Check to see if address has the FACULTY role
    
    function isFaculty(address account) public virtual view returns(bool) 
    {
        return hasRole(FACULTY_ROLE, account);
    }


    // Modifier to check if msg.sender is admin.
    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Restricted to admins.");
        _;
    }

    // Modifier to check if msg.sender is faculty.
    modifier onlyFaculty() {
        require(isFaculty(msg.sender), "Restricted to faculty.");
        _;
    }

    // Grant admin privilege to an address.
    function addAdmin(address account) public virtual onlyAdmin 
    {
        grantRole(DEFAULT_ADMIN_ROLE,account);
    }

    // Grant faculty privilege to an address. Restricted to Admins.
    function addFaculty(address account) public virtual onlyAdmin
    {
        grantRole(FACULTY_ROLE, account);
    }

    
    // Remove admin privilege on an address.
    function removeAdmin(address account) public virtual onlyAdmin 
    {
        revokeRole(DEFAULT_ADMIN_ROLE,account);
    }

    // Remove faculty privilege on an address.
    function removeFaculty(address account) public virtual onlyAdmin
     {
        revokeRole(FACULTY_ROLE, account);
    }

}


