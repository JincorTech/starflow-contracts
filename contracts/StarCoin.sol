pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

/**
 * @title StarCoin
 *
 * @dev Burnable Ownable ERC20 token
 */
contract StarCoin is MintableToken {

  string public constant name = "StarCoin";
  string public constant symbol = "STAR";
  uint8 public constant decimals = 18;
  uint public constant INITIAL_SUPPLY = 40000000 * 1 ether; //40M tokens accroding to https://starflow.com/ico/
  uint public constant MAXIMUM_SUPPLY = 100000000 * 1 ether; // 100M tokens is maximum according to https://starflow.com/ico/

  /* The finalizer contract that allows unlift the transfer limits on this token */
  address public releaseAgent;

  /** A crowdsale contract can release us to the wild if ICO success. If false we are are in transfer lock up period.*/
  bool public released = false;

  /** Map of agents that are allowed to transfer tokens regardless of the lock down period. These are crowdsale contracts and possible the team multisig itself. */
  mapping (address => bool) public transferAgents;

  /**
   * Limit token transfer until the crowdsale is over.
   *
   */
  modifier canTransfer(address _sender) {
    require(released || transferAgents[_sender]);
    _;
  }

  /** The function can be called only before or after the tokens have been released */
  modifier inReleaseState(bool releaseState) {
    require(releaseState == released);
    _;
  }

  /** The function can be called only by a whitelisted release agent. */
  modifier onlyReleaseAgent() {
    require(msg.sender == releaseAgent);
    _;
  }

  /** Restrict minting by the MAXIMUM_SUPPLY allowed **/
  modifier bellowMaximumSupply(uint _amount) {
    require(_amount + totalSupply_ <= MAXIMUM_SUPPLY);
    _;
  }


  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function StarCoin() {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }


  /**
   * Set the contract that can call release and make the token transferable.
   *
   * Design choice. Allow reset the release agent to fix fat finger mistakes.
   */
  function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {
    require(addr != 0x0);

    // We don't do interface check here as we might want to a normal wallet address to act as a release agent
    releaseAgent = addr;
  }

  function release() onlyReleaseAgent inReleaseState(false) public {
    released = true;
  }

  /**
   * Owner can allow a particular address (a crowdsale contract) to transfer tokens despite the lock up period.
   */
  function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
    require(addr != 0x0);
    transferAgents[addr] = state;
  }

  function transfer(address _to, uint _value) canTransfer(msg.sender) returns (bool success) {
    // Call Burnable.transfer()
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) canTransfer(_from) returns (bool success) {
    // Call Burnable.transferForm()
    return super.transferFrom(_from, _to, _value);
  }

    /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint _amount) onlyOwner canMint bellowMaximumSupply(_amount) public returns (bool) {
    return super.mint(_to, _amount);
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    return super.finishMinting();
  }


}
