import requests
from dotenv import load_dotenv
import os


def make_api_request(url, payload, api_key):
    response = requests.post(url, json=payload, headers={"x-api-key": api_key})
    response.raise_for_status()
    response_json = response.json()
    return response_json["@id"]


def create_asset(base_url, api_key):

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
    id = make_api_request(asset_url, payload, api_key)
    return id


def create_policy(base_url, api_key, asset_id):

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
    id = make_api_request(policy_url, payload, api_key)
    return id


def create_contract_definition(base_url, api_key, contract_definition_name, asset_id, policy_id):

    contract_definition_url = base_url+'/contractdefinitions'
    myobj = {
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
    id = make_api_request(contract_definition_url, myobj, api_key)
    return id


if __name__ == "__main__":
    dotenv_path = ".env.provider"
    load_dotenv(dotenv_path=dotenv_path)
    access_key_id = os.getenv('ACCESS_KEY_ID')
    secret_access_key = os.getenv('SECRET_ACCESS_KEY')
    edc_name = os.getenv('EDC_NAME')
    base_url = os.getenv('BASE_URL')
    api_key = os.getenv('API_KEY')
    provider_bucket_name = os.getenv('PROVIDER_BUCKET_NAME')
    bucket_region = os.getenv('BUCKET_REGION')
    key_name = os.getenv('KEY_NAME')
    policy_name = os.getenv('POLICY_NAME')
    permission_action = os.getenv('PERMISSION_ACTION')
    contract_definition_name = os.getenv('CONTRACT_DEFINITION_NAME')
    print(contract_definition_name)

    asset_id = create_asset(base_url, api_key)
    policy_id = create_policy(base_url, api_key, asset_id)
    contract_definition_id = create_contract_definition(
        base_url, api_key, contract_definition_name, asset_id, policy_id)

    print(asset_id)
    print(policy_id)
    print(contract_definition_id)
