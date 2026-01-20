#!/bin/bash

# Script de test de connexion API - Teranga Pass
# Utilisation: ./test_api_connection.sh

API_URL="http://localhost:8000/api"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧪 Test de connexion API - Teranga Pass"
echo "========================================"
echo ""

# Test 1: Vérifier que le serveur répond
echo "1️⃣  Test: Vérifier que le serveur répond..."
response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/announcements/audio")
if [ "$response" = "200" ] || [ "$response" = "401" ]; then
    echo -e "${GREEN}✅ Serveur répond (HTTP $response)${NC}"
else
    echo -e "${RED}❌ Serveur ne répond pas (HTTP $response)${NC}"
    echo "⚠️  Assurez-vous que le serveur Laravel est démarré:"
    echo "   php artisan serve --host=0.0.0.0 --port=8000"
    exit 1
fi
echo ""

# Test 2: Test d'inscription
echo "2️⃣  Test: Inscription d'un utilisateur..."
TIMESTAMP=$(date +%s)
EMAIL="test${TIMESTAMP}@example.com"
register_response=$(curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Test User\",
    \"email\": \"$EMAIL\",
    \"password\": \"password123\"
  }")

if echo "$register_response" | grep -q "token"; then
    echo -e "${GREEN}✅ Inscription réussie${NC}"
    TOKEN=$(echo "$register_response" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo "   Email: $EMAIL"
    echo "   Token: ${TOKEN:0:20}..."
else
    echo -e "${RED}❌ Inscription échouée${NC}"
    echo "   Réponse: $register_response"
    TOKEN=""
fi
echo ""

# Test 3: Test de connexion
echo "3️⃣  Test: Connexion avec le compte créé..."
login_response=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$EMAIL\",
    \"password\": \"password123\"
  }")

if echo "$login_response" | grep -q "token"; then
    echo -e "${GREEN}✅ Connexion réussie${NC}"
    TOKEN=$(echo "$login_response" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
else
    echo -e "${RED}❌ Connexion échouée${NC}"
    echo "   Réponse: $login_response"
    TOKEN=""
fi
echo ""

# Test 4: Test de requête authentifiée
if [ -n "$TOKEN" ]; then
    echo "4️⃣  Test: Requête authentifiée (profil utilisateur)..."
    profile_response=$(curl -s -X GET "$API_URL/user/profile" \
      -H "Authorization: Bearer $TOKEN")
    
    if echo "$profile_response" | grep -q "data\|user\|email"; then
        echo -e "${GREEN}✅ Requête authentifiée réussie${NC}"
    else
        echo -e "${YELLOW}⚠️  Requête authentifiée: ${profile_response}${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Test 4 ignoré (pas de token)${NC}"
fi
echo ""

# Test 5: Test d'envoi d'alerte SOS
if [ -n "$TOKEN" ]; then
    echo "5️⃣  Test: Envoi d'alerte SOS..."
    alert_response=$(curl -s -X POST "$API_URL/sos/alert" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN" \
      -d '{
        "latitude": 14.6928,
        "longitude": -17.4467,
        "address": "Dakar, Sénégal"
      }')
    
    if echo "$alert_response" | grep -q "success\|alert"; then
        echo -e "${GREEN}✅ Alerte SOS envoyée avec succès${NC}"
    else
        echo -e "${YELLOW}⚠️  Réponse alerte SOS: ${alert_response}${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Test 5 ignoré (pas de token)${NC}"
fi
echo ""

# Test 6: Test de récupération de données
echo "6️⃣  Test: Récupération des annonces audio..."
announcements_response=$(curl -s -X GET "$API_URL/announcements/audio")
if echo "$announcements_response" | grep -q "data"; then
    echo -e "${GREEN}✅ Récupération des données réussie${NC}"
else
    echo -e "${YELLOW}⚠️  Réponse: ${announcements_response}${NC}"
fi
echo ""

echo "========================================"
echo -e "${GREEN}✅ Tests terminés !${NC}"
echo ""
echo "📝 Prochaines étapes:"
echo "   1. Vérifiez que toutes les routes répondent correctement"
echo "   2. Testez depuis l'application Flutter"
echo "   3. Vérifiez les logs Laravel si des erreurs apparaissent"
echo ""
