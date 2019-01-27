pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Pausable.sol";
import "./Ownable.sol";

contract Bounties is Pausable, Ownable {
    // SafeMath is a library that allows overflow-safe arithmetic operations
    using SafeMath for uint;

    Bounty[] public bounties;
    Submission[] public submissions;

    // one-to-many mapping for bounty-submissions relation
    mapping(uint => uint[]) bountySubmissions;
    // one-to-many mapping for user-bounties relation
    mapping(address => uint[]) userBounties;
    // one-to-many mapping for user-subimssions relation
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
        // who created the bounty
        address payable issuer;
        // bounty state
        BountyStatuses status;
        // bounty description
        string data;
        // payout amount
        uint reward;
        // current funds allocated for the bounty
        uint balance;
    }

    struct Submission {
        // who created the submission
        address payable submitter;
        // submission state
        SubmissionStatuses status;
        // submission description
        string data;
    }

    event BountyCreated(address issuer, uint id);
    event BountyActivated(uint id, uint balance);
    event BountyClosed(uint id, uint balance, uint refundAmount);
    event SubmissionCreated(uint submissionId, uint bountyId, address submitter);
    event SubmissionAccepted(uint submissionId, uint bountyId, uint oldBalance, uint newBalance, uint rewardAmount);
    event SubmissionRejected(uint submissionId, uint bountyId);

    /**
     * @notice Checks if the provided value is not zero
     * @param _value The value to check against zero
     */
    modifier valueNotZero(uint _value) {
        require(_value != 0);
        _;
    }

    /**
     * @notice Checks whenever the current call has appropriate amount of funds transferred
     * @param _amount The value to check against amount of received funds
     */
    modifier checkValueTransferred(uint _amount) {
        require((_amount * 1 wei) == msg.value, 'Transfered value not matching amount provided in the request');
        _;
    }

    /**
     * @notice Makes sure the current call is done by bounty's issuer
     * @param _bountyId The bounty ID
     */
    modifier onlyIssuer(uint _bountyId) {
        require(msg.sender == bounties[_bountyId].issuer);
        _;
    }

    /**
     * @notice Makes sure the current call is done NOT by bounty's issuer
     * @param _bountyId The bounty ID
     */
    modifier onlySubmitter(uint _bountyId) {
        require(msg.sender != bounties[_bountyId].issuer);
        _;
    }

    /*
     * @notice Makes sure provided ID exists in the bounties storage
     * @dev I'm using array's sequential integers as IDs and not reordering the array,
     *      so it's possible to determine bounty existence with just a length lookup
     * @param _index The storage index
     */
    modifier checkBountiesIndex(uint _index) {
        require(_index < bounties.length);
        _;
    }

    /**
     * @notice Makes sure the bounty is in desirable statatus
     * @param _bountyId The bounty ID
     * @param _status Desirable status
     */
    modifier checkBountyStatus(uint _bountyId, BountyStatuses _status) {
        require(bounties[_bountyId].status == _status, 'Incompatible bounty status');
        _;
    }

    /**
     * @notice Makes sure the bounty has enough funds on balance to pay the reward
     * @param _bountyId The bounty ID
     */
    modifier checkRewardDeposit(uint _bountyId) {
        require(bounties[_bountyId].balance >= bounties[_bountyId].reward, 'Not enough funds on balance to pay the reward');
        _;
    }

    /*
     * @notice Makes sure provided ID exists in the submissions storage
     * @dev I'm using array's sequential integers as IDs and not reordering the array,
     *      so it's possible to determine submission existence with just a length lookup
     * @param _index The storage index
     */
    modifier checkSubmissionsIndex(uint _index) {
        require(_index < submissions.length);
        _;
    }

    /**
     * @notice Makes sure the submission is in desirable status
     * @param _submissionId The submission ID
     * @param _status Desirable status
     */
    modifier checkSubmissionStatus(uint _submissionId, SubmissionStatuses _status) {
        require(submissions[_submissionId].status == _status);
        _;
    }

    /**
     * @notice Adds a new bounty
     * @param _data Bounty description
     * @param _reward The reward amount that will be payed out to accepted submission
     */
    function createBounty(string memory _data, uint256 _reward)
        public
        valueNotZero(_reward)
        whenNotPaused
        returns (uint)
    {
        Bounty memory bounty = Bounty(msg.sender, BountyStatuses.Draft, _data, _reward, 0);
        uint bountyId = bounties.push(bounty).sub(1);
        userBounties[msg.sender].push(bountyId);
        emit BountyCreated(msg.sender, bountyId);
        return bountyId;
    }

    /**
     * @notice Activates the bounty and tops up bounty's balance according to the received funds
     * @dev The bounty has to be in the "draft" state and only the bounty's issuer can call this
     * @param _bountyId The bounty ID
     * @param _value The amount of funds that has to be provided along with the call
     */
    function activateBounty(uint _bountyId, uint _value)
        payable
        public
        whenNotPaused
        onlyIssuer(_bountyId)
        checkBountiesIndex(_bountyId)
        checkBountyStatus(_bountyId, BountyStatuses.Draft)
        checkValueTransferred(_value)
    {
        bounties[_bountyId].balance = bounties[_bountyId].balance.add(_value);
        require(bounties[_bountyId].balance >= bounties[_bountyId].reward, "Not enough funds on balance to match reward");
        bounties[_bountyId].status = BountyStatuses.Active;
        emit BountyActivated(_bountyId, bounties[_bountyId].balance);
    }

    /**
     * @notice Closes the bounty and refunds funds to the issuer, if there's any left on bounty's balance
     * @param _bountyId The bounty ID
     */
    function closeBounty(uint _bountyId)
        public
        whenNotPaused
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

    /**
     * @notice Creates a new submission
     * @dev The bounty has to be "active" and the submitter shouldn't be the issuer of the bounty
     * @param _bountyId The bounty ID
     * @param _data Submission description
     */
    function createSubmission(uint _bountyId, string memory _data)
        public
        whenNotPaused
        checkBountiesIndex(_bountyId)
        checkBountyStatus(_bountyId, BountyStatuses.Active)
        onlySubmitter(_bountyId)
    {
        Submission memory submission = Submission(msg.sender, SubmissionStatuses.New, _data);
        uint sId = submissions.push(submission).sub(1);
        bountySubmissions[_bountyId].push(sId);
        userSubmissions[msg.sender].push(sId);
        emit SubmissionCreated(sId, _bountyId, msg.sender);
    }

    /**
     * @notice Accepts the submission, closing the bounty and pays out the reward
     * @dev The bounty has to be "active" and the submission has to be in "new" status
     * @param _bountyId The bounty ID
     * @param _submissionId The submission ID
     */
    function acceptSubmission(uint _bountyId, uint _submissionId)
        public
        whenNotPaused
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
        bounties[_bountyId].balance = bounties[_bountyId].balance.sub(rewardAmount);
        uint newBalance = bounties[_bountyId].balance;
        if (rewardAmount > 0 && submissions[_submissionId].submitter != address(0)) {
            submissions[_submissionId].submitter.transfer(rewardAmount);
        }
        emit SubmissionAccepted(_submissionId, _bountyId, oldBalance, newBalance, rewardAmount);
    }

    /**
     * @notice Rejects the submission
     * @dev The bounty has to be "active" and the submission has to be in "new" status
     * @param _bountyId The bounty ID
     * @param _submissionId The submission ID
     */
    function rejectSubmission(uint _bountyId, uint _submissionId)
        public
        whenNotPaused
        onlyIssuer(_bountyId)
        checkBountiesIndex(_bountyId)
        checkSubmissionsIndex(_submissionId)
        checkBountyStatus(_bountyId, BountyStatuses.Active)
        checkSubmissionStatus(_submissionId, SubmissionStatuses.New)
    {
        submissions[_submissionId].status = SubmissionStatuses.Rejected;
        emit SubmissionRejected(_submissionId, _bountyId);
    }

    /**
     * @notice Get total count of bounties
     */
    function getCountBounties()
        public
        view
        returns (uint)
    {
        return bounties.length;
    }

    /**
     * @notice Get bounty by ID
     * @param _id The bounty ID
     */
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

    /**
     * @notice Get submission by ID
     * @param _id The submission ID
     */
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

    /**
     * @notice Get count of bounties issued by the sender
     */
    function getCountMyBounties()
        public
        view
        returns (uint)
    {
        return userBounties[msg.sender].length;
    }

    /**
     * @notice Get sender's bounty by numerical index
     * @dev Used for iteration on sender's bounties
     * @param _index Numerical index
     */
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

    /**
     * @notice Get count of submissions created by the sender
     */
    function getCountMySubmissions()
        public
        view
        returns (uint)
    {
        return userSubmissions[msg.sender].length;
    }

    /**
     * @notice Get sender's submission by numerical index
     * @dev Used for iteration on sender's submissions
     * @param _index Numerical index
     */
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

    /**
     * @notice Get count of submissions for the particular bounty
     * @param _id The bounty ID
     */
    function getCountBountySubmissions(uint _id)
        public
        view
        returns (uint)
    {
        return bountySubmissions[_id].length;
    }

    /**
     * @notice Get bounty's submission by numerical index
     * @dev Used for iteration on bounty's submissions
     * @param _id The bounty ID
     * @param _index Numerical index
     */
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