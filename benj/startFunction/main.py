# Importation des bibliothèques nécessaires
from google.cloud import compute_v1
from flask import request
import google.auth
import google.auth.transport.requests
import time

# Définition de la fonction pour démarrer une instance Google Cloud
def start_instance(request):
    try:
        # Vérification de la méthode HTTP, elle doit être POST
        if request.method != 'POST':
            return 'Méthode non autorisée', 405

        # Vérification des autorisations IAM (Identity and Access Management) pour l'utilisateur
        credentials, project = google.auth.default()
        auth_req = google.auth.transport.requests.Request()
        credentials.before_request(auth_req, 'POST', '', headers={})
        if not credentials.valid:
            return 'Non autorisé', 401

        # Récupération des paramètres de la requête JSON, tels que la zone et l'instance
        request_json = request.get_json()
        zone = request_json['zone']
        instance = request_json['instance']

        print(f"Zone: {zone}, Instance: {instance}") # Message de débogage pour afficher la zone et l'instance

        # Démarrage de l'instance en utilisant le client de l'API Google Cloud Compute
        client = compute_v1.InstancesClient()
        operation = client.start(project=project, zone=zone, instance=instance)

        # Boucle pour attendre que l'opération de démarrage soit terminée
        operation_client = compute_v1.ZoneOperationsClient()
        while operation.status != compute_v1.Operation.Status.DONE:
            operation = operation_client.get(operation=operation.name, project=project, zone=zone)
            time.sleep(1) # Pause d'une seconde entre chaque vérification

        print("Instance démarrée avec succès") # Message de débogage pour confirmer le démarrage réussi

        return 'Instance démarrée avec succès', 200 # Réponse HTTP de succès
    except Exception as e:
        print(str(e)) # Journalisation de l'exception en cas d'erreur
        return 'Erreur interne du serveur', 500 # Réponse HTTP d'erreur
