pragma solidity >=0.7.0 <0.9.0;

import "./IERC165.sol";

contract ERC165 is IERC165{
    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) internal _supportsInterfaces;

    constructor() public {
        _registerInterface(_InterfaceId_ERC165);
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        _supportsInterfaces[interfaceId] = true;
    }

    function supportsInterface(bytes4 interfaceId) external view returns(bool) {
        return _supportsInterfaces[interfaceId];
    }
}