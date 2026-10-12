# Applications Windows et Mac

Ces applications sont une fenêtre dédiée pour le site en ligne PPL(A) / SPL Revision Tracker. Elles ont besoin d'une connexion Internet pour Supabase, les comptes et les données.

**Les mises à jour du site (nouveaux QCM, statistiques, etc.) apparaissent automatiquement** dans les applications au prochain démarrage : elles ouvrent le site de production. Il n'est donc pas nécessaire de réinstaller l'application à chaque changement du site, seulement quand ce dossier `desktop` change (version 1.1.0 actuelle).

## Télécharger les installeurs

1. Ouvre le dépôt GitHub, onglet **Actions**.
2. Ouvre le dernier lancement réussi de **Build desktop installers** (ou clique **Run workflow** pour en lancer un nouveau).
3. Dans **Artifacts**, télécharge :
   - **PPL-SPL-Revision-Tracker-Windows** : ZIP contenant `PPL-SPL-Revision-Tracker-1.1.0-Setup.exe` (installeur Windows 64 bits) ;
   - **PPL-SPL-Revision-Tracker-macOS** : ZIP contenant deux `.dmg` — `arm64` pour les Mac récents (puce M1/M2/M3/M4), `x64` pour les Mac Intel.

## Avertissements au premier lancement

Les applications ne sont pas signées par un certificat éditeur payant.
- **Windows** : SmartScreen peut afficher un avertissement → **Informations complémentaires** → **Exécuter quand même**.
- **Mac** : clic droit sur l'application → **Ouvrir** → **Ouvrir**.

Aucune clé secrète Supabase n'est ajoutée aux applications : elles ouvrent l'adresse Vercel déjà configurée dans le code.

## iPhone / iPad

Pas de fichier à installer : le site est installable depuis Safari (**Partager → Sur l'écran d'accueil**). Une vraie application iOS (.ipa) nécessite un compte Apple Developer payant.
