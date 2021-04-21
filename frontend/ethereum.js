//<script type="module">
import contractArtifact from '../build/contracts/MCT.json'; 
//console.log(contractArtifact); </script>

var abi = contractArtifact.abi;
var deployments = Object.keys(contractArtifact.networks);
var address = contractArtifact.networks[deployments[deployments.length -1]];
var web3 = new web3('HTTP://localhost:8545');
var MCT = new web3.eth.Contract(abi, address);

var userAccount;

function startApp() {  

    var accountInterval = setInterval(function() {
      // Check if account has changed
      if (web3.eth.accounts[0] !== userAccount) {
        userAccount = web3.eth.accounts[0];
        // Call a function to update the UI with the new account
        getCardsByOwner(userAccount)
        .then(displayCards);
      }
    }, 100); //check every 100 milliseconds to see if userAccount is still equal web3.eth.accounts[0]
  }

   window.addEventListener('load', function() {

    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof web3 !== 'undefined') {
      // Use Mist/MetaMask's provider
      web3js = new Web3(web3.currentProvider);
    } else {
      // Handle the case where the user doesn't have Metamask installed
      // Show them a message prompting them to install Metamask
      alert("Install Matamask to continue");
      open("https://metamask.io/","");
    }
    startApp();
  })

  function addCard(url) {
    $("#txStatus").text("Adding new MCT on the blockchain. This may take a while...");
    // Send the tx to our contract:
    return MCT.methods.addCard(url)
    .send({ from: userAccount })
    .on("receipt", function(receipt) {
      $("#txStatus").text("Successfully created a MCT token that contains " + url + "!");
      // Transaction was accepted into the blockchain, chech if that certain card has been successfully added
      getCardsByOwner(userAccount).then(displayCards); //Considered that the owner of a new card is the admin
    })
    .on("error", function(error) {
      // Alert Transaction has failed
      $("#txStatus").text(error);
    });
  }

    //Get the address of the owner of card by id
  function OwnerofThisCard(id) {
    return MCT.methods.ownerOf(id).call();
  }

  //calls all cards an address owns
  function getCardsByOwner(owner) {
    var cardlist = [];
    MCT.events.
    displayCards(cardlist);
    
  }

  function displayCards(cardlist) {
      for(var i=0; i<cardlist.length; i++){
        var mydiv = document.getElementById("displayimg");
        var url = document.getElementById("imgurl");
        var image = new Image;
        mydiv.appendChild(image);
        image.src = url.value;
      }
  }
