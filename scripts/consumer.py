import requests
from dotenv import load_dotenv
import os
import time


def make_api_request(url, payload, api_key):

    response = requests.post(url, json=payload, headers={"x-api-key": api_key})
    response.raise_for_status()

    return (response.json())


def request_catalog(base_url, provider_url, api_key):
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
    for dataset in datasets:
        permissions = dataset.get("odrl:hasPolicy", [])
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

    contract_id = input("Contract ID = ")

    asset_id = contract_ids_dict[contract_id]["asset_id"]
    action_type = contract_ids_dict[contract_id]["action_type"]
    return (contract_id, asset_id, action_type)


def create_contract_negociation(provider_url, provider_id, consumer_id,
                                contract_id, asset_id, action_type):
    myobj = {
        "@context": {
            "edc": "https://w3id.org/edc/v0.0.1/ns/"
        },
        "@type": "https://w3id.org/edc/v0.0.1/ns/ContractRequest",
        "connectorAddress": provider_url,
        "protocol": "dataspace-protocol-http",
        "providerId": provider_id,
        "connectorId": consumer_id,
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
                                                 myobj, api_key)
    return contract_negotiation_json["@id"]


def check_contract_negociation(contract_negotiation_id):

    contract_negotiation_url = base_url + \
        '/contractnegotiations/'+contract_negotiation_id
    verified = False
    while (verified == False):
        contract_negotiation_response = requests.get(
            contract_negotiation_url, headers={"x-api-key": api_key})
        if contract_negotiation_response.status_code == 200:
            contract_negotiation_json = contract_negotiation_response.json()
        time.sleep(2)
        state = contract_negotiation_json["edc:state"]
        print(state)
        if state == "VERIFIED":
            verified = True
            break

    agreement_id = contract_negotiation_json["edc:contractAgreementId"]
    negotiation_state = contract_negotiation_json["edc:state"]
    return (agreement_id, negotiation_state)


def transfer_process(provider_url, provider_id, agreement_id, asset_id):
    transfer_process_url = base_url+'/transferprocesses'
    myobj = {
        "@context": {
            "edc": "https://w3id.org/edc/v0.0.1/ns/"
        },
        "@type": "https://w3id.org/edc/v0.0.1/ns/TransferRequest",
        "protocol": "dataspace-protocol-http",
        "connectorAddress": provider_url,
        "contractId": agreement_id,
        "connectorId": provider_id,
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
    transfer_process_json = make_api_request(
        transfer_process_url, myobj, api_key)
    return transfer_process_json["@id"]


if __name__ == "__main__":
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
    contract_ids, provider_id = request_catalog(
        base_url, provider_url, api_key)
    for key in contract_ids:
        print(key)
    contract_id, asset_id, action_type = process_id(contract_ids)

    contract_negotiation_id = create_contract_negociation(
        provider_url, provider_id, consumer_id, contract_id, asset_id, action_type)
    # print(contract_negotiation_id)
    agreement_id, negotiation_state = check_contract_negociation(
        contract_negotiation_id)
    transfer_process_id = transfer_process(
        provider_url, provider_id, agreement_id, asset_id)
    # print(transfer_process_id)
