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

## Using Slither to audit smart contract

- Install slither on python env and solc.

```bash
slither contracts/SITNFT.sol --solc-remaps @openzeppelin/=$(pwd)/node_modules/@openzeppelin/
```
