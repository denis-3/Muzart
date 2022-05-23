pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import "./Muzcoin.sol";

contract MuzartNFT is ERC1155 {
  struct Music_Item { // The struct for music-type items specifically
    string ipfs_id;
    string title;
    string description;
    uint price;

    address author_addr;
    uint likes;
    uint amount_remain;
    uint amount_orig;
  }

  address payable muzart_protocol_addr;
  address payable muzcoin_addr;

  /*
  mapping(uint256 => uint) likes; // Maps token IDs to their respective likes
  mapping(uint256 => address) authors; // Maps token IDs to their respective minters/authors
  mapping(uint256 => uint) prices; // Maps token IDs to their respective prices
  */
  mapping(uint256 => Music_Item) music_items;

  MUZToken muzcoin;

  constructor() ERC1155("https://game.example/api/item/{id}.json") {

    muzcoin_addr = payable(address(0)); // this should be changed before deploying this contract

    muzcoin = MUZToken(muzcoin_addr);
  }

  // Your in-house function that allows minting of tokens from the MuzartProtocol smart contract
  function mintFromMuzart(address account, uint256 id, uint256 amount, uint256 price, string memory ipfs_id, string memory title, string memory desc) external {
    require(msg.sender == muzart_protocol_addr, "Permission denied; only the Muzart Protocol Smart Contract can call this function.");
    music_items[id].price = price;
    music_items[id].ipfs_id = ipfs_id;
    music_items[id].title = title;
    music_items[id].description = desc;

    music_items[id].author_addr = account;
    music_items[id].amount_remain = amount;
    music_items[id].amount_orig = amount;


    _mint(account, id, amount, "");
  }

  function getLikes(uint256 tokenId) public view returns (uint256) {
    return music_items[tokenId].likes;
  }

  function likeToken(uint256 tokenId, uint256 like_amount, address caller) public returns(bool success) {
    require(msg.sender == muzart_protocol_addr, "Only the Muzart Protocol Smart Contract can call this function.");
    require(caller != music_items[tokenId].author_addr);

    muzcoin.transferFrom(caller, music_items[tokenId].author_addr, like_amount);
    music_items[tokenId].likes = music_items[tokenId].likes + like_amount;
    return true;
  }

  function purchaseToken(uint256 tokenId, address caller) external returns(bool success) {
    require(msg.sender == muzart_protocol_addr, "only the Muzart Protocol Smart Contract can call this function.");
    require(caller != music_items[tokenId].author_addr);
    require(music_items[tokenId].amount_remain > 0);

    music_items[tokenId].amount_remain = music_items[tokenId].amount_remain - 1;
    muzcoin.transferFrom(caller, music_items[tokenId].author_addr, music_items[tokenId].price);
    safeTransferFrom(music_items[tokenId].author_addr, caller, tokenId, 1, "");
    return true;
  }

  //

  function initAddrs(address payable muzart) public {
    require(msg.sender == address(0), "owner-only function"); // address(0) should be changed with the contract deployer
    muzart_protocol_addr = muzart;
    // muzcoin = MUZToken(_muzcoin);
  }

  // function getNewReleases(uint count) public view returns (MusicItem[]) {
  //
  // }

  fallback() external payable {
    revert();
  }
}
