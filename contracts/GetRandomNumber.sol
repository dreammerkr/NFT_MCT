// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../node_modules/@chainlink/contracts/src/v0.8/dev/VRFConsumerBase.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract GetRandomNumber is VRFConsumerBase, Ownable{
    
    uint internal fee;
    uint public randomresult;
    
    mapping (bytes32 => address) private callers;
    mapping (address => uint[]) private calledints;
    
    //Check https://docs.chain.link/docs/vrf-contracts for VRFCoordinator & LinkToken & keyHash.
    address public VRFCoordinator;
    // rinkeby: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
    address public LinkToken;
    // rinkeby: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709a
    bytes32 private keyHash;
    //rinkeby: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
    
    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash) VRFConsumerBase(_VRFCoordinator, _LinkToken){
        keyHash=_keyhash;
        
    }
    
    function callRand(uint userProvidedSeed, address _caller) public onlyOwner returns (bytes32 requestId){
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        calledints[_caller].push(0);
        requestId=requestRandomness(keyHash, fee, userProvidedSeed);
        callers[requestId]=_caller;
    }
    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        calledints[callers[requestId]][0]=randomness;
    }
    
    function canGenerateRand(address _caller) internal view returns (bool){
        if(calledints[_caller].length==0) return true;
        else return false;
    }
    
    function getRandomNumber(address _caller) internal returns (uint){
        require(calledints[_caller].length!=0, "Random number not initiated");
        require(calledints[_caller][0]!=0, "Random number is being generated...");
        require(calledints[_caller].length<2, "Popping isn't working, this should not show up...");
        
        uint rand = calledints[_caller][0];
        calledints[_caller].pop();
        return rand;
    }
    
     /**
     * @notice Withdraw LINK from this contract.
     * @dev this is an example only, and in a real contract withdrawals should
     * happen according to the established withdrawal pattern: 
     * https://docs.soliditylang.org/en/v0.4.24/common-patterns.html#withdrawal-from-contracts
     * @param to the address to withdraw LINK to
     * @param value the amount of LINK to withdraw
     */
    function withdrawLINK(address to, uint256 value) public onlyOwner {
        require(LINK.transfer(to, value), "Not enough LINK");
    }

    /**
     * @notice Set the key hash for the oracle
     *
     * @param _keyHash bytes32
     */
    function setKeyHash(bytes32 _keyHash) public onlyOwner {
        keyHash = _keyHash;
    }

    /**
     * @notice Get the current key hash
     *
     * @return bytes32
     */
    function getkeyHash() public view returns (bytes32) {
        return keyHash;
    }

    /**
     * @notice Set the oracle fee for requesting randomness
     *
     * @param _fee uint256
     */
    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    /**
     * @notice Get the current fee
     *
     * @return uint256
     */
    function getfee() public view returns (uint256) {
        return fee;
    }
    
    
}