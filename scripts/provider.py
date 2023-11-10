import requests
from dotenv import load_dotenv
import os

dotenv_path = ".env.provider"
load_dotenv(dotenv_path=dotenv_path)
access_key_id = os.getenv('ACCESS_KEY_ID')
secret_access_key = os.getenv('SECRET_ACCESS_KEY')
edc_name = os.getenv('EDC_NAME')
base_url = os.getenv('BASE_URL')
api_key = os.getenv('API_KEY')
provider_bucket_name = os.getenv('PROVIDER_BUCKET_NAME')
bucket_region = os.getenv('BUCKET_REGION')
key_name = os.getenv('KEY_NAMEadd')
policy_name = os.getenv('POLICY_NAME')
permission_action = os.getenv('PERMISSION_ACTION')
contract_definition_name = os.getenv('CONTRACT_DEFINITION_NAME')


def make_api_request(url, payload, api_key):
    """
    Make an HTTP POST request to a specified URL with the given payload and API
    key.

    Args:
        url (str): The URL  for the API request.
        payload (dict): The data to send in the request body as JSON.
        api_key (str): The API key for authentication.

    Returns:
        str: The ID from the API response if successful.

    Raises:
        Exception: If the request fails or the JSON response cannot be parsed.
    """
    try:
        response = requests.post(url, json=payload, headers={
                                 "x-api-key": api_key})
        response.raise_for_status()
        response_json = response.json()
        if "@id" in response_json:
            return response_json["@id"]
        else:
            raise Exception("Invalid response from the API")
    except requests.exceptions.RequestException as e:
        raise Exception(f"Request to {url} failed: {e}")
    except ValueError as e:
        raise Exception(f"Failed to parse JSON response: {e}")


def create_asset(base_url, api_key):
    """
    Creates an asset by making an API request.

    Args:
        base_url (str): The base URL for the API.
        api_key (str): The API key for authentication.

    Returns:
        str: The ID of the created asset.
    """
    asset_url = base_url+'/assets'
    payload = {
        "@context": {
            "edc": "https://w3id.org/edc/v0.0.1/ns/"
        },
        "asset": {
            "edc:properties": {
                "edc:contenttype": "application/json",
                "edc:name": edc_name
            }
        },
        "dataAddress": {
            "edc:type": "AmazonS3",
            "name": edc_name,
            "bucketName": provider_bucket_name,
            "keyName": key_name,
            "region": bucket_region,
            "accessKeyId": access_key_id,
            "secretAccessKey": secret_access_key
        }
    }
    asset_id = make_api_request(asset_url, payload, api_key)
    return asset_id


def create_policy(base_url, api_key, asset_id):
    """
    Create a policy by making an API request.

    Args:
        base_url (str): The base URL for the API.
        api_key (str): The API key for authentication.
        asset_id (str): The ID of the associated asset.

    Returns:
        str: The ID of the created policy.
    """
    policy_url = base_url+'/policydefinitions'
    payload = {
        "@context": {
            "edc": "https://w3id.org/edc/v0.0.1/ns/"
        },
        "policy": {
            "@context": "http://www.w3.org/ns/odrl.jsonld",
            "@type": "Set",
            "uid": policy_name,
            "permission": [
                {
                    "target": asset_id,
                    "action": permission_action,
                    "constraint": []
                }
            ]
        }
    }
    policy_id = make_api_request(policy_url, payload, api_key)
    return policy_id


def create_contract_definition(base_url, api_key, contract_definition_name, asset_id, policy_id):
    """ 
    Create a contract definition by making an API request.

    Args:
        base_url (str): The base URL for the API.
        api_key (str): The API key for authentication.
        contract_definition_name (str): The name of the contract definition.
        asset_id (str): The ID of the associated asset.
        policy_id (str): The ID of the associated policy.
    Returns:
        str: The ID of the created contract definition.
    """
    contract_definition_url = base_url+'/contractdefinitions'
    payload = {
        "@context": {
            "edc": "https://w3id.org/edc/v0.0.1/ns/"
        },
        "@id": contract_definition_name,
        "accessPolicyId": policy_id,
        "contractPolicyId": policy_id,
        "assetsSelector": [
            {
                "@type": "CriterionDto",
                "operandLeft": "https://w3id.org/edc/v0.0.1/ns/id",
                "operator": "=",
                "operandRight": asset_id
            }]
    }
    contract_definition_id = make_api_request(
        contract_definition_url, payload, api_key)
    return contract_definition_id


if __name__ == "__main__":
    asset_id = create_asset(base_url, api_key)
    policy_id = create_policy(base_url, api_key, asset_id)
    contract_definition_id = create_contract_definition(
        base_url, api_key, contract_definition_name, asset_id, policy_id)

    print("Asset ID:", asset_id)
    print("Policy ID:", policy_id)
    print("Contract Definition ID:", contract_definition_id)
