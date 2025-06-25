import argparse
import json
import base64
from datetime import datetime, timezone
from pathlib import Path
import jwt
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey, Ed25519PublicKey
from cryptography.hazmat.primitives import serialization

ASSETS_DIR = None
ISSUER_KEY_PATH = None
ISSUER_PUB_PATH = None
ISSUER_DID_PATH = None

# Helper: encode Ed25519 key to JWK

def get_issuer_did(domain):
    return f"did:web:issuer.{domain}"

def get_issuer_kid(domain):
    return f"did:web:issuer.{domain}#key-1"

def ed25519_private_to_jwk(private_key: Ed25519PrivateKey, kid: str):
    private_bytes = private_key.private_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PrivateFormat.Raw,
        encryption_algorithm=serialization.NoEncryption()
    )
    public_key = private_key.public_key()
    public_bytes = public_key.public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw
    )
    return {
        "kty": "OKP",
        "crv": "Ed25519",
        "kid": kid,
        "d": base64.urlsafe_b64encode(private_bytes).rstrip(b'=').decode(),
        "x": base64.urlsafe_b64encode(public_bytes).rstrip(b'=').decode()
    }

def ed25519_public_to_jwk(public_key: Ed25519PublicKey, kid: str):
    public_bytes = public_key.public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw
    )
    return {
        "kty": "OKP",
        "crv": "Ed25519",
        "kid": kid,
        "x": base64.urlsafe_b64encode(public_bytes).rstrip(b'=').decode()
    }

def regenerate_keys(domain):
    kid = get_issuer_kid(domain)
    private_key = Ed25519PrivateKey.generate()
    private_jwk = ed25519_private_to_jwk(private_key, kid)
    public_jwk = ed25519_public_to_jwk(private_key.public_key(), kid)
    with open(ISSUER_KEY_PATH, 'w') as f:
        json.dump(private_jwk, f, indent=2)
    with open(ISSUER_PUB_PATH, 'w') as f:
        json.dump(public_jwk, f, indent=2)
    print(f"Issuer key pair generated: {ISSUER_KEY_PATH}, {ISSUER_PUB_PATH}")
    return private_jwk, public_jwk

def update_issuer_did(public_jwk, domain):
    issuer_did = get_issuer_did(domain)
    kid = get_issuer_kid(domain)
    with open(ISSUER_DID_PATH, 'r') as f:
        did_doc = json.load(f)
    # Update the first verificationMethod's publicKeyJwk, id, and controller
    if did_doc['verificationMethod']:
        did_doc['verificationMethod'][0]['publicKeyJwk'] = public_jwk
        did_doc['verificationMethod'][0]['id'] = kid
        did_doc['verificationMethod'][0]['controller'] = issuer_did
    did_doc['id'] = issuer_did
    # Write compact, ordered JSON
    ordered = {
        "service": did_doc.get("service", []),
        "verificationMethod": did_doc.get("verificationMethod", []),
        "authentication": did_doc.get("authentication", []),
        "id": did_doc.get("id", ""),
        "@context": did_doc.get("@context", [])
    }
    with open(ISSUER_DID_PATH, 'w') as f:
        json.dump(ordered, f, separators=(",", ":"))
    print(f"DID document updated: {ISSUER_DID_PATH}")

def load_private_key():
    with open(ISSUER_KEY_PATH, 'r') as f:
        key_data = json.load(f)
    private_bytes = base64.urlsafe_b64decode(key_data['d'] + '==')
    return Ed25519PrivateKey.from_private_bytes(private_bytes), key_data

def build_payload(holder_id, holder_identifier, domain):
    issuer_did = get_issuer_did(domain)
    return {
        "iss": issuer_did,
        "aud": holder_id,
        "sub": holder_id,
        "vc": {
            "@context": [
                "https://www.w3.org/2018/credentials/v1",
                "https://w3id.org/security/suites/jws-2020/v1",
                "https://www.w3.org/ns/did/v1",
                {
                    "mxd-credentials": "https://w3id.org/mxd/credentials/",
                    "membership": "mxd-credentials:membership",
                    "membershipType": "mxd-credentials:membershipType",
                    "website": "mxd-credentials:website",
                    "contact": "mxd-credentials:contact",
                    "since": "mxd-credentials:since"
                }
            ],
            "id": f"https://dataspace.{domain}/credentials/2347",
            "type": [
                "VerifiableCredential",
                "MembershipCredential"
            ],
            "issuer": issuer_did,
            "issuanceDate": "2023-08-18T00:00:00Z",
            "credentialSubject": {
                "id": holder_id,
                "holderIdentifier": holder_identifier,
                "contractTemplate": "https://public.{domain}/contracts/Membership.v1.pdf",
                "contractVersion": "1.0.0"
            }
        },
        "iat": int(datetime.now(timezone.utc).timestamp())
    }

def sign_jwts(domain):
    private_key, key_data = load_private_key()
    header = {
        "kid": get_issuer_kid(domain),
        "typ": "JWT",
        "alg": "EdDSA"
    }
    companies = [
        {
            "filename": "companyx.membership.jwt",
            "holder_id": f"did:web:companyx.{domain}",
            "holder_identifier": "BPNL000000000001"
        },
        {
            "filename": "companyy.membership.jwt",
            "holder_id": f"did:web:companyy.{domain}",
            "holder_identifier": "BPNL000000000002"
        }
    ]
    for company in companies:
        payload = build_payload(company["holder_id"], company["holder_identifier"], domain)
        token = jwt.encode(
            payload,
            private_key,
            algorithm="EdDSA",
            headers=header
        )
        with open(ASSETS_DIR / company['filename'], "w") as f:
            f.write(token)
        print(f"JWT generated: {company['filename']}")

def main():
    parser = argparse.ArgumentParser(
        description="""
JWT Signer Utility: Generate Ed25519 key pairs, update DID documents, and sign JWTs for companyx and companyy.

Usage:
  python3 generate_jwts.py [OPTIONS]

Options:
  --regenerate-keys    Regenerate issuer key pair and update DID document. Overwrites issuer.key.json and issuer.pub.json.
  --sign-jwts          Sign JWTs for companyx and companyy using the current private key.
  --domain DOMAIN      Base domain for DIDs and URLs. Default: local
  --assets-dir DIR     Assets directory for key, JWT, and DID files. Default: assets
  -h, --help           Show this help message and exit.

Examples:
  python3 generate_jwts.py --regenerate-keys --sign-jwts
  python3 generate_jwts.py --regenerate-keys --sign-jwts --domain local.io --assets-dir resources
  python3 generate_jwts.py --sign-jwts --assets-dir resources
        """,
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('--regenerate-keys', action='store_true', help='Regenerate issuer key pair and update DID document. Overwrites issuer.key.json and issuer.pub.json.')
    parser.add_argument('--sign-jwts', action='store_true', help='Sign JWTs for companyx and companyy using the current private key.')
    parser.add_argument('--domain', type=str, default='local', help='Base domain for DIDs and URLs. Default: local')
    parser.add_argument('--assets-dir', type=str, default='assets', help='Assets directory for key, JWT, and DID files. Default: assets')
    args = parser.parse_args()

    global ASSETS_DIR, ISSUER_KEY_PATH, ISSUER_PUB_PATH, ISSUER_DID_PATH
    ASSETS_DIR = Path(args.assets_dir)
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    ISSUER_KEY_PATH = ASSETS_DIR / 'issuer.key.json'
    ISSUER_PUB_PATH = ASSETS_DIR / 'issuer.pub.json'
    ISSUER_DID_PATH = ASSETS_DIR / 'issuer.did.json'

    # Ensure key, pub files exist (create empty if not)
    for path in [ISSUER_KEY_PATH, ISSUER_PUB_PATH]:
        if not path.exists():
            with open(path, 'w') as f:
                f.write('{}')
    # For issuer.did.json, create a minimal valid structure if missing or empty
    if not ISSUER_DID_PATH.exists() or ISSUER_DID_PATH.stat().st_size == 0:
        minimal_did = {
            "service": [],
            "verificationMethod": [
                {
                    "id": get_issuer_kid(args.domain),
                    "type": "JsonWebKey2020",
                    "controller": get_issuer_did(args.domain),
                    "publicKeyMultibase": None,
                    "publicKeyJwk": {}
                }
            ],
            "authentication": [],
            "id": get_issuer_did(args.domain),
            "@context": [
                "https://w3id.org/did-resolution/v1",
                "https://www.w3.org/ns/did/v1"
            ]
        }
        with open(ISSUER_DID_PATH, 'w') as f:
            json.dump(minimal_did, f, separators=(',', ':'))

    if args.regenerate_keys:
        priv_jwk, pub_jwk = regenerate_keys(args.domain)
        update_issuer_did(pub_jwk, args.domain)
    if args.sign_jwts:
        sign_jwts(args.domain)

if __name__ == "__main__":
    main()
