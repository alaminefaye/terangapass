#!/bin/bash

# Test simple de connexion API
API_URL="http://localhost:8000/api"

echo "🧪 Test Simple de Connexion API"
echo "================================"
echo ""

# Vérifier si le serveur répond
echo "1. Vérification du serveur..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/announcements/audio" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "401" ]; then
    echo "✅ Serveur répond (HTTP $HTTP_CODE)"
else
    echo "❌ Serveur ne répond pas (HTTP $HTTP_CODE)"
    echo ""
    echo "⚠️  Le serveur Laravel n'est pas démarré."
    echo "📝 Pour démarrer le serveur, exécutez :"
    echo "   php artisan serve --host=0.0.0.0 --port=8000"
    echo ""
    echo "💡 Une fois le serveur démarré, relancez ce test."
    exit 1
fi

echo ""
echo "2. Test d'inscription..."
TIMESTAMP=$(date +%s)
EMAIL="test${TIMESTAMP}@example.com"

REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"name\":\"Test User\",\"email\":\"$EMAIL\",\"password\":\"password123\"}" 2>&1)

if echo "$REGISTER_RESPONSE" | grep -q "token"; then
    echo "✅ Inscription réussie"
    TOKEN=$(echo "$REGISTER_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo "   Email créé: $EMAIL"
    echo "   Token reçu: ${TOKEN:0:30}..."
else
    echo "❌ Inscription échouée"
    echo "   Réponse: $REGISTER_RESPONSE"
    TOKEN=""
fi

echo ""
echo "3. Test de connexion..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"password123\"}" 2>&1)

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    echo "✅ Connexion réussie"
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
else
    echo "❌ Connexion échouée"
    echo "   Réponse: $LOGIN_RESPONSE"
    TOKEN=""
fi

if [ -n "$TOKEN" ]; then
    echo ""
    echo "4. Test de requête authentifiée..."
    PROFILE_RESPONSE=$(curl -s -X GET "$API_URL/user/profile" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Accept: application/json" 2>&1)
    
    if echo "$PROFILE_RESPONSE" | grep -q "data\|user\|email"; then
        echo "✅ Requête authentifiée réussie"
    else
        echo "⚠️  Réponse: $PROFILE_RESPONSE"
    fi
fi

echo ""
echo "================================"
echo "✅ Tests terminés !"
echo ""
echo "📝 Si tous les tests passent, l'API fonctionne correctement."
echo "   Vous pouvez maintenant tester depuis l'application Flutter."
