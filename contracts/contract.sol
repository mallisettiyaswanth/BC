// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MyContract {
    uint256 public noOfCampaigns = 0;
    address public manager;
    Campaign[] public campaigns;

    constructor() {
        manager = msg.sender;
    }

    struct Request {
        string description;
        uint256 amount;
        bool complete;
        mapping(address => bool) approvals;
        uint256 approvalCount;
    }

    struct Campaign {
        uint256 minContribution;
        mapping(address => bool) contributors; 
        mapping(uint256 => Request) requests;  
        uint256 numRequests;                   
        uint256 numContributors;               
        uint256 contribution;  
    }

    modifier restrictToManager {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    modifier campaignExists(uint256 _campaignIndex) {
        require(_campaignIndex < campaigns.length, "Campaign does not exist");
        _;
    }

    modifier restrictToContributors(uint256 _campaignIndex) {
        require(campaigns[_campaignIndex].contributors[msg.sender], "Only contributors allowed");
        _;
    }

    modifier requestExists(uint256 _campaignIndex, uint256 _requestIndex)  {
        require(_requestIndex < campaigns[_campaignIndex].numRequests, "Request does not exist"); 
        _;
    }

    function createCampaign(uint256 _minContribution) public restrictToManager {
        Campaign storage newCampaign = campaigns.push();
        newCampaign.minContribution = _minContribution;
        newCampaign.numRequests = 0;  
    }

    function contribute(uint256 _campaignIndex) public payable campaignExists(_campaignIndex) {
        require(msg.value >= campaigns[_campaignIndex].minContribution, "Contribution too low");
        Campaign storage campaign = campaigns[_campaignIndex];
        campaign.contribution += msg.value;
        if (!campaign.contributors[msg.sender]) {
            campaign.contributors[msg.sender] = true;
            campaign.numContributors++;
        }
    }

    function createRequest(uint256 _campaignIndex, string memory _description, uint256 amount) 
        public 
        campaignExists(_campaignIndex) 
        restrictToManager 
    {
        Campaign storage campaign = campaigns[_campaignIndex];
        require(amount <= campaign.contribution, "Insufficient funds");
        Request storage newRequest = campaign.requests[campaign.numRequests];  
        newRequest.description = _description;
        newRequest.amount = amount;
        newRequest.approvalCount = 0;
        newRequest.complete = false;
        campaign.numRequests++;
    }

    function approveRequest(uint256 _campaignIndex, uint256 _requestIndex) public 
        campaignExists(_campaignIndex) 
        requestExists(_campaignIndex, _requestIndex) 
        restrictToContributors(_campaignIndex) 
    {
        Request storage request = campaigns[_campaignIndex].requests[_requestIndex];
        require(!request.approvals[msg.sender], "You have already approved this request");
        require(!request.complete, "Request already finalized");
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 _campaignIndex, uint256 _requestIndex) public 
        campaignExists(_campaignIndex) 
        requestExists(_campaignIndex, _requestIndex) 
        restrictToManager  
    {
        Campaign storage campaign = campaigns[_campaignIndex];
        Request storage request = campaign.requests[_requestIndex];
        uint256 numContributors = campaign.numContributors;
        uint256 numApprovals = request.approvalCount;

        require(numApprovals > numContributors / 2, "Not enough approvals");
        require(!request.complete, "Request already completed");

        request.complete = true;        
        payable(manager).transfer(request.amount);
        campaign.contribution -= request.amount;
    }
}
