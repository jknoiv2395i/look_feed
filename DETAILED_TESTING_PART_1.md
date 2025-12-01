# 📚 DETAILED TESTING STRATEGY - PART 1 (Unit & Controller Tests)

**Date**: November 21, 2025  
**Status**: ✅ **COMPREHENSIVE TESTING PLAN**

---

## 🎯 PHASE 1: UNIT TESTS (45 Tests)

### Overview
Unit tests validate individual services in isolation. Fast execution, no external dependencies.

**Duration**: 30 minutes | **Command**: `npm test -- --passWithNoTests`

---

### 1.1 KeywordMatcher Service (8 tests)

**Purpose**: Validate keyword matching algorithm

| # | Test | Input | Expected | Why |
|---|------|-------|----------|-----|
| 1 | Exact matching | keyword="fitness", caption="I love fitness" | Match, score=1.0 | Exact keywords must match |
| 2 | Fuzzy matching | keyword="fitness", caption="fitnes" | Match, score=0.95 | Typos shouldn't prevent matching |
| 3 | Case-insensitive | keyword="Fitness", caption="FITNESS" | Match, score=1.0 | Case shouldn't matter |
| 4 | Hashtag matching | keyword="fitness", caption="#fitness #gym" | Match, score=1.0 | Hashtags are important |
| 5 | Multiple keywords | keywords=["fitness","gym"], caption="fitness and gym" | Both matched, score=2.0 | Multiple keywords per post |
| 6 | Empty input | keyword="", caption="test" | No match, score=0 | Empty keywords safe |
| 7 | Special characters | keyword="c++", caption="learning c++" | Match, score=1.0 | Technical keywords work |
| 8 | Performance | 1000 keywords, 100 captions | Average < 5ms | Real-time performance critical |

---

### 1.2 FilterDecisionEngine Service (8 tests)

**Purpose**: Validate SHOW/HIDE/UNCERTAIN decision logic

| # | Test | Input | Expected | Why |
|---|------|-------|----------|-----|
| 1 | High score | score=0.95, threshold=0.7 | Decision="SHOW" | High confidence shown |
| 2 | Low score | score=0.2, threshold=0.7 | Decision="HIDE" | Low confidence hidden |
| 3 | Medium score | score=0.65, threshold=0.7 | Decision="UNCERTAIN" | Borderline needs review |
| 4 | Strict strategy | strategy="strict", threshold=0.8 | Only high-confidence shown | Strict users want filtering |
| 5 | Moderate strategy | strategy="moderate", threshold=0.6 | Balanced filtering | Default strategy |
| 6 | Relaxed strategy | strategy="relaxed", threshold=0.4 | Most posts shown | Minimal filtering |
| 7 | Keyword matching | matchedKeywords=["fitness"] | Decision includes keyword info | Users need context |
| 8 | Error handling | score=null, threshold=undefined | Default decision, no crash | Resilient system |

---

### 1.3 AnalyticsService (12 tests)

**Purpose**: Validate event logging and reporting

| # | Test | Input | Expected | Why |
|---|------|-------|----------|-----|
| 1 | Log filter event | event={type:"FILTER", postId:"123"} | Event logged | Track filtering |
| 2 | POST_SHOWN event | event={type:"POST_SHOWN"} | Event recorded | Track shown posts |
| 3 | POST_FILTERED event | event={type:"POST_FILTERED"} | Event recorded | Track hidden posts |
| 4 | Batch logging | events=[{...}, {...}, {...}] | All 3 logged | Efficient bulk logging |
| 5 | Large batch | events=[...] (1000 events) | All logged | Handle high volume |
| 6 | Dashboard data | userId="user123", range="7_days" | {totalPosts, shown, hidden} | Users see analytics |
| 7 | Date ranges | ranges=["today","week","month"] | Correct data per range | Flexible filtering |
| 8 | Keyword stats | userId="user123" | {keyword, matchCount, %} | Which keywords match most |
| 9 | Daily stats | userId="user123", range="30_days" | Array of daily data | See trends |
| 10 | CSV export | userId="user123" | CSV file | Users export data |
| 11 | Data cleanup | olderThan="90_days" | Old records deleted | Database maintenance |
| 12 | Valid metrics | userId="user123" | All metrics valid | Data integrity |

---

### 1.4 CacheService (11 tests)

**Purpose**: Validate caching for performance

| # | Test | Input | Expected | Why |
|---|------|-------|----------|-----|
| 1 | Null uncached | key="post:123:user:456" | null | Cache miss returns null |
| 2 | Return cached | key="post:123", cached=0.95 | 0.95 | Cache hit returns value |
| 3 | Different keywords | keys=["fitness","gym","workout"] | Each cached separately | Different scores per keyword |
| 4 | Set cache score | key="post:123", score=0.85, ttl=3600 | Score cached 1 hour | Cache persistence |
| 5 | Multiple keywords | keywords=["fitness","gym"], scores=[0.9,0.8] | Both cached | Multiple per post |
| 6 | Score range | scores=[0, 0.5, 1.0] | All valid | 0-1 range |
| 7 | Invalidate cache | key="post:123:user:456" | Cache removed | Refresh when changed |
| 8 | Invalidate user | userId="user123" | All user cache removed | Refresh on keyword change |
| 9 | Cache stats | none | {hits, misses, hitRate, size} | Monitor effectiveness |
| 10 | Valid hit rate | hits=70, misses=30 | hitRate=0.7 (70%) | > 70% target |
| 11 | Track hits/misses | 100 requests (70 hits, 30 misses) | Accurate tracking | Measure effectiveness |

---

### 1.5 RateLimitService (6 tests)

**Purpose**: Validate API rate limiting

| # | Test | Input | Expected | Why |
|---|------|-------|----------|-----|
| 1 | Check limit | userId="user123", limit=100 | remainingRequests=100 | Track remaining |
| 2 | Track usage | userId="user123", requests=50 | remainingRequests=50 | Decrement quota |
| 3 | Daily reset | userId="user123", time=next_day | quota reset to limit | Reset every 24h |
| 4 | Tiered limits | tiers={free:100, pro:1000, enterprise:10000} | Correct per tier | Different pricing tiers |
| 5 | Concurrent requests | 10 simultaneous requests | All tracked correctly | Handle concurrency |
| 6 | Remaining quota | userId="user123" | remainingRequests=X | Users know their quota |

---

## 🎯 PHASE 2: CONTROLLER TESTS (45 Tests)

### Overview
Controller tests validate API endpoints, request validation, response formatting.

**Duration**: 30 minutes | **Command**: `npm test -- --testPathPattern="controllers"`

---

### 2.1 AuthController (15 tests)

**Purpose**: Validate authentication endpoints

| # | Test | Input | Expected | Why |
|---|------|-------|----------|-----|
| 1 | Register user | {email, password, name} | 201, user created | Core registration |
| 2 | Email validation | {email:"invalid", password} | 400, error | Prevent invalid emails |
| 3 | Password strength | {email, password:"weak"} | 400, error | Enforce strong passwords |
| 4 | Duplicate email | {email:"existing@ex.com", password} | 409, error | Prevent duplicates |
| 5 | Login user | {email, password} (valid) | 200, tokens | Core login |
| 6 | Return tokens | Valid credentials | accessToken, refreshToken | Client needs tokens |
| 7 | Invalid credentials | {email, password:"wrong"} | 401, error | Prevent unauthorized |
| 8 | Non-existent user | {email:"nonexistent@ex.com", password} | 401, error | Prevent enumeration |
| 9 | Get current user | Valid token | 200, user data | Fetch user profile |
| 10 | Return user data | Valid token | {id, email, name, tier} | Complete info |
| 11 | Reject unauthenticated | No token | 401, error | Protect endpoints |
| 12 | Logout user | Valid token | 200, token invalidated | Core logout |
| 13 | Invalidate token | Logout token | Token no longer valid | Prevent reuse |
| 14 | Refresh token | Valid refresh token | New access token | Extend session |
| 15 | Invalid refresh | Invalid/expired token | 401, error | Prevent unauthorized |

---

### 2.2 KeywordController (10 tests)

**Purpose**: Validate keyword management endpoints

| # | Test | Input | Expected | Why |
|---|------|-------|----------|-----|
| 1 | Create keyword | {keyword:"fitness", category:"health"} | 201, created | Users create keywords |
| 2 | Format validation | {keyword:"", category} | 400, error | Prevent empty keywords |
| 3 | Get all keywords | Valid token | 200, array | List user keywords |
| 4 | Get by ID | keywordId="keyword123" | 200, keyword data | Fetch specific keyword |
| 5 | Update keyword | keywordId, {keyword:"gym"} | 200, updated | Modify keywords |
| 6 | Delete keyword | keywordId="keyword123" | 200, deleted | Remove keywords |
| 7 | Duplicate keyword | {keyword:"fitness"} (exists) | 409, error | Prevent duplicates |
| 8 | Require auth | No token | 401, error | Protect endpoints |
| 9 | User ownership | keywordId from other user | 403, error | Only own keywords |
| 10 | Pagination | {page:1, limit:10} | 200, paginated | Handle large lists |

---

### 2.3 FilterController (10 tests)

**Purpose**: Validate post classification endpoints

| # | Test | Input | Expected | Why |
|---|------|-------|----------|-----|
| 1 | Classify post | {postId, caption, hashtags} | 200, decision | Core classification |
| 2 | Return decision | Valid post | {decision:"SHOW"|"HIDE", confidence} | Users know if filtered |
| 3 | Matched keywords | Post matching keywords | {matchedKeywords:[...]} | Show which matched |
| 4 | Cache hit | Previously classified | 200, cached result | Performance |
| 5 | Cache miss | New post | 200, classification | First-time |
| 6 | Rate limits | 101 requests (limit=100) | 429, error | Prevent abuse |
| 7 | Validate data | {postId:"", caption:""} | 400, error | Prevent invalid |
| 8 | Confidence score | Valid post | confidence:0.0-1.0 | Confidence metric |
| 9 | Log analytics | Valid classification | Event logged | Track history |
| 10 | Batch classify | [{...}, {...}, {...}] | 200, all classified | Bulk classification |

---

### 2.4 AnalyticsController (10 tests)

**Purpose**: Validate analytics endpoints

| # | Test | Input | Expected | Why |
|---|------|-------|----------|-----|
| 1 | Dashboard data | Valid token | 200, metrics | Analytics overview |
| 2 | Keyword stats | Valid token | {keyword, matchCount, %} | Keyword performance |
| 3 | Daily stats | Valid token | Array of daily data | Daily trends |
| 4 | Date filtering | {startDate, endDate} | 200, filtered | Custom date ranges |
| 5 | CSV export | Valid token | CSV file | Export data |
| 6 | JSON export | Valid token | JSON file | Alternative format |
| 7 | Valid metrics | Valid token | All metrics valid | Data integrity |
| 8 | Require auth | No token | 401, error | Protect endpoints |
| 9 | Pagination | {page:1, limit:50} | 200, paginated | Handle large datasets |
| 10 | Large datasets | 1 year of data | 200, all data | Historical data |

---

## ✅ EXECUTION CHECKLIST

### Unit Tests
```bash
cd backend
npm test -- --passWithNoTests
```
- [ ] 45 tests pass
- [ ] 85%+ coverage
- [ ] No errors

### Controller Tests
```bash
npm test -- --testPathPattern="controllers"
```
- [ ] 45 tests pass
- [ ] All endpoints working
- [ ] Proper error handling

---

**Next**: Read DETAILED_TESTING_PART_2.md for Integration, Database, and API Tests
