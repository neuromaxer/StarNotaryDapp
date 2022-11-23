pragma solidity >=0.7.0 <0.9.0;

import "./ERC165.sol";
import "./IERC721.sol";
import "./Address.sol";
import "./SafeMath.sol";

contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint;
    using Address for address;

    mapping(uint => address) internal _tokenOwners;
    mapping(address => uint) internal _tokenBalances;
    mapping(uint => address) internal _tokenApprovals;
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;

    constructor() public {
        _registerInterface(_InterfaceId_ERC721);
    }

    function ownerOf(uint tokenId) public view returns(address) {
        address owner = _tokenOwners[tokenId];
        require(owner != address(0), "Token doesn't exist yet or was burned");
        return owner;
    }

    function balanceOf(address owner) public view returns(uint) {
        require(owner != address(0), "Can't return balance for account(0)");
        return _tokenBalances[owner];
    }

    function safeTransferFrom(address from, address to, uint tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        require(_checkAndCallSafeTransfer(from, to, tokenId, data), "Contract you want to send token to doesn't support ERC721 standard");
    }

    function transferFrom(address from, address to, uint tokenId) public {
        require(_isOwnerOrApproved(msg.sender, tokenId), "Message Sender is neither owner nor approved/operator");
        require(to != address(0), "Can't transfer token to address(0)");
        _transferFrom(from, to, tokenId);
    }

    function _transferFrom(address from, address to, uint tokenId) internal {
        _clearApproval(from, tokenId);
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);

        emit Transfer(from, to, tokenId);
    }

    function _removeTokenFrom(address from, uint tokenId) internal {
        require(from == ownerOf(tokenId), "Can't remove token provided address is not token owner");
        _tokenOwners[tokenId] = address(0);
        _tokenBalances[from] = _tokenBalances[from].sub(1);
    }

    function _addTokenTo(address to, uint tokenId) internal {
        require(_tokenOwners[tokenId] == address(0), "Can't add a token since it's owned by some address");
        _tokenOwners[tokenId] = to;
        _tokenBalances[to] = _tokenBalances[to].add(1);
    }

    function _clearApproval(address owner, uint tokenId) internal {
        require(owner == ownerOf(tokenId), "Can't clear approval since provided address is not owner");
        _tokenApprovals[tokenId] = address(0);
    }
    function _isOwnerOrApproved(address operator, uint tokenId) internal view returns(bool) {
        require(operator != address(0), "Operator can't be address(0)");
        address owner = ownerOf(tokenId);
        return (operator == ownerOf(tokenId)) || (operator == getApproved(tokenId)) || isApprovedForAll(owner, operator);
    }

    function getApproved(uint tokenId) public view returns(address) {
        require(_exists(tokenId), "Can't approve as token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns(bool) {
        return _operatorApprovals[owner][operator];
    }

    function _exists(uint tokenId) internal view returns(bool){
        return _tokenOwners[tokenId] != address(0);
    }

    function approve(address operator, uint tokenId) public {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Can't approve since message sender is not Owner");
        require(owner != operator, "Can't approve since provided operator is already owner of the token");

        _tokenApprovals[tokenId] = operator;
        emit Approval(owner, operator, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(operator != address(0), "Can't set approval for all to address(0)");
        require(msg.sender != operator, "Can't set approval for all for message sender itself");
        _operatorApprovals[msg.sender][operator] = true;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function _mint(address to, uint tokenId) internal {
        require(to != address(0), "Can't mint a token for address(0)");
        require(!_exists(tokenId), "Can't mint a token with tokenId that already exists");
        _addTokenTo(to, tokenId);
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint tokenId) internal {
        _clearApproval(owner, tokenId);
        _removeTokenFrom(owner, tokenId);
        emit Transfer(owner, address(0), tokenId);
    }

    function _checkAndCallSafeTransfer(address from, address to, uint tokenId, bytes memory data) internal returns(bool) {
        if (!to.isContract()) {
            return true;  // sending to Externally Owned Account (owned by person)
        }
        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data);
        return (retval == _ERC721_RECEIVED);
    }

}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes memory data
    ) 
    external 
    returns(bytes4);
}