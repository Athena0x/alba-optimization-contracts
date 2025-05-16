pragma solidity ^0.8.0;


contract OptimizedAlba {
    address public owner;
    bool private locked;
    uint256 public constant CHALLENGE_PERIOD = 100;

    struct Attestation {
        bytes32 stateHash; // Hash of the latest state
        bytes32 sigHash; // Hash of signatures (optimistic case)
        uint256 submissionBlock;
        bool challenged;
    }

    mapping(bytes32 => Attestation) public attestations;

    event ProofSubmitted(bytes32 indexed id, bytes32 stateHash);
    event ProofChallenged(bytes32 indexed id);
    event ProofFinalized(bytes32 indexed id, bool success);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        owner = msg.sender;
        locked = false;
    }

 
    function submitProof(
        bytes32 id,
        bytes32 stateHash,
        bytes calldata sigP,
        bytes calldata sigV
    ) external nonReentrant {
        require(stateHash != bytes32(0), "Invalid state hash");
        bytes32 sigHash = keccak256(abi.encodePacked(sigP, sigV)); // Signed attestation as per idea
        attestations[id] = Attestation(stateHash, sigHash, block.number, false);
        emit ProofSubmitted(id, stateHash);
    }


    function challengeProof(
        bytes32 id,
        bytes32 stateHash,
        bytes calldata fullProof
    ) external nonReentrant {
        Attestation storage attestation = attestations[id];
        require(attestation.submissionBlock > 0, "No attestation");
        require(!attestation.challenged, "Already challenged");
        require(block.number <= attestation.submissionBlock + CHALLENGE_PERIOD, "Period expired");
        require(stateHash != attestation.stateHash, "State matches");
        attestation.challenged = true;
        emit ProofChallenged(id);
    }


    function finalizeProof(bytes32 id) external onlyOwner nonReentrant {
        Attestation storage attestation = attestations[id];
        require(attestation.submissionBlock > 0, "No attestation");
        require(block.number > attestation.submissionBlock + CHALLENGE_PERIOD, "Period not expired");
        bool success = !attestation.challenged;
        emit ProofFinalized(id, success);
        delete attestations[id];
    }

    function getProofStatus(bytes32 id) external view returns (bool, bool, uint256) {
        Attestation memory attestation = attestations[id];
        return (attestation.submissionBlock > 0, attestation.challenged, attestation.submissionBlock);
    }

    receive() external payable {}
    fallback() external payable {}
}