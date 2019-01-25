pragma solidity ^0.5.0;

contract Bounties {
    address public owner;

    Bounty[] public bounties;
    Submission[] public submissions;

    mapping(uint => uint[]) bountySubmissions;
    mapping(address => uint[]) userBounties;
    mapping(address => uint[]) userSubmissions;

    enum BountyStatuses {
        Draft,
        Active,
        Closed
    }

    enum SubmissionStatuses {
        New,
        Accepted,
        Rejected
    }

    struct Bounty {
        address payable issuer;
        BountyStatuses status;
        string data;
        uint reward;
        uint balance;
    }

    struct Submission {
        address payable submitter;
        SubmissionStatuses status;
        string data;
    }

    modifier valueNotZero(uint _value) {
        require(_value != 0);
        _;
    }

    modifier checkValueTransferred(uint _amount) {
        require((_amount * 1 wei) == msg.value);
        _;
    }

    modifier onlyIssuer(uint _bountyId) {
        require(msg.sender == bounties[_bountyId].issuer);
        _;
    }

    modifier onlySubmitter(uint _bountyId) {
        require(msg.sender != bounties[_bountyId].issuer);
        _;
    }

    modifier checkBountiesOverflow() {
        require((bounties.length + 1) > bounties.length);
        _;
    }

    modifier checkBountiesIndex(uint _index){
        require(_index < bounties.length);
        _;
    }

    modifier checkBountyStatus(uint _bountyId, BountyStatuses _status) {
        require(bounties[_bountyId].status == _status);
        _;
    }

    modifier checkRewardDeposit(uint _bountyId) {
        require(bounties[_bountyId].balance >= bounties[_bountyId].reward);
        _;
    }

    modifier checkSubmissionsOverflow() {
        require((submissions.length + 1) > submissions.length);
        _;
    }

    modifier checkSubmissionsIndex(uint _index) {
        require(_index < submissions.length);
        _;
    }

    modifier checkSubmissionStatus(uint _submissionId, SubmissionStatuses _status) {
        require(submissions[_submissionId].status == _status);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function createBounty(string memory _data, uint256 _reward)
        public
        valueNotZero(_reward)
        checkBountiesOverflow
        returns (uint)
    {
        Bounty memory bounty = Bounty(msg.sender, BountyStatuses.Draft, _data, _reward, 0);
        uint bountyId = bounties.push(bounty) - 1;
        userBounties[msg.sender].push(bountyId);
        // BountyIssued(bounties.length - 1);
        return bountyId;
    }

    function activateBounty(uint _bountyId, uint _value)
        payable
        public
        onlyIssuer(_bountyId)
        checkBountiesIndex(_bountyId)
        checkValueTransferred(_value)
    {
        bounties[_bountyId].balance += _value;
        require(bounties[_bountyId].balance >= bounties[_bountyId].reward);
        bounties[_bountyId].status = BountyStatuses.Active;
        // BountyActivated(_bountyId, msg.sender);
    }

    function closeBounty(uint _bountyId)
        public
        onlyIssuer(_bountyId)
        checkBountiesIndex(_bountyId)
    {
        bounties[_bountyId].status = BountyStatuses.Closed;
        uint refundAmount = bounties[_bountyId].balance;
        bounties[_bountyId].balance = 0;
        if (refundAmount > 0 && bounties[_bountyId].issuer != address(0)) {
            bounties[_bountyId].issuer.transfer(refundAmount);
        }
        // BountyKilled(_bountyId, msg.sender);
    }

    function createSubmission(uint _bountyId, string memory _data)
        public
        checkBountiesIndex(_bountyId)
        checkBountyStatus(_bountyId, BountyStatuses.Active)
        checkSubmissionsOverflow()
        onlySubmitter(_bountyId)
    {
        Submission memory submission = Submission(msg.sender, SubmissionStatuses.New, _data);
        uint sId = submissions.push(submission) - 1;
        bountySubmissions[_bountyId].push(sId);
        userSubmissions[msg.sender].push(sId);
        // BountyFulfilled(_bountyId, msg.sender, (submissions.length - 1));
    }

    function acceptSubmission(uint _bountyId, uint _submissionId)
        public
        onlyIssuer(_bountyId)
        checkBountiesIndex(_bountyId)
        checkSubmissionsIndex(_submissionId)
        checkBountyStatus(_bountyId, BountyStatuses.Active)
        checkSubmissionStatus(_submissionId, SubmissionStatuses.New)
        checkRewardDeposit(_bountyId)
    {
        submissions[_submissionId].status = SubmissionStatuses.Accepted;
        uint rewardAmount = bounties[_bountyId].reward;
        bounties[_bountyId].balance -= rewardAmount;
        if (submissions[_submissionId].submitter != address(0)) {
            submissions[_submissionId].submitter.transfer(rewardAmount);
        }
        // SubmissionAccepted(_bountyId, msg.sender, _submissionId);
    }

    function rejectSubmission(uint _bountyId, uint _submissionId)
        public
        onlyIssuer(_bountyId)
        checkBountiesIndex(_bountyId)
        checkSubmissionsIndex(_submissionId)
        checkBountyStatus(_bountyId, BountyStatuses.Active)
        checkSubmissionStatus(_submissionId, SubmissionStatuses.New)
    {
        submissions[_submissionId].status = SubmissionStatuses.Rejected;
        // SubmissionRejected(_bountyId, msg.sender, _submissionId);
    }

    function getCountBounties()
        public
        view
        returns (uint)
    {
        return bounties.length;
    }

    function getBounty(uint _id)
        public
        view
        returns (
            uint id,
            address payable issuer,
            BountyStatuses status,
            string memory data,
            uint reward,
            uint balance
        )
    {
        Bounty memory bounty = bounties[_id];
        return (
            _id,
            bounty.issuer,
            bounty.status,
            bounty.data,
            bounty.reward,
            bounty.balance
        );
    }

    function getCountMyBounties()
        public
        view
        returns (uint)
    {
        return userBounties[msg.sender].length;
    }

    function getMyBounty(uint _index)
        public
        view
        returns (
            uint id,
            address payable issuer,
            BountyStatuses status,
            string memory data,
            uint reward,
            uint balance
        )
    {
        uint bountyId = userBounties[msg.sender][_index];
        Bounty memory bounty = bounties[bountyId];
        return (
            bountyId,
            bounty.issuer,
            bounty.status,
            bounty.data,
            bounty.reward,
            bounty.balance
        );
    }

    function getCountMySubmissions()
        public
        view
        returns (uint)
    {
        return userSubmissions[msg.sender].length;
    }

    function getMySubmission(uint _index)
        public
        view
        returns (
            uint id,
            SubmissionStatuses status,
            string memory data
        )
    {
        uint submissionId = userSubmissions[msg.sender][_index];
        Submission memory submission = submissions[submissionId];
        return (
            submissionId,
            submission.status,
            submission.data
        );
    }
}