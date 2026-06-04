// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// OmniRefer — USDC referral reward system
contract OmniRefer {
    address public owner;
    uint256 public joinFee    = 0;
    uint256 public rewardBps  = 1000; // 10%
    mapping(address => address) public referrer;
    mapping(address => uint256) public earnings;
    mapping(address => uint256) public referralCount;
    mapping(address => bool)    public registered;
    event Registered(address indexed user, address indexed ref);
    event RewardPaid(address indexed ref, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    constructor() { owner = msg.sender; registered[owner] = true; }
    modifier onlyOwner() { require(msg.sender == owner, "Not owner"); _; }
    function register(address ref) external payable {
        require(msg.value >= joinFee, "Fee too low");
        require(!registered[msg.sender], "Already registered");
        registered[msg.sender] = true;
        if (ref != address(0) && registered[ref] && ref != msg.sender) {
            referrer[msg.sender] = ref;
            uint256 reward = msg.value * rewardBps / 10000;
            earnings[ref] += reward;
            referralCount[ref]++;
            emit RewardPaid(ref, reward);
        }
        emit Registered(msg.sender, ref);
    }
    function withdraw() external {
        uint256 amt = earnings[msg.sender];
        require(amt > 0, "No earnings");
        earnings[msg.sender] = 0;
        payable(msg.sender).transfer(amt);
        emit Withdrawn(msg.sender, amt);
    }
    function collect() external onlyOwner { payable(owner).transfer(address(this).balance); }
}