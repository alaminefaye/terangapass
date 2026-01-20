# Différence entre Dashboard Web et API Mobile

## 🔍 Observation Importante

Vous avez raison de vous poser la question ! Il y a une **différence fondamentale** entre le dashboard web et l'API mobile.

## 📊 Comparaison

### Dashboard Web (Fonctionne ✅)

**Routes utilisées :**
- `/login` (POST) - Route web classique
- `/admin/dashboard` - Route web protégée
- Utilise des **sessions Laravel** (cookies)
- Authentification via `Auth::attempt()`

**Pourquoi ça fonctionne :**
1. ✅ Requête depuis un **navigateur web** avec JavaScript activé
2. ✅ Tiger Protect voit un vrai navigateur et laisse passer
3. ✅ Les cookies de session sont gérés automatiquement
4. ✅ Pas besoin d'API REST

### API Mobile (Bloqué ❌)

**Routes utilisées :**
- `/api/v1/auth/login` (POST) - Route API REST
- Utilise des **tokens** (pas de sessions)
- Authentification via `AuthController@login`

**Pourquoi ça ne fonctionne pas :**
1. ❌ Requête depuis une **app mobile** sans JavaScript
2. ❌ Tiger Protect bloque car pas de JavaScript
3. ❌ Pas de cookies de session (utilise des tokens)
4. ❌ Requête API REST directe

## 🔄 Différence Technique

### Dashboard Web
```
Navigateur → /login (POST) → Tiger Protect ✅ → Laravel → Session → Dashboard
```

### API Mobile
```
App Mobile → /api/v1/auth/login (POST) → Tiger Protect ❌ → Bloqué
```

## 💡 Pourquoi cette différence ?

**Tiger Protect vérifie :**
- ✅ User-Agent de navigateur (OK pour dashboard)
- ✅ Exécution de JavaScript (OK pour dashboard, ❌ pour app mobile)
- ✅ Cookies de session (OK pour dashboard)
- ✅ Comportement de navigateur (OK pour dashboard)

**Le dashboard fonctionne car :**
- Il utilise un navigateur web avec JavaScript
- Les requêtes passent par le navigateur (pas directement HTTP)
- Tiger Protect voit un "vrai" navigateur

**L'app mobile ne fonctionne pas car :**
- Elle fait des requêtes HTTP directes (pas de navigateur)
- Pas de JavaScript (impossible dans une app native)
- Tiger Protect bloque les requêtes "non-navigateur"

## 🎯 Conclusion

**C'est normal que le dashboard fonctionne et pas l'API mobile !**

Le dashboard utilise des routes web classiques avec un navigateur, tandis que l'app mobile utilise une API REST qui nécessite une configuration spéciale de Tiger Protect.

## ✅ Solution

Pour que l'API mobile fonctionne, il faut :
1. **Configurer Tiger Protect** dans le cPanel o2switch
2. **Désactiver Tiger Protect pour `/api/*`**
3. Ou **créer une exception** pour les routes API

Le dashboard continuera de fonctionner normalement car il utilise des routes web différentes.
