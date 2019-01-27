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

    event BountyCreated(address issuer, uint id);
    event BountyActivated(uint id, uint balance);
    event BountyClosed(uint id, uint balance, uint refundAmount);
    event SubmissionCreated(uint submissionId, uint bountyId, address submitter);
    event SubmissionAccepted(uint submissionId, uint bountyId, uint oldBalance, uint newBalance, uint rewardAmount);
    event SubmissionRejected(uint submissionId, uint bountyId);

    modifier valueNotZero(uint _value) {
        require(_value != 0);
        _;
    }

    modifier checkValueTransferred(uint _amount) {
        require((_amount * 1 wei) == msg.value, 'Transfered value not matching amount provided in the request');
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
        require(bounties[_bountyId].status == _status, 'Incompatible bounty status');
        _;
    }

    modifier checkRewardDeposit(uint _bountyId) {
        require(bounties[_bountyId].balance >= bounties[_bountyId].reward, 'Not enough funds on balance to pay the reward');
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
        emit BountyCreated(msg.sender, bountyId);
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
        require(bounties[_bountyId].balance >= bounties[_bountyId].reward, "Not enough balance to match reward");
        bounties[_bountyId].status = BountyStatuses.Active;
        emit BountyActivated(_bountyId, bounties[_bountyId].balance);
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
        emit BountyClosed(_bountyId, bounties[_bountyId].balance, refundAmount);
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
        emit SubmissionCreated(sId, _bountyId, msg.sender);
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
        uint oldBalance = bounties[_bountyId].balance;
        uint rewardAmount = bounties[_bountyId].reward;
        submissions[_submissionId].status = SubmissionStatuses.Accepted;
        bounties[_bountyId].status = BountyStatuses.Closed;
        bounties[_bountyId].balance -= rewardAmount;
        uint newBalance = bounties[_bountyId].balance;
        if (rewardAmount > 0 && submissions[_submissionId].submitter != address(0)) {
            submissions[_submissionId].submitter.transfer(rewardAmount);
        }
        emit SubmissionAccepted(_submissionId, _bountyId, oldBalance, newBalance, rewardAmount);
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
        emit SubmissionRejected(_submissionId, _bountyId);
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

    function getSubmission(uint _id)
        public
        view
        returns (
            uint id,
            address payable submitter,
            SubmissionStatuses status,
            string memory data
        )
    {
        Submission memory submission = submissions[_id];
        return (
            _id,
            submission.submitter,
            submission.status,
            submission.data
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
            address payable submitter,
            SubmissionStatuses status,
            string memory data
        )
    {
        uint submissionId = userSubmissions[msg.sender][_index];
        Submission memory submission = submissions[submissionId];
        return (
            submissionId,
            submission.submitter,
            submission.status,
            submission.data
        );
    }

    function getCountBountySubmissions(uint _id)
        public
        view
        returns (uint)
    {
        return bountySubmissions[_id].length;
    }

    function getBountySubmission(uint _id, uint _index)
        public
        view
        returns (
            uint id,
            address payable submitter,
            SubmissionStatuses status,
            string memory data
        )
    {
        uint submissionId = bountySubmissions[_id][_index];
        Submission memory submission = submissions[submissionId];
        return (
            submissionId,
            submission.submitter,
            submission.status,
            submission.data
        );
    }
}