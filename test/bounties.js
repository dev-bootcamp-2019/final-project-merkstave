const Bounties = artifacts.require("Bounties");

// Function to verify that a contract call has failed (reverted) during execution
async function hasReverted(contractCall) {
  try {
    await contractCall;
    return false;
  } catch (e) {
    return /revert/.test(e.message);
  }
}

contract("Bounties", accounts => {
  var instance;

  const COWNER = accounts[0];

  const BDATA = 'Test bounty';
  const BISSUER = accounts[0];
  const BREWARD = web3.utils.toWei('1', 'ether');

  const SSUBMITTER = accounts[1];
  const SSUBMITTER2 = accounts[2];
  const SDATA = 'Test submission';

  beforeEach('deploy contract', async () => {
    instance = await Bounties.deployed();
  });

  it('sets the owner', async () => {
    assert.equal(await instance.owner.call(), COWNER);
  });

  it('creates bounty', async () => {
      let tx = await instance.createBounty(BDATA, BREWARD, { from: BISSUER });

      assert.equal(tx.logs[0].event, 'BountyCreated');
      assert.equal(tx.logs[0].args.issuer.toString(), BISSUER);
      assert.equal(tx.logs[0].args.id.toString(), 0);
  });

  it('activates bounty', async () => {
      let tx = await instance.activateBounty(0, BREWARD, { from: BISSUER, value: BREWARD });

      assert.equal(tx.logs[0].event, 'BountyActivated');
      assert.equal(tx.logs[0].args.id.toString(), 0);
      assert.equal(tx.logs[0].args.balance.toString(), BREWARD);
  });

  it('creates submission', async () => {
      let tx = await instance.createSubmission(0, SDATA, { from: SSUBMITTER });

      assert.equal(tx.logs[0].event, 'SubmissionCreated');
      assert.equal(tx.logs[0].args.submissionId.toString(), 0);
      assert.equal(tx.logs[0].args.bountyId.toString(), 0);
      assert.equal(tx.logs[0].args.submitter.toString(), SSUBMITTER);
  });

  it('reject submission', async () => {
      let tx = await instance.rejectSubmission(0, 0, { from: BISSUER });
      
      assert.equal(tx.logs[0].event, 'SubmissionRejected');
      assert.equal(tx.logs[0].args.submissionId.toString(), 0);
      assert.equal(tx.logs[0].args.bountyId.toString(), 0);
  });

  it('creates another submission', async () => {
      let tx = await instance.createSubmission(0, SDATA, { from: SSUBMITTER2 });

      assert.equal(tx.logs[0].event, 'SubmissionCreated');
      assert.equal(tx.logs[0].args.submissionId.toString(), 1);
      assert.equal(tx.logs[0].args.bountyId.toString(), 0);
      assert.equal(tx.logs[0].args.submitter.toString(), SSUBMITTER2);
  });

  it('accepts submission', async () => {
      let submitterOldBalance = await web3.eth.getBalance(SSUBMITTER2);
      let tx = await instance.acceptSubmission(0, 1, { from: BISSUER });
      let submitterNewBalance = await web3.eth.getBalance(SSUBMITTER2);

      assert.equal(tx.logs[0].event, 'SubmissionAccepted');
      assert.equal(tx.logs[0].args.submissionId.toString(), 1);
      assert.equal(tx.logs[0].args.bountyId.toString(), 0);
      assert.equal(tx.logs[0].args.oldBalance.toString(), BREWARD);
      assert.equal(tx.logs[0].args.newBalance.toString(), 0);
      assert.equal(tx.logs[0].args.rewardAmount.toString(), BREWARD);
      assert.equal((submitterNewBalance - submitterOldBalance), BREWARD);
  });

  it('creates another bounty', async () => {
      let tx = await instance.createBounty(BDATA, BREWARD, { from: BISSUER });

      assert.equal(tx.logs[0].event, 'BountyCreated');
      assert.equal(tx.logs[0].args.issuer.toString(), BISSUER);
      assert.equal(tx.logs[0].args.id.toString(), 1);
  });

  it('activates bounty', async () => {
      let tx = await instance.activateBounty(1, BREWARD, { from: BISSUER, value: BREWARD });

      assert.equal(tx.logs[0].event, 'BountyActivated');
      assert.equal(tx.logs[0].args.id.toString(), 1);
      assert.equal(tx.logs[0].args.balance.toString(), BREWARD);
  });

  it('closes bounty', async () => {
      let tx = await instance.closeBounty(1, { from: BISSUER });

      assert.equal(tx.logs[0].event, 'BountyClosed');
      assert.equal(tx.logs[0].args.id.toString(), 1);
      assert.equal(tx.logs[0].args.balance.toString(), 0);
      assert.equal(tx.logs[0].args.refundAmount.toString(), BREWARD);
  });

  it('pauses contract', async () => {
    await instance.pause();
    assert.ok(await hasReverted(
      instance.createBounty(BDATA, BREWARD, { from: BISSUER })
    ));
  });

  it('unpauses contract', async () => {
    await instance.unpause();
    assert.ok(await instance.createBounty(BDATA, BREWARD, { from: BISSUER }));
  });
});
