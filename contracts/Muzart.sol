pragma solidity >=0.8.0;

import "./MuzartNFT.sol";

contract MuzartProtocol {
  MuzartNFT muzart_nft;

  uint public authors;
  uint public music_items;


  struct Music_Item { // The struct for music-type items specifically
    string ipfs_id;
    string title;
    string description;
    uint price;

    address author_addr;
    uint item_id;
    uint likes;
  }

  struct Muzart_User { // The struct for each individual wallet profile
    string user_name;
    string display_name;
    uint256[] published_items;

    bool initialized;
  }

  mapping(address => Muzart_User) Muzart_Users; // Mapping which associates wallets to Muzart_User structs
  // mapping(uint => Music_Item) Music_Items; // Mapping which lists all the Music items. Note that the key of each item is its ID

  constructor() {
    // muzcoin = MUZToken(muzcoin_addrr);
  }

  // Functions for profile managment

  function initProfile(string memory user_name, string memory display_name) public returns(bool success) {
    if (!Muzart_Users[msg.sender].initialized) {
      Muzart_Users[msg.sender].user_name = user_name;
      Muzart_Users[msg.sender].display_name = display_name;

      Muzart_Users[msg.sender].initialized = true;
      muzart_nft.setApprovalForAll(msg.sender, true);
      return true;
    } else {
      return false;
    }
  }

  function getOwnProfile() public view returns(Muzart_User memory user) {
    return Muzart_Users[msg.sender];
  }

  function setProfile(uint property, string memory value) public returns(bool success) {
    if (property == 1) {
      Muzart_Users[msg.sender].user_name = value;
      return true;
    } else if (property == 2) {
      Muzart_Users[msg.sender].display_name = value;
      return true;
    }
  }

  // Functions for item managment

  function listMusicItem(string memory ipfs_id, string memory title, string memory desc, uint amount, uint price) public returns(uint item_id) {
    require(amount > 0);
    require(price > 0);

    music_items += 1;
    muzart_nft.mintFromMuzart(msg.sender, music_items, amount, price, ipfs_id, title, desc);
    Muzart_Users[msg.sender].published_items.push(music_items);
    return music_items;
  }

  function purchaseToken(uint256 tokenId) public returns(bool success) {
    return muzart_nft.purchaseToken(tokenId, msg.sender);
  }

  function likeToken(uint256 tokenId, uint256 like_amount) public returns(bool success) {
    return muzart_nft.likeToken(tokenId, like_amount, msg.sender);
  }

  // Misc. Functions

  function initMuzartNftAddr(address payable addr) public {
    require(msg.sender == address(0), "owner-only function"); // address(0) should be changed with the contract deployer
    muzart_nft = MuzartNFT(addr);
  }

  fallback() external payable {
    revert();
  }

  // Test Functions

  function getAddr() public view returns(address sender_address) {
    return msg.sender;
  }
}
