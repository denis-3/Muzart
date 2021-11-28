// We will be using Solidity version 0.5.3
pragma solidity 0.8.10;

contract Muzart {
  // maps for the Artist Marketplace
  mapping (uint => string) private stuff; // The array which stores all the obtainable items (the key is the I.D. of the item)
  mapping (uint => uint) private stuff_prices; // The array which stores the price of the corresponding stuff
  mapping (address => uint[]) private stuff_ownership; // The array which stores the "who owns what" data
  mapping (uint => uint) private stuff_quantity; // The array for how much stuff is left to be sold
  mapping (uint => address) private stuff_sellers;
  // maps for user market
  mapping (uint => string) private um_stuff;
  mapping (uint => uint) private um_prices;
  mapping (uint => address) private um_sellers;


  uint stuff_registered; // Length of "stuff" and "stuff_prices" array
  uint um_stuff_registered;

  mapping(address => uint) private balances;

  // Privates

  function includes(uint needle, uint[] memory haystack) private view returns(bool) { // Basicaly the '.includes()' that javascript has
    for (uint i = 0; i < haystack.length; i++) {
      if (haystack[i] == needle) return true;
    }
    return false;
  }

  function indexOf(uint needle, uint[] memory haystack) private view returns(uint) { // Basically the '.indexof()' that javscript has
    for (uint i = 0; i < haystack.length; i++) {
      if (haystack[i] == needle) return i;
    }
    return 0;
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) { // Converts uint --> string
      if (_i == 0) {
          return "0";
      }
      uint j = _i;
      uint len;
      while (j != 0) {
          len++;
          j /= 10;
      }
      bytes memory bstr = new bytes(len);
      uint k = len;
      while (_i != 0) {
          k = k-1;
          uint8 temp = (48 + uint8(_i - _i / 10 * 10));
          bytes1 b1 = bytes1(temp);
          bstr[k] = b1;
          _i /= 10;
      }
      return string(bstr);
  }

  // Functions for monetary exchange

  function freeTokens(uint howMany) public returns(bool) {
    balances[msg.sender] += howMany;
    return true;
  }

  function burnTokens(uint howMany) public returns(bool) {
    if (howMany > balances[msg.sender]) return false;
    balances[msg.sender] -= howMany;
    return true;
  }

  function sendCoin(address _from, address to, uint howMany) public returns(bool) {
    balances[_from] -= howMany;
    balances[to] += howMany;
    return true;
  }

  function balanceOf(address _b) public view returns(uint) {
    return balances[_b];
  }

  function getAddress() public view returns(address) {
    return msg.sender;
  }

  // Functions regarding le "Obtainable Objects"

  function addAListing(string memory data, uint price, uint quantity) public returns(bool) {
    stuff_registered = stuff_registered + 1;
    stuff[stuff_registered] = data;
    stuff_prices[stuff_registered] = price;
    stuff_quantity[stuff_registered] = quantity;
    stuff_sellers[stuff_registered] = 0xa50Ba8074de6406Da000dc26A5BFeC7B890351A3; // replace with 'msg.sender' after tests are done
    return true;
  }

  function addAListingUM(uint id, uint price) public returns(bool) {
    if (!includes(id, stuff_ownership[msg.sender])) {return false;}
    um_stuff_registered += 1;
    um_stuff[um_stuff_registered] = stuff[id];
    um_prices[um_stuff_registered] = price;
    um_sellers[um_stuff_registered] = msg.sender;
    delete stuff_ownership[msg.sender][indexOf(id, stuff_ownership[msg.sender])];
    return true;
  }

  function viewListingById(address who, uint _id) public view returns(string memory) {
    if (!includes(_id, stuff_ownership[who])) return "you 'on even own this item lol";
    return stuff[_id];
  }

  function getTotalListings() public view returns(uint) {
    return stuff_registered;
  }

  function purchaseStuff(uint id) public returns(bool) {
    if (balances[msg.sender] < stuff_prices[id]) {return false;} else if (stuff_quantity[id] > 0) {
      balances[msg.sender] -= stuff_prices[id];
      stuff_quantity[id] -= 1;
      stuff_ownership[msg.sender].push(id);
      balances[stuff_sellers[id]] += 100000;
      return true;
    } else {
      balances[msg.sender] -= um_prices[id];
      balances[um_sellers[id]] += stuff_prices[id];
      stuff_ownership[msg.sender].push(id);
      delete um_stuff[id];
      return true;
    }
  }

  function transferItem(address _from, address _to, uint id) public returns(bool) {
    if (!includes(id, stuff_ownership[_from])) {return false;} else {
      delete stuff_ownership[_from][indexOf(id, stuff_ownership[_from])];
      stuff_ownership[_to].push(id);
      return true;
    }
  }

  // function getListedItems() public view returns(string memory) {
  //   string memory _final;
  //   for (uint i = 1; i < stuff_registered; i++) {
  //     _final += string(stuff[i]) + "($" + uint2str(stuff_prices[i]) + ")(" + uint2str(stuff_quantity) + " copies remaining)\n";
  //   }
  //   return _final;
  // }
}
