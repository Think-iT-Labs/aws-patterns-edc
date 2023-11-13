
## Dependencies
- `requests`: Used for making HTTP requests to the API.
- `dotenv`: Used for loading environment variables from a .env file.

## The provider script

### Overview
This script provides functionalities for creating assets, policies, and contract definitions using the API.

### Usage
1. Set up your environment variables in the .env.provider file.
2. Run the script `provider.py`.

### Functions
1. **create_asset(base_url, api_key)**
   - Creates an asset.

2. **create_policy(base_url, api_key, asset_id)**
   - Creates a policy with a given asset ID.

3. **create_contract_definition(base_url, api_key, contract_definition_name, asset_id, policy_id)**
   - Creates a contract definition using the provided parameters.

## The consumer script

### Overview
This script manages the process of requesting a catalog, negotiating a contract, and initiating a data transfer using the API.

### Usage
1. Set up your environment variables in the .env.consumer file.
2. Run the script `consumer.py`.

### Functions
1. **request_catalog(base_url, provider_url, api_key)**
   - Requests a catalog and extracts contract and asset IDs.

2. **process_id(contract_ids_dict)**
   - Prompts the user to input a contract ID and retrieves corresponding asset and action type.

3. **create_contract_negotiation(provider_url, provider_id, consumer_id, contract_id, asset_id, action_type)**
   - Initiates a contract negotiation request.

4. **check_contract_negotiation(contract_negotiation_id)**
   - Checks the status of a contract negotiation until it is "VERIFIED".

5. **transfer_process(provider_url, provider_id, consumer_id, contract_id, asset_id)**
   - Initiates a transfer process.

### Main Execution
1. The script loads environment variables and prints the contract IDs available.
2. It prompts the user to input a contract ID and proceeds with the contract negotiation and data transfer process.