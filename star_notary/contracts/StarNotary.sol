pragma solidity >=0.7.0 <0.9.0;

//Importing ERC-721 Standard
import "./dependencies/ERC721.sol";

contract StarNotary is ERC721 {

    string public name;
    string public symbol;

    constructor() public {
        name = "Star Notary Token";
        symbol = "SNT";
    }

    // Star data
    struct Star {
        string name;
    }

    // Implement Task 1 Add a name and symbol properties
    // name: Is a short name to your token
    // symbol: Is a short string like 'USD' -> 'American Dollar'
    

    // mapping the Star with the Owner Address
    mapping(uint256 => Star) public tokenIdToStarInfo;
    // mapping the TokenId and price
    mapping(uint256 => uint256) public starsForSale;

    
    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(_isOwnerOrApproved(msg.sender, _tokenId), "Only owner, Approved address or an Operator can put star up for sale");
        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transferFrom(ownerAddress, msg.sender, _tokenId); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        address payable ownerAddressPayable = payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            payable(msg.sender).transfer(msg.value - starCost);
        }
        starsForSale[_tokenId] = 0;
    }

    function lookUptokenIdToStarInfo (uint _tokenId) public view returns (string memory) {
        require(_exists(_tokenId), "Can't return Star Info as token doesn't exist");
        return tokenIdToStarInfo[_tokenId].name;
    }

    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        address owner1 = ownerOf(_tokenId1);
        address owner2 = ownerOf(_tokenId2);
        require(msg.sender == owner1 || msg.sender == owner2, "Can't exchange stars as sender is owner of neither of two tokens");
        _transferFrom(owner1, owner2, _tokenId1);
        _transferFrom(owner2, owner1, _tokenId2);
    }

    function transferStar(address _to1, uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId), "Can't transfer star as sender is not token owner");
        safeTransferFrom(msg.sender, _to1, _tokenId);
        starsForSale[_tokenId] = 0; 
    }

}
