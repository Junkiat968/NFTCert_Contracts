// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


import "./Base64.sol";
import "./RoleControl.sol";

contract SITNFT is ERC721, ERC721Enumerable, RoleControl {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIdCounter;
  using Strings for uint256;

  struct Attribute {
      string moduleCode;
      string testType;
      string grade;
      string trimester;
      address recipient;
      address base;
  }

  mapping(uint256 => Attribute) public attributes;
  mapping(bytes32 => address) private _studentAddress;

  
  constructor() ERC721("SIT NFT", "SIT") RoleControl(msg.sender) {
  }

  function addStudentAddress(string memory _id, address _address ) private {
    bytes32 encryptedId = keccak256(abi.encodePacked(_id));
    _studentAddress[encryptedId] = _address;
  }
  
  function getStudentAddress(string memory _id) private view returns (address) {
    bytes32 encryptedId = keccak256(abi.encodePacked(_id));
    require(_studentAddress[encryptedId] != address(0) , "Student does not exist.");
    return _studentAddress[encryptedId];
  }

  // public
  function mint(string memory moduleCode, string memory testType, string memory grade, string memory trimester, string memory recipient) public onlyFaculty {
    uint256 supply = totalSupply();
    Attribute memory newAttribute = Attribute(
      moduleCode,
      testType,
      grade,
      trimester,
      getStudentAddress(recipient),
      getOwner()
    );

    attributes[supply + 1] = newAttribute;
    _safeMint(newAttribute.recipient,supply + 1);
  }

  function generateModuleSection(uint256 _tokenId) internal view returns (string memory) {
        Attribute memory currentAttribute = attributes[_tokenId];
      return string(abi.encodePacked(
      '<text style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 16.4px;" x="13" y="98.877">Module: </text>',
      '<text style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 16.4px;" x="77" y="98.877">',currentAttribute.moduleCode,'</text>',
      '<text style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 16.4px;" x="13" y="114.877">Type:</text>',
      '<text style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 16.4px;" x="76.697" y="114.877">',currentAttribute.testType,'</text>',
      '<text style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 16.4px;" x="13" y="146.877">Trimester:</text>',
      '<text style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 16.4px;" x="95.434" y="146.877">',currentAttribute.trimester,',</text>'
            )
        );
  }

  function generateBase64Image(uint256 _tokenId) public view returns (string memory) {
        return Base64.encode(bytes(generateImage(_tokenId)));
  }
  

  function generateImage(uint256 _tokenId) public view returns(string memory) {
    Attribute memory currentAttribute = attributes[_tokenId];
    string memory moduleSection = generateModuleSection(_tokenId);
    return string(abi.encodePacked(
      '<svg width="350" height="350" viewBox="0 0 350 350" xmlns="http://www.w3.org/2000/svg">',
      moduleSection,
      '<text style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 16.4px;" x="13" y="130.877">Grade:</text>',
      '<text style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 16.4px;" x="77.283" y="130.877">',currentAttribute.grade,'</text>',
      '<text style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 16.4px;" x="13" y="162.877">Recipient:</text>',
      '<text style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 12px;" x="13" y="181.158">',toHexString(uint160(currentAttribute.recipient), 20),'</text>',
      '</svg>'
    ));
  }

  

  
  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    Attribute memory currentAttribute = attributes[_tokenId];

    string memory image = generateBase64Image(_tokenId);

    return string(abi.encodePacked(
      'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
        '{"moduleCode": "',
        currentAttribute.moduleCode,
        '", "testType":"',
        currentAttribute.testType,
        '","Grade":"',
        currentAttribute.grade,
        '","Trimester":"',
        currentAttribute.trimester,
        '","Recipient":"',
        toHexString(uint160(currentAttribute.recipient), 20),
        '", "image": "',
        'data:image/svg+xml;base64,',
        image,
        '"}')))));
  }

      function _beforeTokenTransfer(address from, address to, uint256 _tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, _tokenId);

        Attribute memory currentAttribute = attributes[_tokenId];
        
        require(to == currentAttribute.recipient || to == currentAttribute.base , "Target is not the recipient.");
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721,ERC721Enumerable, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }



    bytes16 private constant _ALPHABET = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _ALPHABET[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "HEX_L");
        return string(buffer);
    }



}