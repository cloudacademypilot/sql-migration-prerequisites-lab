import requests
import hmac
import hashlib
import base64
import requests
from xml.etree import ElementTree
from datetime import datetime, timedelta, timezone
from azure.identity import ClientSecretCredential, SharedTokenCacheCredential
from azure.mgmt.storage import StorageManagementClient
from azure.core.exceptions import HttpResponseError

def with_hint(result, hint=None):
    return {'result': result, 'hint_message': hint} if hint else result

def get_blobs(key, account, container):
    api_version = "2020-04-08"
    request_date = datetime.utcnow().strftime('%a, %d %b %Y %H:%M:%S GMT')
    url = f"https://{account}.blob.core.windows.net/{container}?restype=container&comp=list"

    canonicalized_headers = f"x-ms-date:{request_date}\nx-ms-version:{api_version}"
    canonicalized_resource = f"/{account}/{container}"
    string_to_sign = "GET\n\n\n\n\n\n\n\n\n\n\n\n{0}\n{1}\ncomp:list\nrestype:container".format(canonicalized_headers, canonicalized_resource).encode('utf-8')
    signature = base64.b64encode(hmac.new(base64.b64decode(key), string_to_sign, hashlib.sha256).digest()).decode()
    authorization_header = f"SharedKey {account}:{signature}"
    headers = {
        "x-ms-date": request_date,
        "x-ms-version": api_version,
        "Authorization": authorization_header
    }

    response = requests.get(url, headers=headers)
    tree = ElementTree.fromstring(response.content)
    blobs = []
    for blob in tree.findall('.//Blob/Name'):
        blobs.append(blob.text)
    return blobs

def handler(event, context):
    credentials, subscriptionId = get_credentials(event)
    rgName = event['environment_params']['resource_group']

    storage_client = StorageManagementClient(credentials, subscriptionId)

    backup_containers = []
    storage = storage_client.storage_accounts.list_by_resource_group(rgName)
    for st in storage:
        try:
            containers = [container for container in storage_client.blob_containers.list(rgName, st.name) if container.name == 'backup']
            if any(containers):
                backup_containers.append((st, containers[0]))
        except HttpResponseError as e:
            print(e)
            if 'ContainerOperationFailure' in e.message:
                continue
            raise(e)
    if not any(backup_containers):        
        return with_hint(False, "No backup container found in Azure Storage")
    
    for account, container in backup_containers:
        keys = storage_client.storage_accounts.list_keys(rgName, account.name)
        blobs = get_blobs(keys.keys[0].value, account.name, container.name)
        if any(blobs):
            return True

    return with_hint(False, "No files found in the backup storage container")


def get_credentials(event):
    subscription_id = event['environment_params']['subscription_id']
    credentials = ClientSecretCredential(
        client_id=event['credentials']['credential_id'],
        client_secret=event['credentials']['credential_key'],
        tenant_id=event['environment_params']['tenant']
    )
    return credentials, subscription_id