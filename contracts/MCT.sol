// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./GetRandomNumber.sol";

contract MCT is ERC721URIStorage, GetRandomNumber{
    
    
    /*Many require() and approval statements, visibility declarations are inadequate. These should be thoroughly tested, only the simplest logic has been made.*/
    
    event MCTInit();
    event NewGen();
    event SoldCard(string _uri);
    event CallYourTokens_Start();
    event CallYourTokens(string _uri);
    event CallYourTokens_Finish();
    
    
    struct Card{
        uint id;
        address owner;
        string url;
    }
    using Counters for Counters.Counter;
    using Strings for string;
    Counters.Counter private _tokenIds;
    uint gatchaprice;
    uint private _previousGenCards;
    uint[] private _numOfCardsPerGen;
    uint private  _currGen;//starts from 1, not 0
    mapping (address => uint[]) private _ownedCards;
    address public admin;
    uint public cycler;

    
    
    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash) GetRandomNumber(_VRFCoordinator, _LinkToken, _keyhash) ERC721('NFT-MCT', 'MCT') {
        admin=msg.sender;
        _currGen=0; //this will be incremented as soon as startNewGen() is called.
        emit MCTInit();
        _previousGenCards=0;
        gatchaprice=0; //Set to 0 for easy testing.
        cycler=18047; //prime number.
    }

    function addCard(string memory _url) external {
        require(msg.sender==admin);
        _numOfCardsPerGen[_currGen-1]++;
        uint id=_tokenIds.current();
        _tokenIds.increment();
        _mintCard(admin, id);
        _setTokenURI(id, _url);
    }
    
    function startNewGen() external{
        _numOfCardsPerGen.push(0);
        if(_currGen!=0){
            _previousGenCards+=_numOfCardsPerGen[_currGen-1];
        }
        _currGen++;
        emit NewGen();
    }
    
    function callOwnedCards(address _address) external {
        require(msg.sender==_address); //Maybe change to assert()?
        emit CallYourTokens_Start();
        uint[] memory ownedCards = _ownedCards[_address];
        for(uint i=0; i<ownedCards.length; i++){
            string memory url=tokenURI(ownedCards[i]);
            emit CallYourTokens(url);
        }
        emit CallYourTokens_Finish();
    }
    
    function searchCard(uint _id) external view returns (Card memory){
        string memory url = tokenURI(_id);
        address owner = ownerOf(_id);
        Card memory card;
        card.id=_id;
        card.owner=owner;
        card.url=url;
        return card;
    }
    
    function gatcha(address _to, uint userProvidedSeed) external payable{
        //Currently paying with Ether. This must tbe modified when integrated with Fungible Token.
        require(canGenerateRand(_to), "Your previous Gatcha is not finished!");
        require(_to==msg.sender && msg.value==gatchaprice, "Get your own pack or pay for it!");
        uint id = _drawcardId(_to, userProvidedSeed);
        TransferCard(admin, _to, id);
        emit SoldCard(tokenURI(id));
    }
    
    
    //function to transfer card. should not use transfer function of parent contracts.
    function TransferCard(address _from, address _to, uint _id) public {
        require(ownerOf(_id)==_from || _to==getApproved(_id), 'Invalid transfer');
        if(_removeOwnership(ownerOf(_id), _id)){
            _addOwnership(_to, _id);
            super.safeTransferFrom(_from, _to, _id);
        }
    }
    
    function _drawcardId(address _to, uint userProvidedSeed) private returns (uint) {
        callRand(userProvidedSeed, _to);
        uint rawid = getRandomNumber(_to);
        uint id = rawid%_numOfCardsPerGen[_currGen-1];
        id+=_previousGenCards;
        while(ownerOf(id)!=admin){
            id+=cycler;
            id%=_numOfCardsPerGen[_currGen-1];
        }
        return id;
    }
    
    function _mintCard(address _to, uint _id) private {
        _safeMint(_to, _id);
        
    }
    
    function _addOwnership(address _owner, uint _id) private{
        _ownedCards[_owner].push(_id);
    }
    
    function _removeOwnership(address _owner, uint _id) private returns (bool) {
        uint len = _ownedCards[_owner].length;
        uint i=0;
        while(i<len){
            if(_ownedCards[_owner][i]==_id){
                uint lastElement=_ownedCards[_owner][len];
                _ownedCards[_owner][i]=lastElement;
                _ownedCards[_owner].pop();
                return true;
            }
        }
        return false;
    }
    
    
    //Do we need to burn a card?
    function _burnCard(uint _id) internal {
        require(msg.sender==ownerOf(_id) || msg.sender==getApproved(_id));
        address owner = ownerOf(_id);
        _removeOwnership(owner, _id);
        super._burn(_id);
    }
    
    //Get Random Number from Backend, currently a dummy function.
    function getRandId() public pure returns(uint) 
    {
        return 0;
    }
    
}
