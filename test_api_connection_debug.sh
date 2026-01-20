#!/bin/bash

# Script de debug pour tester la connexion à l'API Teranga Pass
# Ce script teste différentes URLs et méthodes pour identifier le problème

echo "=========================================="
echo "SCRIPT DE DEBUG - CONNEXION API"
echo "=========================================="
echo ""

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# URLs à tester
PROD_URL="https://terangapass.universaltechnologiesafrica.com"
LOCAL_URL="http://localhost:8000"

# Fonction pour tester une URL
test_url() {
    local url=$1
    local name=$2
    
    echo -e "${YELLOW}Test: $name${NC}"
    echo "URL: $url"
    echo ""
    
    # Test de base (GET)
    echo "1. Test GET (health check)..."
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url/up" 2>&1)
    if [ $? -eq 0 ] && [ "$response" = "200" ]; then
        echo -e "${GREEN}✓ Serveur accessible (HTTP $response)${NC}"
    else
        echo -e "${RED}✗ Serveur non accessible ou erreur (HTTP $response)${NC}"
    fi
    echo ""
    
    # Test de l'endpoint API login
    echo "2. Test POST /api/v1/auth/login..."
    response=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME:%{time_total}" \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d '{"email":"test@example.com","password":"test"}' \
        --max-time 10 \
        "$url/api/v1/auth/login" 2>&1)
    
    http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)
    time_total=$(echo "$response" | grep "TIME" | cut -d: -f2)
    body=$(echo "$response" | grep -v "HTTP_CODE" | grep -v "TIME")
    
    echo "HTTP Code: $http_code"
    echo "Time: ${time_total}s"
    echo "Response: $body"
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "401" ] || [ "$http_code" = "422" ]; then
        echo -e "${GREEN}✓ Endpoint API accessible (HTTP $http_code)${NC}"
    elif [ "$http_code" = "000" ] || [ -z "$http_code" ]; then
        echo -e "${RED}✗ Connexion impossible (timeout ou DNS)${NC}"
    elif [ "$http_code" = "503" ]; then
        echo -e "${RED}✗ Service temporairement indisponible (HTTP 503)${NC}"
    else
        echo -e "${YELLOW}⚠ Réponse inattendue (HTTP $http_code)${NC}"
    fi
    echo ""
    
    # Test DNS
    echo "3. Test DNS..."
    domain=$(echo "$url" | sed -E 's|https?://||' | cut -d'/' -f1)
    if nslookup "$domain" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ DNS résolu pour $domain${NC}"
        ip=$(nslookup "$domain" | grep -A 1 "Name:" | tail -1 | awk '{print $2}')
        echo "  IP: $ip"
    else
        echo -e "${RED}✗ DNS non résolu pour $domain${NC}"
    fi
    echo ""
    
    # Test SSL (si HTTPS)
    if [[ "$url" == https://* ]]; then
        echo "4. Test SSL..."
        domain=$(echo "$url" | sed -E 's|https?://||' | cut -d'/' -f1)
        if echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>&1 | grep -q "Verify return code: 0"; then
            echo -e "${GREEN}✓ Certificat SSL valide${NC}"
        else
            echo -e "${YELLOW}⚠ Problème avec le certificat SSL${NC}"
        fi
        echo ""
    fi
    
    echo "----------------------------------------"
    echo ""
}

# Test de l'URL de production
test_url "$PROD_URL" "URL de Production"

# Test de l'URL locale (si le serveur est en cours d'exécution)
echo "Voulez-vous tester l'URL locale? (y/n)"
read -r answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    test_url "$LOCAL_URL" "URL Locale"
fi

echo "=========================================="
echo "RÉSUMÉ"
echo "=========================================="
echo ""
echo "Si vous voyez des erreurs:"
echo "1. Vérifiez que le serveur Laravel est en cours d'exécution"
echo "2. Vérifiez la configuration CORS dans config/cors.php"
echo "3. Vérifiez que l'URL dans api_constants.dart correspond"
echo "4. Vérifiez les logs Laravel: tail -f storage/logs/laravel.log"
echo ""
