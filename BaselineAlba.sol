pragma solidity ^0.8.0;


contract SimplifiedAlba {
 
    address public owner;
    bool private locked; // For reentrancy protection
    uint256 public constant CHALLENGE_PERIOD = 100; // 100 blocks for dispute period

    // Attestation struct for optimistic proof submission
    struct Attestation {
        bytes32 stateHash; // Hash of the payment channel state
        bytes sigP; // Signature from party P
        bytes sigV; // Signature from party V
        uint256 submissionBlock; // Block number of submission
        bool challenged; // Whether the attestation has been challenged
    }

    // Mapping to store attestations
    mapping(bytes32 => Attestation) public attestations;

    // Events
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
        // Basic validation (simplified signature check for Remix)
        require(stateHash != bytes32(0), "Invalid state hash");
        require(sigP.length > 0 && sigV.length > 0, "Invalid signatures");

        attestations[id] = Attestation({
            stateHash: stateHash,
            sigP: sigP,
            sigV: sigV,
            submissionBlock: block.number,
            challenged: false
        });

        emit ProofSubmitted(id, stateHash);
    }


    function challengeProof(
        bytes32 id,
        bytes32 stateHash,
        bytes calldata fullProof
    ) external nonReentrant {
        Attestation storage attestation = attestations[id];
        require(attestation.submissionBlock > 0, "Attestation does not exist");
        require(!attestation.challenged, "Already challenged");
        require(
            block.number <= attestation.submissionBlock + CHALLENGE_PERIOD,
            "Challenge period expired"
        );


        require(
            stateHash != attestation.stateHash,
            "State hash matches attestation"
        );


        attestation.challenged = true;

        emit ProofChallenged(id);
    }

    // Finalize the proof after the challenge period
    function finalizeProof(bytes32 id) external onlyOwner nonReentrant {
        Attestation storage attestation = attestations[id];
        require(attestation.submissionBlock > 0, "Attestation does not exist");
        require(
            block.number > attestation.submissionBlock + CHALLENGE_PERIOD,
            "Challenge period not expired"
        );

     
        bool success = !attestation.challenged;
        if (success) {
            // In a real implementation, update state or release funds
            // Here, we simply emit an event
            emit ProofFinalized(id, true);
        } else {
            emit ProofFinalized(id, false);
        }

        // Clean up storage to save gas
        delete attestations[id];
    }

    // Utility function to get attestation status
    function getProofStatus(bytes32 id) external view returns (bool exists, bool challenged, uint256 submissionBlock) {
        Attestation memory attestation = attestations[id];
        return (
            attestation.submissionBlock > 0,
            attestation.challenged,
            attestation.submissionBlock
        );
    }

    // Fallback and receive functions to handle Ether (optional for Remix)
    receive() external payable {}
    fallback() external payable {}
}