pragma solidity >=0.7.0 <0.9.0;

interface IERC721 {
    event Transfer(address from, address to, uint tokenId);
    event Approval(address from, address to, uint tokenId);
    event ApprovalForAll(address from, address to, bool approved);

    function transferFrom(address from, address to, uint tokenId) external;
    function safeTransferFrom(address from, address to, uint tokenId) external;
    function safeTransferFrom(address from, address to, uint tokenId, bytes memory data) external;
    function ownerOf(uint tokenId) external view returns(address);
    function balanceOf(address owner) external view returns(uint);
    function approve(address operator, uint tokenId) external;
    function getApproved(uint tokenId) external view returns(address);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns(bool);
}