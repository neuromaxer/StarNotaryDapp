pragma solidity >=0.7.0 <0.9.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}