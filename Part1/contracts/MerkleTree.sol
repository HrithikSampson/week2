//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[15] public hashes; // the Merkle tree in flattened array form
    uint256 public index ; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        uint currentHash = 0;
        uint startNum = 15;
        index = 7;
        while(startNum > 0){
            for(uint i=startNum/2; i<startNum; i++){
                hashes[i] = currentHash;
            }
            currentHash = PoseidonT3.poseidon([currentHash,currentHash]);
            startNum = startNum/2;
        }

        //to reference interface PoseidonT3.poseidon([left, right])
    }
    function convIdx(uint posn) public pure returns (uint){
        if(posn>6 && posn <15){
            return posn-7;
        }
        if(posn>2 && posn < 7){
            return posn+5;
        }
        if(posn>0 && posn<3){
            return posn+11;
        }
        return 14;
    }
    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        assert(index>=7);
        assert(index<15);
        uint parent = (index-1)/2;
        uint currentIndex = index;
        while(parent > 0){
            parent = (currentIndex-1)/2;
            if(currentIndex%2 == 1){
                hashes[convIdx(parent)] = PoseidonT3.poseidon([hashedLeaf, hashes[2*parent]]);
            }
            else{
                hashes[convIdx(parent)] = PoseidonT3.poseidon([hashes[2*parent - 1],hashedLeaf]);
            }
            currentIndex = parent;
        }

        return hashes[14];
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {
        //assert(input[0] == hashes[14]);
        return verifyProof(a,b,c,input);
    }
}
