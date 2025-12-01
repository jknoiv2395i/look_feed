# 🚀 TESTING EXECUTION GUIDE - INSTAGRAM SAAS

**Status**: ✅ **READY TO TEST**

---

## 📊 WHAT TO TEST (Priority Order)

### PHASE 1: Unit Tests (Backend Services)
```bash
cd backend
npm test -- --passWithNoTests
```

**Test Files**:
1. KeywordMatcher.test.ts (8 tests)
2. FilterDecisionEngine.test.ts (8 tests)
3. AnalyticsService.test.ts (12 tests)
4. CacheService.test.ts (11 tests)
5. RateLimitService.test.ts (6 tests)

**Expected**: 45 tests pass, 85%+ coverage

---

### PHASE 2: Controller Tests (API Endpoints)
```bash
npm test -- --testPathPattern="controllers"
```

**Test Files**:
1. AuthController.test.ts (15 tests)
2. KeywordController.test.ts (10 tests)
3. FilterController.test.ts (10 tests)
4. AnalyticsController.test.ts (10 tests)

**Expected**: 45 tests pass

---

### PHASE 3: Integration Tests (Complete Workflows)
```bash
npm test -- --testPathPattern="integration"
```

**Test Scenarios**:
1. Auth flow: Register → Login → Refresh → Logout
2. Keyword flow: Create → Read → Update → Delete
3. Classification flow: Match keywords → AI classify → Decide
4. Analytics flow: Log events → Query dashboard → Export CSV

**Expected**: 4 integration tests pass

---

### PHASE 4: Database Tests

#### Firebase Test
Create `backend/test-firebase.js`:
```bash
node test-firebase.js
```

**Tests**: Create, Read, Update, Delete users & keywords (6 operations)

#### PostgreSQL Test
```bash
docker-compose up -d postgres
node test-database.js
```

**Tests**: Connect, Create table, Insert, Query, Update, Delete (7 operations)

---

### PHASE 5: API Tests (Manual HTTP)

Start server:
```bash
npm start
```

Test endpoints:
```bash
# 1. Register
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!","name":"Test"}'

# 2. Login (save token)
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!"}'

# 3. Get user
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"

# 4. Create keyword
curl -X POST http://localhost:3000/api/v1/keywords \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"keyword":"fitness","category":"health"}'

# 5. Get keywords
curl -X GET http://localhost:3000/api/v1/keywords \
  -H "Authorization: Bearer YOUR_TOKEN"

# 6. Classify post
curl -X POST http://localhost:3000/api/v1/filter/classify \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"caption":"fitness workout","hashtags":["#fitness"]}'

# 7. Get analytics
curl -X GET http://localhost:3000/api/v1/analytics/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN"

# 8. Logout
curl -X POST http://localhost:3000/api/v1/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected**: All 8 endpoints return 200/201

---

### PHASE 6: Performance Tests

#### Keyword Matching Speed
```bash
npm test -- KeywordMatcher.test.ts --verbose
```
**Target**: < 5ms per post

#### API Response Times
```bash
# Cached: < 50ms
# Uncached: < 500ms
# Cache hit rate: > 70%
```

#### Database Queries
```bash
# Query 1000 keywords: < 500ms
```

---

### PHASE 7: Load Tests

```bash
# Install
npm install -g artillery

# Create load-test.yml
cat > load-test.yml << 'EOF'
config:
  target: "http://localhost:3000"
  phases:
    - duration: 60
      arrivalRate: 10
    - duration: 120
      arrivalRate: 50
    - duration: 60
      arrivalRate: 100

scenarios:
  - name: "Classification"
    flow:
      - post:
          url: "/api/v1/filter/classify"
          json:
            caption: "Test"
            hashtags: ["#test"]
EOF

# Run
artillery run load-test.yml
```

**Target**: p95 < 500ms, p99 < 1000ms

---

### PHASE 8: Security Tests

```bash
# 1. No token → 401
curl -X GET http://localhost:3000/api/v1/keywords

# 2. Invalid token → 401
curl -X GET http://localhost:3000/api/v1/keywords \
  -H "Authorization: Bearer invalid"

# 3. SQL injection → Blocked
curl -X POST http://localhost:3000/api/v1/keywords \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"keyword":"test'; DROP TABLE users; --"}'

# 4. Rate limiting → 429
for i in {1..100}; do
  curl -X GET http://localhost:3000/api/v1/keywords \
    -H "Authorization: Bearer TOKEN" &
done
```

---

## ✅ COMPLETION CHECKLIST

### Unit Tests
- [ ] 45 tests pass
- [ ] Coverage > 80%

### Controller Tests
- [ ] 45 tests pass

### Integration Tests
- [ ] 4 tests pass

### Database Tests
- [ ] Firebase: 6/6 operations pass
- [ ] PostgreSQL: 7/7 operations pass

### API Tests
- [ ] 8/8 endpoints working

### Performance Tests
- [ ] Keyword matching < 5ms
- [ ] API cached < 50ms
- [ ] API uncached < 500ms
- [ ] Cache hit rate > 70%

### Load Tests
- [ ] 100 concurrent users: ✅
- [ ] 1000 concurrent users: ✅
- [ ] p95 < 500ms: ✅

### Security Tests
- [ ] Auth bypass blocked: ✅
- [ ] Invalid token blocked: ✅
- [ ] SQL injection blocked: ✅
- [ ] Rate limiting enforced: ✅

---

## 🎯 EXECUTION TIMELINE

**Day 1**: Unit + Controller Tests (2 hours)
```bash
npm test -- --passWithNoTests
```

**Day 2**: Integration Tests (1 hour)
```bash
npm test -- --testPathPattern="integration"
```

**Day 3**: Database Tests (2 hours)
```bash
node test-firebase.js
docker-compose up -d postgres
node test-database.js
```

**Day 4**: API Tests (2 hours)
```bash
npm start
# Run all curl commands
```

**Day 5**: Performance + Load Tests (3 hours)
```bash
npm test -- --verbose
artillery run load-test.yml
```

**Day 6**: Security Tests (1 hour)
```bash
# Run all security test cases
```

---

## 📊 SUCCESS METRICS

| Category | Target | Status |
|----------|--------|--------|
| Unit Tests | 45/45 | ⏳ |
| Controller Tests | 45/45 | ⏳ |
| Integration Tests | 4/4 | ⏳ |
| API Endpoints | 8/8 | ⏳ |
| Code Coverage | 80%+ | ⏳ |
| Performance | Targets Met | ⏳ |
| Load Test | p95 < 500ms | ⏳ |
| Security | All Passed | ⏳ |

---

## 🚀 NEXT STEPS

1. Start with Unit Tests (Phase 1)
2. Run each phase sequentially
3. Fix any failures before moving to next phase
4. Document all results
5. Deploy to production once all tests pass

---

**Status**: ✅ **READY TO EXECUTE**

Start with: `cd backend && npm test -- --passWithNoTests`
