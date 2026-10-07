#!/bin/sh
# Génère public/config.js depuis les variables d'environnement de l'hébergeur.
: "${SUPABASE_URL:?SUPABASE_URL manquante}"
: "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY manquante}"
cat > public/config.js <<CFG
window.APP_CONFIG = { SUPABASE_URL: "$SUPABASE_URL", SUPABASE_ANON_KEY: "$SUPABASE_ANON_KEY" };
CFG
echo "config.js généré"
