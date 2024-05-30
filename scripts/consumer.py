import requests
from dotenv import load_dotenv
import os
import time

dotenv_path = ".env.consumer"
load_dotenv(dotenv_path=dotenv_path)
base_url = os.getenv('BASE_URL')
provider_url = os.getenv('PROVIDER_URL')
api_key = os.getenv('API_KEY')
consumer_id = os.getenv('CONSUMER_ID')
bucket_name = os.getenv('CONSUMER_BUCKET_NAME')
key_name = os.getenv('KEY_NAME')
bucket_region = os.getenv('BUCKET_REGION')
access_key_id = os.getenv('ACCESS_KEY_ID')
secret_access_key = os.getenv('SECRET_ACCESS_KEY')


def make_api_request(url, payload, api_key):
    """
    Make an HTTP POST request to the specified URL with the given payload and 
    API key.

    Args:
        url (str): The URL for the API request.
        payload (dict): The data to send in the request body as JSON.
        api_key (str): The API key for authentication.

    Returns:
        dict: The JSON response from the API.

    Raises:
        requests.exceptions.RequestException: If the request fails.
    """
    try:
        response = requests.post(url, json=payload, headers={
                                 "x-api-key": api_key})
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"An error occurred while making the API request: {e}")
        return None


def request_catalog(base_url, provider_url, api_key):
    """
    Request catalog information from a provider.

    Args:
        base_url (str): The base URL for the API.
        provider_url (str): The URL of the provider's catalog.
        api_key (str): The API key for authentication.

    Returns:
        tuple: A tuple containing a dictionary of contract IDs and a dictionary 
        with the provider's ID.
    """
    catalog_request_url = base_url+'/catalog/request'
    myobj = {
        "@context": {
            "edc": "https://w3id.org/edc/v0.0.1/ns/"
        },
        "@type": "CatalogRequest",
        "providerUrl": provider_url,
        "protocol": "dataspace-protocol-http"
    }
    catalog_json = make_api_request(catalog_request_url, myobj, api_key)
    contract_asset_dict = dict()
    datasets = catalog_json.get("dcat:dataset", [])
    if isinstance(datasets, dict):
        datasets = [datasets]

    for dataset in datasets:
        permissions = dataset.get("odrl:hasPolicy", [])
        if isinstance(permissions, dict):
            permissions = [permissions]
        for permission in permissions:
            contract_id = permission.get("@id", "")
            asset_id = permission.get("odrl:target", "")
            action_type = permission.get("odrl:permission", {}).get(
                "odrl:action", {}).get("odrl:type", "")
            contract_asset_dict.update(
                {contract_id: {"asset_id": asset_id, "action_type": action_type
                               }})

    providerID = catalog_json.get("edc:participantId", "")
    providerID_set = {"providerID": providerID}
    return (contract_asset_dict, providerID_set)


def process_id(contract_ids_dict):
    """
    Process a contract ID and extract asset and action type.

    Args:
        contract_ids_dict (dict): A dictionary of contract IDs with associated asset and action type.

    Returns:
        tuple: A tuple containing contract ID, asset ID, and action type.
    """
    contract_id = input("Contract ID = ")
    asset_id = contract_ids_dict[contract_id]["asset_id"]
    action_type = contract_ids_dict[contract_id]["action_type"]
    return (contract_id, asset_id, action_type)


def create_contract_negociation(provider_url, provider_id, consumer_id,
                                contract_id, asset_id, action_type):
    """
    Create a contract negotiation with the provider.

    Args:
        provider_url (str): The URL of the provider's catalog.
        provider_id (str): The provider's ID.
        consumer_id (str): The consumer's ID.
        contract_id (str): The contract ID.
        asset_id (str): The asset ID.
        action_type (str): The action type.

    Returns:
        str: The ID of the created contract negotiation.
    """

    print(provider_id)
    print(consumer_id)
    payload = {
        "@context": {
            "edc": "https://w3id.org/edc/v0.0.1/ns/"
        },
        "@type": "https://w3id.org/edc/v0.0.1/ns/ContractRequest",
        "connectorAddress": provider_url,
        "protocol": "dataspace-protocol-http",
        "providerId": provider_id["providerID"],
        "connectorId": provider_id["providerID"],
        "offer": {
            "assetId": asset_id,
            "offerId": contract_id,
            "policy": {
                "@context": "http://www.w3.org/ns/odrl.jsonld",
                "@type": "odrl:Set",
                "permission": {
                    "odrl:target": asset_id,
                    "odrl:action": {
                        "odrl:type": action_type
                    }
                },
                "prohibition": [],
                "obligation": [],
                "target": asset_id
            }
        }
    }
    contract_negotiation_url = base_url+'/contractnegotiations'
    contract_negotiation_json = make_api_request(contract_negotiation_url,
                                                 payload, api_key)
    print(contract_negotiation_json)
    return contract_negotiation_json["@id"]


def send_request(url):
    """
    Send an HTTP GET request to the specified URL with the API key.

    Args:
        url (str): The URL for the GET request.

    Returns:
        dict or None: The JSON response from the API, or None if the request
        fails.
    """
    try:
        response = requests.get(url, headers={"x-api-key": api_key})
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"An error occurred while sending the request: {e}")
        return None


def is_negotiation_verified(negotiation):
    """
    Check if a contract negotiation is verified.

    Args:
        negotiation (dict): The contract negotiation data.

    Returns:
        bool: True if the negotiation is verified, False otherwise.
    """
    if "edc:state" in negotiation and negotiation["edc:state"] == "FINALIZED":
        return True
    return False


def parse_negotiation(negotiation):
    """
    Parse contract negotiation data to extract agreement ID and negotiation 
    state.

    Args:
        negotiation (dict): The contract negotiation data.

    Returns:
        tuple: A tuple containing agreement ID and negotiation state.
    """
    if "edc:contractAgreementId" in negotiation and "edc:state" in negotiation:
        return negotiation["edc:contractAgreementId"], negotiation["edc:state"]
    return None, None


def check_contract_negotiation(contract_negotiation_id):
    """
    Check the status of a contract negotiation.

    Args:
        contract_negotiation_id (str): The ID of the contract negotiation.

    Returns:
        tuple: A tuple containing agreement ID and negotiation state.
    """
    contract_negotiation_url = base_url + \
        '/contractnegotiations/' + contract_negotiation_id

    iteration = 0
    max_iterations = 10

    while iteration < max_iterations:
        negotiation = send_request(contract_negotiation_url)
        if negotiation is None:
            break

        time.sleep(2)
        print(negotiation["edc:state"])
        if is_negotiation_verified(negotiation):
            agreement_id, negotiation_state = parse_negotiation(negotiation)
            return agreement_id, negotiation_state

    return None, None


def transfer_process(provider_url, provider_id, agreement_id, asset_id):
    """
    Initiate a data transfer process.

    Args:
        provider_url (str): The URL of the provider's catalog.
        provider_id (str): The provider's ID.
        agreement_id (str): The agreement ID.
        asset_id (str): The asset ID.

    Returns:
        str: The ID of the transfer process.
    """
    transfer_process_url = base_url+'/transferprocesses'
    myobj = {
        "@context": {
            "edc": "https://w3id.org/edc/v0.0.1/ns/"
        },
        "@type": "https://w3id.org/edc/v0.0.1/ns/TransferRequest",
        "protocol": "dataspace-protocol-http",
        "connectorAddress": provider_url,
        "contractId": agreement_id,
        "connectorId": provider_id["providerID"],
        "assetId": asset_id,
        "dataDestination": {
            "type": "AmazonS3",
            "bucketName": bucket_name,
            "keyName": key_name,
            "region": bucket_region,
            "accessKeyId": access_key_id,
            "secretAccessKey": secret_access_key
        }
    }
    print(provider_id)
    transfer_process_json = make_api_request(
        transfer_process_url, myobj, api_key)
    return transfer_process_json["@id"]


if __name__ == "__main__":

    contract_ids, provider_id = request_catalog(
        base_url, provider_url, api_key)
    for key in contract_ids:
        print(key)
    contract_id, asset_id, action_type = process_id(contract_ids)

    contract_negotiation_id = create_contract_negociation(
        provider_url, provider_id, consumer_id, contract_id, asset_id,
        action_type)
    print("contract negotiation ID: ", contract_negotiation_id)
    agreement_id, negotiation_state = check_contract_negotiation(
        contract_negotiation_id)
    transfer_process_id = transfer_process(
        provider_url, provider_id, agreement_id, asset_id)
    print("Transfer process ID: ", transfer_process_id)
