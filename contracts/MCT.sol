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
    event CallYOurTokens_Finish();              //Finish token call

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint gatchaprice;
    uint lastId;
    uint[] numOfCardsPerGen;
    uint currGen;//starts from 1, not 0
    
    address public admin;
    constructor() ERC721('MCT', 'Card'){
        admin=msg.sender;
        lastId=0;
        currGen=0; //this will be incremented as soon as startNewGen() is called.
        MCTInit();
    }


    

    function addCard(string memory _uri) external {
        require(msg.sender==admin);
        numOfCardsPerGen[currGen-1]++;
        _tokenIds.increment();
        uint id=_tokenIds.current();
        _setTokenURI(id, _uri);
    }
    
    function startNewGen() external{
        numOfCardsPerGen.push(0);
        currGen++;
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
