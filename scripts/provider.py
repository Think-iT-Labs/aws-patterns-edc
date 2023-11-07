import requests
from dotenv import load_dotenv
import os


def create_asset(base_url, api_key):

    asset_url = base_url+'/assets'
    myobj = {
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
    asset_response = requests.post(
        asset_url, json=myobj, headers={"x-api-key": api_key})
    if asset_response.status_code == 200:
        asset_json = asset_response.json()
        return asset_json["@id"]
    else:
        raise Exception(
            f"Asset creation failed with status code {asset_response.status_code}")


'''{
  "@context": {
    "edc": "https://w3id.org/edc/v0.0.1/ns/"
  },
  "policy": {
    "@context": "http://www.w3.org/ns/odrl.jsonld",
    "@type": "Set",
    "uid": "example-policy-7000",
    "permission": [
      {
        "target": "20be3a74-8aaf-4e7e-9458-5a0268414973",
        "action": "USE",# Use or DISPLAY as env variable 
        "constraint": []
      }
    ]
  }
}'''


def create_policy(base_url, api_key, asset_id):

    policy_url = base_url+'/policydefinitions'
    myobj = {
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
    policy_response = requests.post(
        policy_url, json=myobj, headers={"x-api-key": api_key})
    # policy_json = policy_response.json()
    # return (policy_json["@id"])
    if policy_response.status_code == 200:
        policy_json = policy_response.json()
        return policy_json["@id"]
    else:
        raise Exception(
            f"Asset creation failed with status code {policy_response.status_code}")


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
    contract_definition_response = requests.post(
        contract_definition_url, json=myobj, headers={"x-api-key": api_key})
    # contract_definition_json = contract_definition_response.json()
    # return (contract_definition_json["@id"])
    if contract_definition_response.status_code == 200:
        contract_definition_json = contract_definition_response.json()
        return contract_definition_json["@id"]
    else:
        raise Exception(
            f"Asset creation failed with status code {contract_definition_response.status_code}")


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
    print(type(asset_id))
    print(policy_id)
    print(type(policy_id))
    print(contract_definition_id)
    print(type(contract_definition_id))
