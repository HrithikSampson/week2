pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";
template CheckRoot(n) { // compute the root of a MerkleTree of n Levels
    signal input leaves[2**n];
    signal output root;
    component p = Poseidon(2);
    var hashes[2**n];
    hashes = leaves;
    var t = 0;
    var level = n -1;
    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    for(var maxHash = 2**n;maxHash>=1;maxHash/=2){
        t = 0;
        for(var i = 0;i<maxHash;i=i+2){
            p.inputs <== [hashes[i],hashes[i+1]];
            hashes[t] <== p.out;
            t++;
        }
        level--;
    }
    root <== hashes[0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    var currentHash = leaf;
    component p[n];
    component mux[n];
    component mux2[n];
    var inp[2];
    for(var i=0;i<n;i++){
        p[i] = Poseidon(2);
        mux[i] = Mux1();
        mux2[i] = Mux1();
        mux2[i].s <== (1-path_index[i]);
        mux[i].s <== path_index[i];
        mux[i].c[0] <== currentHash;
        mux[i].c[1] <== path_elements[i];

        mux2[i].c[0] <== currentHash;
        mux2[i].c[1] <== path_elements[i];

        p[i].inputs[0] <==  mux[i].out;

        p[i].inputs[1] <== mux2[i].out;


        currentHash = p[i].out;
    }
    root <== currentHash;
}