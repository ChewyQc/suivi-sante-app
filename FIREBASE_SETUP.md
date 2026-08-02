# Configurer Firebase pour la sauvegarde Google (v3.1)

## 1. Créer le projet
1. Va sur https://console.firebase.google.com (connecte-toi avec ton compte Google)
2. "Ajouter un projet" → nomme-le par ex. `suivi-sante`
3. Désactive Google Analytics (pas nécessaire) → "Créer le projet"

## 2. Enregistrer l'app Android
1. Dans le projet, clique l'icône Android pour ajouter une app
2. **Nom du package Android** : `com.epitome.suivisante`
3. **Certificat de signature SHA-1** (débogage) : `9F:B9:9C:A6:AE:90:65:F5:E4:27:22:97:D3:A5:02:6F:FF:75:F0:E5`
4. "Enregistrer l'application"
5. **Télécharge le fichier `google-services.json`** — envoie-le-moi (glisse-le dans le chat)

## 3. Activer la connexion Google
1. Menu de gauche → "Authentication" → "Get started"
2. Onglet "Sign-in method" → active le fournisseur **Google**
3. Enregistre

## 4. Activer la base de données
1. Menu de gauche → "Firestore Database" → "Créer une base de données"
2. Mode **production**
3. Région : `northamerica-northeast1` (Montréal) si proposée, sinon la plus proche
4. "Activer"

Une fois que tu m'as envoyé `google-services.json`, je branche le bouton "Se connecter avec Google" et la sauvegarde/restauration dans Réglages.
