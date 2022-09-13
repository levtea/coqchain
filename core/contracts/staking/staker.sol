// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Staker {

	uint epoch = 100;
	address[] signers;
	mapping (address => uint) name;
	mapping(address => uint256) public balances;

    constructor(uint in_epoch) payable {
		if (in_epoch == 0) {
			epoch = 100;
		}else {
			epoch = in_epoch;
		}
    }

    // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function deposit() public payable {
		require(msg.value != 0,"wrong value");
		balances[msg.sender] = msg.value;
	}
	

	function exist(address signer) internal view returns (bool) {
		bool rs_exist = false;
		for (uint idx =0; idx < signers.length; idx++) {
            if (signers[idx] == signer) {
				rs_exist = true;
			}
		}
		return rs_exist;
	}
	

	function commitSigners(address[] memory sigs) public {

		// must be checkpoint
		bool rs = block.number % epoch != 0;
		require(rs, "not checkpoint");


		// must be signer
		rs = exist(msg.sender);
		require(rs, "not signer");

        // clear old batch signers
		delete signers;

		// set new batch signers
		for (uint idx = 0; idx < sigs.length; idx++){
			signers.push(sigs[idx]);
		}
	}

    function withdraw(address payable _to, uint _amount) public{

		// must be signer
		bool rs = exist(msg.sender);
		require(rs, "not signer");
		
		// _amount should be less or equal _to balance
		rs = balances[_to] >= _amount;
		require(rs, "withdraw amount should be less or equal your balance");


        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send");

    }
	

    // Function to transfer Ether from this contract to address from input
    function slash(address payable _to, uint _amount) public{

		// must be checkpoint
		bool rs = block.number % epoch != 0;
		require(rs, "not checkpoint");

		// must be signer
		rs = exist(msg.sender);
		require(rs, "not signer");
		
		balances[_to] -= _amount;

    }
	
	function balanceOf() view public returns (uint) {
	     return balances[msg.sender];	
	}
}