# سوق النقل واللوجستيك — Déploiement (Vercel + GitHub + Supabase)

App **jumelle de سوق المقاول** : même architecture (Supabase via CDN, auth téléphone+nom,
bucket photos), mêmes polices **Amiri + Tajawal**, mais thème **bleu + jaune**.

> L'app démarre en **mode démo** (données fictives) tant que Supabase n'est pas branché.
> Tu peux donc la déployer sur Vercel et la tester **tout de suite**, puis brancher Supabase.

## Fichiers
- `index.html` — l'application complète
- `manifest.json`, `service-worker.js`, `icon-192.png`, `icon-512.png` — PWA (installable)
- `schema.sql` — à exécuter dans Supabase

---

## 1) Supabase
1. Crée un projet sur https://supabase.com (gratuit).
2. **SQL Editor → New query** → colle tout `schema.sql` → **Run**.
   (crée les tables `users_naql`, `annonces_naql`, le bucket `photos_naql` et les règles d'accès.)
3. **Project Settings → API** : copie
   - **Project URL** (ex. `https://abcd.supabase.co`)
   - **anon public** key
4. Ouvre `index.html` et remplace en haut du `<script>` :
   ```js
   const SUPABASE_URL = 'https://VOTRE-PROJET.supabase.co';
   const SUPABASE_KEY = 'VOTRE_CLE_ANON_PUBLIQUE';
   ```
   par tes vraies valeurs. Le mode démo se désactive automatiquement.

## 2) GitHub
1. Crée un dépôt (ex. `souk-naql`).
2. Mets-y tous les fichiers de ce dossier (à la racine).
   ```bash
   git init
   git add .
   git commit -m "سوق النقل واللوجستيك — v1"
   git branch -M main
   git remote add origin https://github.com/TON-COMPTE/souk-naql.git
   git push -u origin main
   ```

## 3) Vercel
1. https://vercel.com → **Add New → Project** → importe le dépôt GitHub.
2. Framework Preset : **Other** (c'est un site statique, aucune config).
3. **Deploy**. Vercel te donne une URL `https://souk-naql.vercel.app`.
4. Sur mobile : ouvre l'URL → menu navigateur → **Ajouter à l'écran d'accueil** (PWA).

---

## Notes
- **Même projet Supabase que سوق المقاول ?** Possible : les tables sont préfixées `_naql`
  (vs `_maqawil`), donc aucun conflit. Sinon, un projet séparé marche aussi.
- **Sécurité** : l'auth est volontairement simple (téléphone + nom, sans mot de passe),
  identique à سوق المقاول. Les règles RLS ouvrent l'accès à la clé `anon`.
  Pour durcir : migrer vers Supabase Auth + policies `auth.uid()`.
- **Évolutions prêtes à brancher** : messagerie interne (table `messages_naql`),
  badges premium, statistiques transporteur, géolocalisation.
