# Application Windows

Cette application est une fenêtre dédiée pour le site en ligne PPL(A) / SPL Revision Tracker. Elle a besoin d'une connexion Internet pour Supabase, les comptes et les données.

## Télécharger le fichier EXE

1. Ouvre le dépôt GitHub privé.
2. Clique sur **Actions**.
3. Ouvre le dernier lancement réussi de **Build Windows EXE**.
4. Dans **Artifacts**, télécharge **PPL-SPL-Revision-Tracker-Windows**.
5. Décompresse le ZIP et lance le fichier `PPL-SPL-Revision-Tracker-1.0.0-x64.exe`.

Le fichier est une version portable : pas d'installation et pas de droits administrateur nécessaires. Les mises à jour du site apparaissent dans l'application après redémarrage, car elle ouvre le site de production.

## Avertissement Windows

Le fichier n'est pas signé par un certificat éditeur payant. Windows SmartScreen peut afficher un avertissement au premier lancement. L'application est compilée par le workflow GitHub de ce dépôt. Ne télécharge le fichier que depuis l'onglet **Actions** de ton dépôt.

Aucune clé secrète Supabase n'est ajoutée à l'application. Elle ouvre l'adresse Vercel déjà configurée dans le code.
