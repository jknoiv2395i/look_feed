# ⚡ QUICK TEST COMMANDS

## Copy-Paste Ready Commands

### PHASE 1: Unit Tests
```bash
cd backend
npm test -- --passWithNoTests
```

### PHASE 2: Controller Tests
```bash
npm test -- --testPathPattern="controllers"
```

### PHASE 3: Integration Tests
```bash
npm test -- --testPathPattern="integration"
```

### PHASE 4A: Firebase Tests
```bash
node test-firebase.js
```

### PHASE 4B: PostgreSQL Tests
```bash
docker-compose up -d postgres
sleep 10
node test-database.js
```

### PHASE 5: Start API Server
```bash
npm start
```

### PHASE 5: Test Registration
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!","name":"Test User"}'
```

### PHASE 5: Test Login
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!"}'
```

### PHASE 5: Test Get User (replace TOKEN)
```bash
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### PHASE 5: Test Create Keyword (replace TOKEN)
```bash
curl -X POST http://localhost:3000/api/v1/keywords \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"keyword":"fitness","category":"health"}'
```

### PHASE 5: Test Classify Post (replace TOKEN)
```bash
curl -X POST http://localhost:3000/api/v1/filter/classify \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"caption":"Just finished a fitness workout!","hashtags":["#fitness","#gym"]}'
```

### PHASE 5: Test Get Analytics (replace TOKEN)
```bash
curl -X GET http://localhost:3000/api/v1/analytics/dashboard \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### PHASE 6: Performance Test
```bash
npm test -- KeywordMatcher.test.ts --verbose
```

### PHASE 7: Load Test (Install first)
```bash
npm install -g artillery
artillery run load-test.yml
```

### PHASE 8: Security - No Auth
```bash
curl -X GET http://localhost:3000/api/v1/keywords
```

### PHASE 8: Security - Invalid Token
```bash
curl -X GET http://localhost:3000/api/v1/keywords \
  -H "Authorization: Bearer invalid_token"
```

### PHASE 8: Security - SQL Injection
```bash
curl -X POST http://localhost:3000/api/v1/keywords \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"keyword":"test'"'"'; DROP TABLE users; --"}'
```

### PHASE 8: Security - Rate Limit
```bash
for i in {1..100}; do
  curl -X GET http://localhost:3000/api/v1/keywords \
    -H "Authorization: Bearer YOUR_TOKEN" &
done
```

---

## Expected Results

| Command | Expected Status |
|---------|-----------------|
| Unit Tests | 45 pass, 85%+ coverage |
| Controller Tests | 45 pass |
| Integration Tests | 4 pass |
| Firebase Tests | 6 operations pass |
| PostgreSQL Tests | 7 operations pass |
| Registration | 201 Created |
| Login | 200 OK + tokens |
| Get User | 200 OK + user data |
| Create Keyword | 201 Created |
| Classify Post | 200 OK + decision |
| Get Analytics | 200 OK + stats |
| No Auth | 401 Unauthorized |
| Invalid Token | 401 Unauthorized |
| SQL Injection | Sanitized/Blocked |
| Rate Limit | 429 Too Many Requests |

---

## Troubleshooting

### Tests not running?
```bash
# Check Node version
node --version  # Need 18+

# Check dependencies
npm install

# Check test files exist
ls src/__tests__/services/
```

### Database connection failed?
```bash
# Check PostgreSQL
docker-compose ps

# Check Firebase
ls firebase-key.json
cat .env | grep FIREBASE
```

### API not responding?
```bash
# Check server running
npm start

# Check port available
netstat -an | grep 3000

# Check logs
npm start 2>&1 | head -20
```

---

## 📊 Test Summary

**Total Tests**: 100+
**Total API Endpoints**: 8
**Database Operations**: 13
**Performance Benchmarks**: 5
**Security Checks**: 4

**Estimated Time**: 6 days (1-2 hours/day)

---

**Status**: ✅ Ready to test!
