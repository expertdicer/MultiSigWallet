// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.0;

/// @title Verifier - verify signature
/// @author Lặc Số Một - <expertdicer@gmail.com>
contract Verifier {
    function public2address(bytes memory pubkey) public pure returns (address) {
        bytes32 hash = keccak256(pubkey);
        return address(uint160(uint256(hash)));
    }

    function getMessageHash(
        bytes8 chainID,
        address add
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(chainID, add));
    }

    function getMessageHash(
        bytes memory data
    ) public view returns (bytes32) {
        return keccak256(data);
    }

    function getMessageHash(
        address[] memory add
    ) public view returns (bytes32) {
        bytes memory data;
        for (uint i = 0; i < add.length; i++) 
        {
            data = abi.encodePacked(data, add[i]);
        }
        return keccak256(data);
    }

    function getMessageHash(
        address[] calldata addresses, 
        uint nonce
    ) public view returns (bytes32) {
        bytes memory data;
        for (uint i = 0; i < addresses.length; i++) 
        {
            data = abi.encodePacked(data, addresses[i]);
        }
        data = abi.encodePacked(data, nonce);
        return keccak256(data);
    }

    function testAbi(
        bytes8 chainID,
        bytes memory pubk
    ) public pure returns (bytes memory) {
        return abi.encodePacked(chainID, pubk);
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }


}
