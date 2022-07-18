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
  event Transfer(address from, address receiver, uint amount, string message, uint256 timestamp, string keyword);
  string[4][16] palette = [
        ["#eca3f5", "#fdbaf9", "#b0efeb", "#edffa9"],
        ["#75cfb8", "#bbdfc8", "#f0e5d8", "#ffc478"],
        ["#ffab73", "#ffd384", "#fff9b0", "#ffaec0"],
        ["#94b4a4", "#d2f5e3", "#e5c5b5", "#f4d9c6"],
        ["#f4f9f9", "#ccf2f4", "#a4ebf3", "#aaaaaa"],
        ["#caf7e3", "#edffec", "#f6dfeb", "#e4bad4"],
        ["#f4f9f9", "#f1d1d0", "#fbaccc", "#f875aa"],
        ["#fdffbc", "#ffeebb", "#ffdcb8", "#ffc1b6"],
        ["#f0e4d7", "#f5c0c0", "#ff7171", "#9fd8df"],
        ["#e4fbff", "#b8b5ff", "#7868e6", "#edeef7"],
        ["#ffcb91", "#ffefa1", "#94ebcd", "#6ddccf"],
        ["#bedcfa", "#98acf8", "#b088f9", "#da9ff9"],
        ["#bce6eb", "#fdcfdf", "#fbbedf", "#fca3cc"],
        ["#ff75a0", "#fce38a", "#eaffd0", "#95e1d3"],
        ["#fbe0c4", "#8ab6d6", "#2978b5", "#0061a8"],
        ["#dddddd", "#f9f3f3", "#f7d9d9", "#f25287"]
  ];
 
  struct IdAddress {
      string id;
      address addr;
  }

  struct Attribute {
      string moduleCode;
      string testType;
      string grade;
      string trimester;
      address recipient;
      address base;
  }
   struct TransferStruct {
        address sender;
        string message;
        uint256 timestamp;
    }
    TransferStruct[] transactions;


  mapping(uint256 => Attribute) public attributes;
  mapping(bytes32 => address) private _studentAddress;

  constructor() ERC721("SIT NFT", "SIT") RoleControl(msg.sender) {
  }
  function addToBlockchain( string memory message) public {
    transactions.push(TransferStruct(msg.sender, message, block.timestamp));
    // emit Transfer(msg.sender, receiver, amount, message, block.timestamp, keyword);
  }
      function getAllTransactions() public view returns (TransferStruct[] memory) {
        return transactions;
    }

  function addStudentAddress(string memory _id, address _address ) public onlyAdmin {
    bytes32 encryptedId = keccak256(abi.encodePacked(_id));
    _studentAddress[encryptedId] = _address;
  }

  function multiAddStudentAddress(IdAddress[] memory _array) public onlyAdmin {
    for(uint i=0; i <_array.length; i++) {
      addStudentAddress(_array[i].id, _array[i].addr);
    }
  }

  function getStudentAddress(string memory _id) public view onlyFaculty returns (address){
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
    function generatePaletteSection(uint256 _tokenId, uint256 pIndex) internal view returns (string memory) {
        return string(abi.encodePacked(
                '<rect width="300" height="300" rx="10" style="fill:',palette[pIndex][0],'" />',
                '<rect y="60" width="300" height="115" style="fill:',palette[pIndex][1],'"/>',
                '<rect y="175" width="300" height="40" style="fill:',palette[pIndex][2],'" />', 
                '<text x="15" y="25" class="medium">',attributes[_tokenId].testType,' Certificate</text>',
                // '<text x="17" y="50" class="small" opacity="0.5">',substring(toString(_tokenId),0,24),'</text>',
                '<g transform="translate(260.000000,40.000000) scale(0.010000,-0.010000)" fill="#000000" stroke="none">',
                '<path d="M446 3021 c-3 -9 -12 -59 -21 -111 -25 -156 -13 -140 -110 -140 l-85 0 0 -488 0 -488 -110 -629 c-60 -347 -112 -640 -115 -651 -4 -20 2 -23 93 -39 53 -9 105 -19 114 -21 16 -5 18 -19 18 -120 l0 -114 664 0 663 0 633 -110 c462 -81 635 -108 641 -99 4 6 10 35 14 63 3 28 11 72 16 99 l11 47 79 0 79 0 0 458 0 458 120 690 c66 379 122 696 123 704 1 11 -26 19 -118 35 l-120 21 -3 92 -3 92 -523 0 -522 0 -635 111 c-349 60 -694 120 -766 133 -120 21 -133 22 -137 7z m964 -773 c0 -7 -8 -63 -17 -125 l-16 -112 -336 -3 c-316 -3 -339 -4 -381 -24 -86 -39 -123 -113 -98 -190 11 -34 22 -43 78 -71 40 -20 145 -53 270 -84 124 -31 234 -65 280 -87 88 -41 174 -122 211 -197 21 -45 24 -63 24 -170 0 -110 -2 -125 -28 -179 -57 -122 -144 -196 -297 -250 l-85 -31 -393 -3 -393 -3 3 123 3 123 365 5 365 5 52 27 c69 37 97 77 98 144 0 91 -62 145 -220 188 -49 14 -148 41 -220 61 -230 63 -344 135 -402 254 -25 51 -28 66 -28 166 0 100 3 115 28 166 68 139 194 227 377 264 91 18 760 21 760 3z m1620 -133 l0 -135 -205 0 -205 0 0 -630 0 -630 -165 0 -165 0 0 630 0 630 -165 0 c-134 0 -165 3 -165 14 0 12 31 175 45 234 l5 22 510 0 510 0 0 -135z m-1197 -782 l-3 -598 -160 -3 -160 -2 0 574 0 574 73 12 c39 7 101 18 137 25 36 7 76 13 90 14 l25 1 -2 -597z"/></g>'
                
            )
        );
    }  



  function generateBase64Image(uint256 _tokenId) public view returns (string memory) {
        return Base64.encode(bytes(generateImage(_tokenId)));
  }
  function setMetadata(uint256 _tokenId, string memory grade) public onlyFaculty returns (string memory) {
        // attributes[_tokenId].testType = "EditedTest";
        attributes[_tokenId].grade = grade;
        return "success";
  }
  


  function generateImage(uint256 _tokenId) public view returns (string memory) {
        // bytes memory hash = abi.encodePacked(bytes32(_tokenId));
        uint256 random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        bytes memory hash = abi.encodePacked(bytes32(random));
        uint256 pIndex = toUint8(hash,0)/16; // 16 palettes
        
        /* this is broken into functions to avoid stack too deep errors */
        string memory paletteSection = generatePaletteSection(_tokenId, pIndex);
        string memory svgSection = buildImageSvg(_tokenId);
        return string(
            abi.encodePacked(
                '<svg class="svgBody" width="300" height="300" viewBox="0 0 300 300" xmlns="http://www.w3.org/2000/svg">',
                paletteSection,
                svgSection
            )
        );
    }
    function buildImageSvg(uint256 _tokenId) public view returns(string memory) {
        return string(
            abi.encodePacked(
                '<text x="15" y="80" class="medium">Module> ',attributes[_tokenId].moduleCode,'</text>',
                '<text x="15" y="100" class="medium">Trimester> ',attributes[_tokenId].trimester,'</text>',
                '<text x="15" y="120" class="medium">Grade:</text>',
                '<rect x="15" y="125" width="205" height="40" style="fill:white;opacity:0.5"/>',
                '<text x="15" y="140" class="medium">',attributes[_tokenId].grade,'</text>',
                '<text x="15" y="190" class="small">Recipient:</text>',
                '<text x="15" y="205" style="font-size:8px">',toHexString(uint160(attributes[_tokenId].base), 20),'</text>',
                '<style>.svgBody {font-family: "Courier New" } .tiny {font-size:6px; } .small {font-size: 12px;}.medium {font-size: 18px;}</style>',
                '</svg>'
            )
        );
    }

    function buildMetadata(uint256 _tokenId) public view returns(string memory) {
        // Attribute memory currentAttribute = attributes[_tokenId];
        string memory image = generateBase64Image(_tokenId);
        string memory json = Base64.encode(
            bytes(string(
                abi.encodePacked(
                    '{"name": "', attributes[_tokenId].moduleCode,' Certificate #',toString(_tokenId),'",',
                    '"image": "', 
                    'data:image/svg+xml;base64,',
                    image,'",',
                    '"attributes": [{"trait_type": "ModuleCode", "value": "', attributes[_tokenId].moduleCode, '"},',
                    '{"trait_type": "Type", "value": "', attributes[_tokenId].testType, '"},',
                    '{"trait_type": "Trimester", "value": "', attributes[_tokenId].trimester, '"}',
                    ']}'
                )
            ))
        );
        return string(abi.encodePacked('data:application/json;base64,', json));
    }
    

  

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
        return buildMetadata(_tokenId);

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

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
        require(_start + 1 >= _start, "toUint8_overflow");
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }
        return tempUint;
    }    
    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }


}