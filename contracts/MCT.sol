// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract MCT is ERC721URIStorage{
    
    event MCTInit();
    event NewGen();
    event SoldCard(uint _id);

    //Events that are needed when calling a user's owned tokens
    event CallYourTokens_Start();               //Initiate token call
    event CallYourTokens(string _url);          //Token is called
    event CallYourTokens_Finish();              //Finish token call, typo fixed, sry.

   struct Card{
        uint id;
        address owner;
        string url;
    }
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint gatchaprice;
    uint[] private _numOfCardsPerGen;
    uint private  _currGen;//starts from 1, not 0
    mapping (address => uint[]) private _ownedCards;
    address public admin;
    
    
    constructor() ERC721('MCT', 'Card') {
        admin=msg.sender;
        _currGen=0; //this will be incremented as soon as startNewGen() is called.
        emit MCTInit();
        gatchaprice=0; //Set to 0 for easy testing.
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
    
    function gatcha(address _to) external payable{
        //Currently paying with Ether. This must tbe modified when integrated with Fungible Token.
        require(_to==msg.sender && msg.value==gatchaprice);
        uint id;
        do{
            id=getRandId();
        } while(ownerOf(id)!=admin);
        TransferCard(admin, _to, id);
        emit SoldCard(id);
    }
    
    
    //function to transfer card. should not use transfer function of parent contracts.
    function TransferCard(address _from, address _to, uint _id) public {
        require(ownerOf(_id)==_from || _to==getApproved(_id), 'Invalid transfer');
        if(_removeOwnership(ownerOf(_id), _id)){
            _addOwnership(_to, _id);
            super.safeTransferFrom(_from, _to, _id);
        }
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
