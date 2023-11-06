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
    asset_json = asset_response.json()
    return (asset_json["@id"])


if __name__ == "__main__":
    dotenv_path = ".env.provider"
    load_dotenv(dotenv_path=dotenv_path)
    edc_name = os.getenv('EDC_NAME')
    base_url = os.getenv('BASE_URL')
    api_key = os.getenv('API_KEY')
    provider_bucket_name = os.getenv('PROVIDER_BUCKET_NAME')
    key_name = os.getenv('KEY_NAME')
    id = create_asset(base_url, api_key)

    print(id)
