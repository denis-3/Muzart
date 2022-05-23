pragma solidity ^0.8.9;

// ----------------------------------------------------------------------------
// Lib: Safe Math
// ----------------------------------------------------------------------------
contract SafeMath {

    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


/**
ERC Token Standard #20 Interface
https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
*/
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

/**
ERC20 Token, with the addition of symbol, name and decimals and assisted token transfers
*/
contract MUZToken is ERC20Interface, SafeMath {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;
    uint256 public tokens_from_network_fee;
    uint256 public network_fee;
    uint256 last_fee_distr_call;
    address[] public registrees;
    uint256 public registree_amount;


    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => bool) drop_claim;
    mapping(address => bool) registered;
    mapping(address => uint) rank;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "MUZ";
        name = "Muzcoin";
        decimals = 10;
        _totalSupply = 100000000 * 10**decimals; // 100,000,000 tokens
        network_fee = 5; // in tenths of a percent
        // balances[0x713C49dbD6361de1341d31C219217e12d9432181] = _totalSupply;
        balances[address(0)] = _totalSupply;
        tokens_from_network_fee = 0;
        // emit Transfer(address(0), address(0), _totalSupply);
    }

    function addTokensToFee(uint amount) public returns (uint) {
      uint256 fee = (amount * (network_fee)) / 1000;
      tokens_from_network_fee = tokens_from_network_fee + fee;
      return amount - fee;
    }

    function register() public returns (bool) {
      require(registered[msg.sender] == false, "You have already registered!");
      registrees.push(msg.sender);
      registree_amount = registree_amount + 1;
      registered[msg.sender] = true;
      return true;
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply - balances[address(0)] - tokens_from_network_fee;
    }

    // function calcFeeDistr() public view returns (uint256) {
    //   return (balances[msg.sender] * tokens_from_network_fee) / totalSupply();
    //   // return [balances[msg.sender], totalSupply(), tokens_from_network_fee];
    // }

    function distributeFees() public returns (bool) {
      require(block.timestamp >= last_fee_distr_call + 2 days, "Fees can only be distributed once every 2 days");
      last_fee_distr_call = block.timestamp;

      for (uint256 i = 0; i < registree_amount; i = i + 1) {
        if (balances[registrees[i]] > 0) {
          balances[registrees[i]] = balances[registrees[i]] + (balances[registrees[i]] * tokens_from_network_fee) / totalSupply();
        }
      }
      tokens_from_network_fee = 0;
      return true;
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        tokens = addTokensToFee(tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Airdrops Muzcoins to the ownder in a specific time frame
    // ------------------------------------------------------------------------
    function claimDrop() public returns(bool success) {
      require(!drop_claim[msg.sender], "You have already claimed your airdrop");
      require(block.timestamp <= 1679678092, "The claiming window is over"); // An arbitrary fixed value for now. Later on, functions to dynamicalyl change this will be implemented

      balances[address(0)] = safeSub(balances[address(0)], 1000 * 10**decimals);
      balances[msg.sender] = safeAdd(balances[msg.sender], 1000 * 10**decimals); // replace 10 with the amount of tokens you wanna airdrop
      drop_claim[msg.sender] = true;
      return true;
    }

    // ------------------------------------------------------------------------
    // Automatically transfers Muzcoins in exchange for ETH to the caller's
    // account based on a set exchange rate
    // ------------------------------------------------------------------------
    function swap() external payable returns(bool success) {
      if (msg.value > 0) {
        uint exchange_rate = 1000; // How many MUZ one ETH is equal to
        uint eth_sent = msg.value / 1000000000000000000;
        balances[address(0)] = safeSub(balances[address(0)], exchange_rate * eth_sent);
        balances[msg.sender] = safeAdd(balances[msg.sender], exchange_rate * eth_sent);
        return true;
      } else {
        return false;
      }
    }

    // ------------------------------------------------------------------------
    // Fallback function in case of accidental transfers
    // ------------------------------------------------------------------------
    fallback() external payable {
      revert();
    }
}
