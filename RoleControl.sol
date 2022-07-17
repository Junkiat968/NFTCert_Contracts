// SPDX-License-Identifier: GPL3

pragma solidity ^0.8.0;

// Import the OpenZeppelin AccessControl contract
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

// create control that extends OpenZeppelin Access Control
contract RoleControl is AccessControlEnumerable {
    // keccak256 to create hash that identify constant in contract
    bytes32 public constant FACULTY_ROLE = keccak256("FACULTY"); // hash FACULTY as role constant
    address private owner;

   event IndexedLog(address indexed sender, string message);

    /*
     * @dev Add 'root' to admin role.
     */
    constructor(address root) {
        require(root != address(0));
        owner = root;
        // give msg.sender roles
        _setupRole(DEFAULT_ADMIN_ROLE, root);
        // Set role hierarchy
        _setRoleAdmin(FACULTY_ROLE, DEFAULT_ADMIN_ROLE);
    }

    // Check to see if address has the ADMIN role
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    // Check to see if address has the FACULTY role

    function isFaculty(address account) public view virtual returns (bool) {
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
    function addAdmin(address account) external virtual onlyAdmin {
        require(!isFaculty(account), "Faculty cannot be an admin.");
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    // Grant faculty privilege to an address. Restricted to Admins.
    function addFaculty(address account) external virtual onlyAdmin {
        require(!isAdmin(account), "Admin cannot be a faculty.");
        grantRole(FACULTY_ROLE, account);
    }

    // Grant faculty privilege to multiple addresses
    function multiAddFaculty(address[] calldata _array) external virtual onlyAdmin {
    for(uint i=0; i <_array.length; i++) {
        require(!isAdmin(_array[i]), "Admin cannot be a faculty.");
        grantRole(FACULTY_ROLE, _array[i]);
    }
    emit IndexedLog(msg.sender,"multiAddFacultySucceed");
  }

    // Remove admin privilege on an address.
    function removeAdmin(address account) external virtual onlyAdmin {
        revokeRole(DEFAULT_ADMIN_ROLE, account);
    }

    // Remove faculty privilege on an address.
    function removeFaculty(address account) external virtual onlyAdmin {
        revokeRole(FACULTY_ROLE, account);
    }

    // Get owner of contract
    function getOwner() public view returns (address) {
        return owner;
    }
}
