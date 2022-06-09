# Smart Contracts 

### Role Control

- Access Control
- Faculty and Admin

#### Usage

```solidity
import "./RoleControl.sol";

// Add to constructor

constructor() ERC721("TEST NFT", "NFT") RoleControl(msg.sender) {

}
```

