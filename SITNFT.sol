// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


import "./Base64.sol";
import "./RoleControl.sol";

contract SITNFT is ERC721, ERC721Enumerable, RoleControl {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIdCounter;
  using Strings for uint256;
  string[] public gradeValues = ["A+","A","A-","B+","B","B-","C+","C","D+","D","F"];

  struct Grade {
      string name;
      string description;
      string bgHue;
      string value;
      address minter;
      address recipient;
  }

  struct Attribute {
      string moduleCode;
      string name;
      string grade;
      string trimester;
      address faculty;
      address recipient;
  }

  mapping(uint256 => Grade) public grades;

  mapping(uint256 => Attribute) private _attributes;

  mapping(string => address) private _studentAddress;
  
  constructor() ERC721("SIT NFT", "SIT") RoleControl(msg.sender) {
  }

  function studentAddress(string memory studentId) public view onlyAdmin returns (address) {
    return _studentAddress[studentId];
  }

  // public
  function mint() public onlyFaculty{
    uint256 supply = totalSupply();
    
    Grade memory newGrade = Grade(
      string(abi.encodePacked('OCN #', uint256(supply+1).toString())),
      "Test Description",
      randomNum(361, block.difficulty, supply).toString(),
      gradeValues[randomNum(gradeValues.length,block.difficulty, supply)],
      msg.sender,
      0xdCb20126d95f7c3645cb82da8a14a992983adA1e
    );
    
    grades[supply + 1] = newGrade;

    _safeMint(msg.sender, supply + 1);
  }

  function multiMint() public onlyFaculty {
    uint i = 0;
    for(i; i < 100; i++) {
      uint256 supply = totalSupply();
      Grade memory newGrade = Grade(
      string(abi.encodePacked('OCN #', uint256(supply+1).toString())),
      Strings.toString(i),
      randomNum(361, block.difficulty, supply).toString(),
      gradeValues[randomNum(gradeValues.length,block.difficulty, supply)],
      msg.sender,
      0xdCb20126d95f7c3645cb82da8a14a992983adA1e
    );
      grades[supply + 1] = newGrade;
      _safeMint(msg.sender, supply + 1);
    }
  }

  function randomNum(uint256 _mod, uint256 _seed, uint256 _salt) public view returns(uint256) {
    uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
    return num;
  }

  function buildImage(uint256 _tokenId) public view returns (string memory) {
    Grade memory currentGrade = grades[_tokenId];
    return Base64.encode(bytes(abi.encodePacked(
      '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg">',
      '<rect height="500" width="502" y="1" x="-1" stroke="#000" fill="hsl(',currentGrade.bgHue,', 50%, 25%)"/>',
      '<text font-style="normal" transform="matrix(1 0 0 1 0 0)" xml:space="preserve" text-anchor="start" font-family="Noto Sans JP" font-size="250" y="334.5" x="89.22656" stroke-width="0" stroke="#000" fill="#ffffff">',currentGrade.value,'</text>',
      '</svg>'
    )));
  }

  function buildMetadata(uint256 _tokenId) public view returns(string memory) {
    
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
    Grade memory currentGrade = grades[_tokenId];

    return string(abi.encodePacked(
      'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
        '{"name": "',
        currentGrade.name,
        '", "description":"',
        currentGrade.description,
        '", "image": "',
        'data:image/svg+xml;base64,',
        buildImage(_tokenId),
        '"}')))));
  }

      function _beforeTokenTransfer(address from, address to, uint256 _tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, _tokenId);

        Grade memory currentGrade = grades[_tokenId];

        require(to == currentGrade.recipient  || to   == currentGrade.minter , "Target is not the recipient.");
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721,ERC721Enumerable, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function addStudentAddress(string memory _id, address _address ) public onlyAdmin {
      _studentAddress[_id] = _address;
    }

}