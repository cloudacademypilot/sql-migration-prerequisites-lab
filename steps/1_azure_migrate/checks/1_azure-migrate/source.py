import json
import requests
from azure.identity import ClientSecretCredential, SharedTokenCacheCredential
from azure.mgmt.resource import ResourceManagementClient

def with_hint(result, hint=None):
    return {'result': result, 'hint_message': hint} if hint else result

def authorized_get(url, bearer_token):
    return requests.get(url, headers={'Authorization': f'Bearer {bearer_token.token}', 'ContentType': 'application/json'})

def get_machines(bearer_token, subscriptionId, rgName, project_name):
    url = f"https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{rgName}/providers/Microsoft.Migrate/migrateProjects/{project_name}/machines?api-version=2018-09-01-preview"
    response = authorized_get(url, bearer_token)
    return response.json()['value']

def get_assessment(bearer_token, subscriptionId, rgName):
    url = f"https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{rgName}/providers/Microsoft.Migrate/assessmentProjects?api-version=2019-10-01"
    response = authorized_get(url, bearer_token)
    return response.json()['value']

def get_assessment_group(bearer_token, subscriptionId, rgName, assessment):
    url = f"https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{rgName}/providers/Microsoft.Migrate/assessmentProjects/{assessment}/groups?api-version=2019-10-01"
    response = authorized_get(url, bearer_token)
    return response.json()['value']

def handler(event, context):
    credentials, subscriptionId = get_credentials(event)
    rgName = event['environment_params']['resource_group']

    hint = "Did you create the Migration Project using Azure Portal?"
    client = ResourceManagementClient(credentials, subscriptionId)
    migration_projects = [resource for resource in client.resources.list_by_resource_group(rgName, filter="resourceType eq 'Microsoft.Migrate/MigrateProjects'")]
    if not any(migration_projects):
        return with_hint(False, hint)

    bearer_token = credentials.get_token('https://management.azure.com/.default')

    found_machines = False
    for project in migration_projects:
        project_name = project.name
        machines = get_machines(bearer_token, subscriptionId, rgName, project_name)
        if machines:
            found_machines = True
            break
    if not found_machines:
        return with_hint(False, "No machines found in the Migration Project")

    assessments = get_assessment(bearer_token, subscriptionId, rgName)
    if not any(assessments):
        return with_hint(False, "No assessments found")

    found_groups = False
    for assessment in assessments:
        assessment_name = assessment['name']
        groups = get_assessment_group(bearer_token, subscriptionId, rgName, assessment_name)
        if groups:
            found_groups = True
            break
    return with_hint(found_groups, "No assessment groups found")


def get_credentials(event):
    subscription_id = event['environment_params']['subscription_id']
    credentials = ClientSecretCredential(
        client_id=event['credentials']['credential_id'],
        client_secret=event['credentials']['credential_key'],
        tenant_id=event['environment_params']['tenant']
    )
    return credentials, subscription_id