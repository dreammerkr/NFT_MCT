pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MCT is ERC721URIStorage{
    
    event MCTInit();
    event NewGen();
    event SoldCard(uint _id);
    
    
    address public admin;
    constructor() ERC721('MCT', 'Card'){
        admin=msg.sender;
        lastId=0;
        currGen=0;
        MCTInit();
    }
    /*
    function balanceOf(address _owner) public override view returns (uint256){
        
    }
    function ownerOf(uint256 _tokenId) public override view returns (address){
        
    }
    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
        
    }
    function approve(address _approved, uint256 _tokenId) public override {
        
    }*/
    

    
    uint gatchaprice;
    uint lastId;
    uint[] numOfCardsPerGen;
    uint currGen;
    

    function generatePool(uint _numofnewcards /*What to input for URI's? array of strings are not available in Solidity (yet)*/) external {
        require(msg.sender==admin);
        for(uint i=1; i<=_numofnewcards; i++){
            _setTokenURI(lastId+i, ""); //How to pass strings in a nested loop? Maybe just call it everytime?
        }
        numOfCardsPerGen[++currGen]=_numofnewcards;
        lastId+=_numofnewcards;
        NewGen();
    }
    
    function seeCard(uint _id) external view returns (string memory){
        return tokenURI(_id);
    }
    
    function gatcha(address _to) external payable{
        //Currently paying with Ether. This must tbe modified when integrated with Fungible Token.
        require(_to==msg.sender && msg.value==gatchaprice);
        
        uint id=getRandId();
        _mintCard(_to, id);
        SoldCard(id);
    }
    
    function _mintCard(address _to, uint _id) private {
        _safeMint(_to, _id);
        
    }
    
    //Get Random Number from Backend, currently a dummy function.
    function getRandId() public pure returns(uint) 
    {
        return 0;
    }
    
}
