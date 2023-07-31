from google.cloud import compute_v1
from flask import request
import google.auth
import google.auth.transport.requests
import time

def stop_instance(request):
    try:
        if request.method != 'POST':
            return 'Méthode non autorisée', 405

        # Vérification des autorisations IAM
        credentials, project = google.auth.default()
        auth_req = google.auth.transport.requests.Request()
        credentials.before_request(auth_req, 'POST', '', headers={})
        if not credentials.valid:
            return 'Non autorisé', 401

        # Récupération des paramètres
        request_json = request.get_json()
        zone = request_json['zone']
        instance = request_json['instance']

        print(f"Zone: {zone}, Instance: {instance}") # Debug

        # Arrêt de l'instance
        client = compute_v1.InstancesClient()
        operation = client.stop(project=project, zone=zone, instance=instance)

        # Attendre que l'opération soit terminée
        operation_client = compute_v1.ZoneOperationsClient()
        while operation.status != compute_v1.Operation.Status.DONE:
            operation = operation_client.get(operation=operation.name, project=project, zone=zone)
            time.sleep(1)

        print("Instance arrêtée avec succès") # Debug

        return 'Instance arrêtée avec succès', 200
    except Exception as e:
        print(str(e)) # Log de l'exception
        return 'Erreur interne du serveur', 500
