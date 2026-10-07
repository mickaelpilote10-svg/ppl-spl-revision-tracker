# PPL(A) / SPL Revision Tracker — version multi-utilisateurs (Supabase)

Site statique (`public/`) + Supabase (Auth + PostgreSQL + RLS).
Les mots de passe sont hashés par Supabase Auth, les sessions sont des jetons JWT persistants (rafraîchis automatiquement), et la base refuse l'accès aux lignes d'un autre utilisateur grâce aux politiques RLS.

## Contenu
- `public/index.html` : application (connexion, inscription, mot de passe oublié, profil, 9 matières, stats, calendrier, objectifs, Quizlet 050, footer)
- `public/config.js` : URL + clé publique Supabase
- `public/assets/logo-gvvg.png` : **à ajouter : ton logo GVVG, fichier original sans modification**
- `supabase/schema.sql` : tables, trigger de profil, politiques RLS
- `build.sh` : génère `config.js` depuis des variables d'environnement

## Variables d'environnement
| Variable | Où la trouver | Remarque |
|---|---|---|
| `SUPABASE_URL` | Supabase → Project Settings → API → Project URL | publique |
| `SUPABASE_ANON_KEY` | Project Settings → API → `anon` / publishable key | publique, protégée par la RLS |

N'utilise **jamais** la clé `service_role` dans ce site.

## Étape 1 — Créer le projet Supabase
1. Crée un compte sur supabase.com → New project (région Europe, ex. Zurich/Frankfurt).
2. SQL Editor → New query → colle `supabase/schema.sql` → Run.
3. Vérifie dans Table Editor que `profiles`, `sessions`, `goals` affichent **RLS enabled**.

## Étape 2 — Configurer l'authentification
Authentication → Providers → Email : activer **Confirm email**, longueur minimale du mot de passe **10**, exigences : minuscules, majuscules, chiffres. Durée de validité des liens (**OTP expiry**) : 3600 s ou moins.

Authentication → URL Configuration :
- **Site URL** : l'adresse finale du site (ex. `https://tracker.exemple.ch`)
- **Redirect URLs** : la même adresse (+ `http://localhost:8080` pour les tests)

**SMTP (important)** : le service d'e-mail par défaut de Supabase est limité et réservé aux tests. Pour un vrai usage, Authentication → SMTP Settings → configure un fournisseur (Resend, Brevo, Postmark…) avec une adresse d'expéditeur de ton domaine.

## Étape 3 — E-mails (Authentication → Email Templates)
**Confirm signup** — sujet : `Bienvenue sur PPL(A) / SPL Revision Tracker ✈️`
```html
<div style="font-family:Arial,sans-serif;max-width:520px;margin:auto;color:#14263a">
  <h2 style="color:#1f5f99">✈️ PPL(A) / SPL Revision Tracker</h2>
  <p>Bonjour {{ .Data.first_name }},</p>
  <p>Merci pour ta confiance et bienvenue sur PPL(A) / SPL Revision Tracker !</p>
  <p>Ton compte vient d'être créé. Tu pourras suivre tes révisions théoriques PPL(A) et SPL, ton temps d'étude, tes statistiques, tes objectifs et ton historique.</p>
  <p>Pour activer ton compte, clique sur le bouton ci-dessous (lien personnel et temporaire) :</p>
  <p><a href="{{ .ConfirmationURL }}" style="background:#1f5f99;color:#fff;padding:12px 20px;border-radius:8px;text-decoration:none;font-weight:bold">Activer mon compte</a></p>
  <p>🔐 Pour ta sécurité, ton mot de passe n'est jamais envoyé par e-mail. <strong>Ne le partage jamais avec personne.</strong></p>
  <p>Bonne révision et bon courage pour ta formation aéronautique ! ✈️</p>
  <p><strong>Mickaël Rouiller</strong><br>Créateur de PPL(A) / SPL Revision Tracker</p>
</div>
```
**Reset Password** — sujet : `Réinitialisation de ton mot de passe`
```html
<div style="font-family:Arial,sans-serif;max-width:520px;margin:auto;color:#14263a">
  <h2 style="color:#1f5f99">✈️ PPL(A) / SPL Revision Tracker</h2>
  <p>Tu as demandé à réinitialiser ton mot de passe.</p>
  <p><a href="{{ .ConfirmationURL }}" style="background:#1f5f99;color:#fff;padding:12px 20px;border-radius:8px;text-decoration:none;font-weight:bold">Choisir un nouveau mot de passe</a></p>
  <p>Ce lien est temporaire et à usage unique. Si tu n'es pas à l'origine de cette demande, ignore cet e-mail.</p>
</div>
```
Modèle **Change Email Address** : traduis-le de la même façon (il contient `{{ .ConfirmationURL }}`).

## Étape 4 — Configurer le site
1. Copie ton logo dans `public/assets/logo-gvvg.png` (même nom).
2. Test local : modifie `public/config.js` avec tes valeurs, puis `cd public && python3 -m http.server 8080` → http://localhost:8080

## Étape 5 — Mise en ligne (Netlify, Vercel ou Cloudflare Pages)
1. Pousse ce dossier sur un dépôt GitHub (ne commit pas de vraie clé si tu préfères les variables d'environnement).
2. Crée un site depuis ce dépôt : **Build command** `sh build.sh` — **Publish / output directory** `public`.
3. Ajoute `SUPABASE_URL` et `SUPABASE_ANON_KEY` dans les variables d'environnement de l'hébergeur.
4. Déploie, puis mets l'URL finale dans Supabase (Site URL + Redirect URLs, étape 2).
5. Ajoute éventuellement ton domaine, en HTTPS.

## Sécurité — ce qui est en place
- Hash des mots de passe, sessions JWT à expiration + refresh, déconnexion (`signOut`).
- RLS sur les 3 tables : `user_id = auth.uid()` en lecture, ajout, modification, suppression ; `anon` n'a aucun droit sur les tables.
- `user_id` est rempli par défaut avec `auth.uid()` ; impossible d'écrire pour un autre utilisateur.
- Contraintes SQL : matières valides, durée 1–600, lien Quizlet limité à `https://…quizlet.com`.
- Liens e-mail temporaires ; réponse neutre au « mot de passe oublié » (n'indique pas si l'adresse existe).
- Contenu utilisateur échappé à l'affichage (anti-XSS).
Limite assumée : les protections « page protégée » côté navigateur ne sont qu'un confort ; la vraie protection est la RLS côté base.

## Checklist de tests
1. Créer un compte (prénom, nom, e-mail, mot de passe valide)
2. Recevoir l'e-mail de bienvenue (lien, sans mot de passe) et cliquer sur le lien
3. Se connecter ; rafraîchir la page → toujours connecté
4. Se déconnecter → retour à la page de connexion
5. Mot de passe incorrect → message clair
6. Inscription avec une adresse déjà utilisée → refusée
7. Mot de passe oublié → e-mail reçu
8. Lien de réinitialisation → nouveau mot de passe → « Votre mot de passe a été modifié avec succès. » ; reconnexion avec le nouveau
9. Lien de réinitialisation réutilisé / expiré → refusé
10. Ajouter une séance 07.10.2026 — 050 — 1h30 (90 min) ; vérifier chacune des 9 matières dans le menu
11. Statistiques, calendrier, graphiques, objectif : cohérents ; catégorie PPL(A) / SPL correcte
12. Créer un 2e compte (autre e-mail) : aucune donnée du 1er visible ; ses séances n'apparaissent pas chez le 1er
13. Quizlet 050 : chaque compte a son propre lien ; le bouton ouvre un nouvel onglet
14. Profil : modifier prénom/nom, mot de passe, e-mail (vérification)
15. Téléphone : connexion, saisie d'une séance, calendrier
16. Test RLS (SQL Editor → Table Editor en tant qu'utilisateur) : un `select` sur `sessions` avec la clé anon sans connexion renvoie 0 ligne

## Non inclus
Streak (jours consécutifs) : absent de la version précédente, donc non ajouté. Confirmation d'e-mail et envoi réel nécessitent ton projet Supabase et un SMTP : ils n'ont pas pu être testés depuis l'environnement où ce projet a été préparé.
