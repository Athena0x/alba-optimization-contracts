### Instructions for Testing in Remix IDE

1. **Access Remix**:
   - Open your web browser and go to https://remix.ethereum.org.
   - No installation is required; Remix runs directly in the browser.

2. **Upload Contracts**:
   - In the left-hand File Explorer, click the "+" icon to create a new file.
   - Name the files `BaselineAlba.sol`, `OptimizedAlba.sol`, and `HighlyOptimizedAlba.sol`.
   - Copy the contents of each `.sol` file from your GitHub repository and paste them into the respective files.

3. **Compile the Code**:
   - Go to the "Solidity Compiler" tab on the left.
   - Select compiler version 0.8.0 from the dropdown menu.
   - Click the "Compile" button for each contract to ensure there are no syntax errors.

4. **Deploy the Contracts**:
   - Navigate to the "Deploy & Run Transactions" tab.
   - Set the environment to "JavaScript VM (Shanghai)" to simulate an Ethereum network.
   - Under "Contract," select each compiled contract (e.g., `BaselineAlba`) and click "Deploy."
   - Note the gas costs displayed in the console after deployment (e.g., transaction cost, execution cost).

5. **Interact with the Contracts**:
   - After deployment, the contract instances will appear in the "Deployed Contracts" section.
   - For each contract, call the `submitProof` function with the following test inputs:
     - `BaselineAlba`: `id` = "0x1", `stateHash` = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", `fullProof` = "0x5678..." (a 100-byte string, e.g., repeated "56" for simplicity).
     - `OptimizedAlba`: `id` = "0x1", `stateHash` = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", `sigP` = "0x5678...", `sigV` = "0x9abc...".
     - `HighlyOptimizedAlba`: `id` = "0x1", `stateHash` = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", `isValid` = `true`.
   - Record the gas costs for each `submitProof` call in the Remix console.

6. **Finalize and Measure Total Costs**:
   - Advance the block number by making a few dummy transactions (e.g., send Ether to yourself) to exceed the 100-block challenge period.
   - Call the `finalizeProof` function with `id` = "0x1" for each contract.
   - Sum the gas costs of `submitProof` and `finalizeProof` to get the total gas usage for the optimistic case (no challenge).

7. **Analyze Results**:
   - Compare the gas costs across the three contracts. Expected values are approximately:
     - BaselineAlba: ~1,283,034 gas (deployment).
     - OptimizedAlba: ~963,636 gas (deployment).
     - HighlyOptimizedAlba: ~947,167 gas (deployment).
   - Note any deviations and adjust inputs or logic if needed.