// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.0;
import "./Factory.sol";
import "./MultiSigWallet.sol";
import "./Verifier.sol";


/// @title Multisignature wallet factory - Allows creation of multisig wallet.
/// @author Stefan George - <stefan.george@consensys.net>
contract MultiSigWalletFactory is Factory, Verifier {

    mapping(address => uint) public entity;           // danh tính nối địa chỉ với 1 id
    mapping(address => bool) public verified;         // đã xác thực danh tính chưa
    uint public identifier;                           // biến đếm

    function create(
        address[] calldata _owners, 
        uint _required, 
        bytes8[] calldata chainID,              // array chain ID
        address[] calldata addresses,                  // array public key
        bytes[] calldata signature,             // array signature
        uint timestamp
        ) public
        returns (address wallet)
    {   
        // require(timestamp + 1000 <= block.timestamp, "Too late!");
        require(verifyIntegrity(chainID,addresses,signature), "Bullshitery");
        identifier++;     

        MultiSigWallet wallet = new MultiSigWallet(_owners, _required);            // deploy 1 contract mulltisigWallet mới
        register(address(wallet));                                           // Lưu lại: tại địa chỉ "wallet" thì đã có instant
                                                                    // msg.sender có 1 instant là wallet
    }

    function verifyIntegrity(
        bytes8[] calldata chainID,              // array chain ID
        address[] calldata addresses,                  // array public key
        bytes[] calldata signature            // array signature
    ) public returns (bool)
    {
        for(uint i = 0; i < chainID.length ;i++)
        {
          bytes32 messageHash = getMessageHash(chainID[i], addresses[i]);
          bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
          (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature[i]);
          require(addresses[i] == ecrecover(ethSignedMessageHash, v, r, s), "Invalid signature");
        }   
    }
}
