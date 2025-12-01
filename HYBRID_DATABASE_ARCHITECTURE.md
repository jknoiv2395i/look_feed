# Hybrid Database Architecture - Firebase + PostgreSQL

**Date**: November 20, 2025  
**Project**: Feed Lock - Instagram Content Filtering Engine  
**Status**: Architecture Finalized & Implementation Started

---

## Overview

After comprehensive research into Firebase limitations, a **hybrid architecture** has been designed that leverages:
- **Firebase (Firestore)** for real-time user data and authentication
- **PostgreSQL** for analytics, complex queries, and high-throughput operations

This approach overcomes Firebase's limitations while maintaining its strengths.

---

## Why Hybrid Architecture?

### Firebase Limitations Identified

| Limitation | Impact | Solution |
|-----------|--------|----------|
| No multiple inequality filters | Complex queries fail | Use PostgreSQL |
| No full-text search | Cannot search captions | Use PostgreSQL |
| No aggregation functions | Cannot calculate stats | Use PostgreSQL |
| 1 write/sec per document | High-frequency updates fail | Use PostgreSQL |
| 500 write batch limit | Bulk operations slow | Use PostgreSQL |
| No complex transactions | Multi-document updates risky | Use PostgreSQL |
| Limited query flexibility | Restricted data retrieval | Use PostgreSQL |

### Firebase Strengths

| Strength | Use Case |
|----------|----------|
| Real-time updates | User profiles, keywords, settings |
| Built-in authentication | User login, JWT tokens |
| Security rules | Fine-grained access control |
| Automatic scaling | Handles traffic spikes |
| Low latency | < 100ms response times |

---

## Data Distribution Strategy

### Firebase Collections (Real-time & User Data)

```
Firestore
├── users/{userId}
│   ├── email
│   ├── firstName
│   ├── lastName
│   ├── tier (free/premium/pro)
│   ├── filterStrategy (strict/moderate/relaxed)
│   ├── createdAt
│   └── updatedAt
│
├── keywords/{userId}/items/{keywordId}
│   ├── keyword
│   ├── createdAt
│   └── updatedAt
│
├── filterConfigs/{userId}
│   ├── strategy
│   ├── enableAiClassification
│   ├── createdAt
│   └── updatedAt
│
└── userStats/{userId}
    ├── todayPostsViewed
    ├── todayPostsBlocked
    ├── thisWeekPostsViewed
    ├── thisWeekPostsBlocked
    └── lastUpdated
```

**Why Firebase?**
- Real-time sync needed
- User-specific data (security rules)
- Frequent reads/writes (< 1/sec)
- Authentication integration

### PostgreSQL Tables (Analytics & Complex Data)

```
PostgreSQL
├── analytics_events
│   ├── id (UUID)
│   ├── user_id
│   ├── post_id
│   ├── event_type (POST_DETECTED/FILTERED/SHOWN)
│   ├── relevance_score
│   ├── matched_keywords (JSONB)
│   ├── filter_method (keyword/ai/hybrid)
│   ├── processing_time_ms
│   └── created_at
│
├── analytics_daily_summary
│   ├── id (UUID)
│   ├── user_id
│   ├── date
│   ├── total_posts_viewed
│   ├── total_posts_blocked
│   ├── blocking_rate
│   ├── time_saved_minutes
│   └── created_at
│
├── analytics_keyword_stats
│   ├── id (UUID)
│   ├── user_id
│   ├── keyword
│   ├── match_count
│   ├── effectiveness_score
│   └── created_at
│
├── filter_logs
│   ├── id (UUID)
│   ├── user_id
│   ├── post_id
│   ├── action (shown/hidden)
│   ├── relevance_score
│   ├── matched_keywords (JSONB)
│   └── created_at
│
├── ai_classification_cache
│   ├── id (UUID)
│   ├── cache_key (MD5 hash)
│   ├── post_id
│   ├── keywords (JSONB)
│   ├── relevance_score
│   ├── created_at
│   ├── expires_at (24h TTL)
│   └── INDEX on cache_key, expires_at
│
└── rate_limit_tracking
    ├── id (UUID)
    ├── user_id
    ├── tier (free/premium/pro)
    ├── date
    ├── ai_calls_today
    ├── ai_calls_this_hour
    └── created_at
```

**Why PostgreSQL?**
- Complex queries needed (GROUP BY, aggregations)
- High write throughput (batch inserts)
- Historical data analysis
- Full-text search
- Advanced filtering

---

## Backend Services Implemented

### 1. FirebaseService
**Purpose**: Handle all Firestore operations
**Methods**:
- `getUserProfile(userId)` - Get user from Firebase
- `updateUserProfile(userId, updates)` - Update user
- `getKeywords(userId)` - Get user's keywords
- `addKeyword(userId, keyword)` - Add new keyword
- `deleteKeyword(userId, keywordId)` - Remove keyword
- `getFilterConfig(userId)` - Get filter settings
- `updateFilterConfig(userId, updates)` - Update settings
- `getUserStats(userId)` - Get real-time stats
- `updateUserStats(userId, stats)` - Update stats

### 2. AnalyticsService
**Purpose**: Handle analytics in PostgreSQL
**Methods**:
- `logFilterEvent(event)` - Log single event
- `batchLogFilterEvents(events)` - Batch log events
- `getAnalyticsDashboard(userId, dateRange)` - Get dashboard
- `getKeywordStats(userId, limit)` - Get keyword effectiveness
- `getDailyStats(userId, startDate)` - Get daily breakdown
- `aggregateDailyStats(userId, date)` - Aggregate stats (cron job)
- `exportAnalytics(userId, dateRange)` - Export as CSV
- `cleanupOldAnalytics(retentionDays)` - Delete old data

### 3. CacheService
**Purpose**: Cache AI classification results
**Methods**:
- `getCachedScore(postId, keywords)` - Get cached score
- `setCachedScore(postId, keywords, score)` - Cache score
- `invalidateCache(postId)` - Clear cache for post
- `cleanupExpiredCache()` - Delete expired entries
- `getCacheStats()` - Get cache statistics
- `getCacheHitRate(timeWindowHours)` - Calculate hit rate

### 4. RateLimitService
**Purpose**: Enforce API rate limits
**Methods**:
- `checkLimit(userId, tier)` - Check if under limit
- `incrementUsage(userId, tier)` - Increment counter
- `getCurrentUsage(userId)` - Get current usage
- `resetDailyLimits()` - Reset limits (cron job)
- `getRateLimitStats()` - Get statistics
- `checkAndEnforce(userId, tier)` - Check and throw error

### 5. Existing Services (Unchanged)
- `KeywordMatcher` - Fuzzy keyword matching
- `AIClassifierService` - OpenAI classification
- `FilterDecisionEngine` - Decision logic

---

## Data Flow Examples

### Example 1: User Adds Keyword
```
1. Client → API: POST /api/v1/keywords { keyword: "fitness" }
2. API → FirebaseService: addKeyword(userId, "fitness")
3. FirebaseService → Firestore: Add to keywords collection
4. Firestore → Client: Real-time update
5. API → AnalyticsService: Log event (async)
```

### Example 2: Post Classification with Caching
```
1. Client → API: POST /api/v1/filter/classify { postData, keywords }
2. API → CacheService: getCachedScore(postId, keywords)
3. If cached:
   a. Return cached score
4. If not cached:
   a. API → KeywordMatcher: Quick match
   b. If uncertain: API → AIClassifierService: AI classification
   c. API → CacheService: Cache result (24h TTL)
5. API → AnalyticsService: Log event (async)
6. API → RateLimitService: Increment usage
7. API → Client: Return decision
```

### Example 3: Analytics Dashboard
```
1. Client → API: GET /api/v1/analytics/dashboard?dateRange=7d
2. API → AnalyticsService: getAnalyticsDashboard(userId, "7d")
3. AnalyticsService → PostgreSQL: Complex queries
   a. SELECT COUNT(*) FROM analytics_events WHERE user_id = X AND created_at >= startDate
   b. SELECT keyword, COUNT(*) FROM analytics_events GROUP BY keyword
   c. SELECT date, SUM(posts_blocked) FROM analytics_daily_summary
4. AnalyticsService → API: Aggregated results
5. API → Client: Return dashboard
```

### Example 4: Rate Limit Check
```
1. Client → API: POST /api/v1/filter/classify
2. API → RateLimitService: checkAndEnforce(userId, tier)
3. RateLimitService → PostgreSQL: Get current usage
4. If over limit: Throw 429 error
5. If under limit: Increment counter + Process request
```

---

## Database Migrations

Created migration file: `001_create_analytics_tables.ts`

**Tables Created**:
1. `analytics_events` - Individual filter events (high volume)
2. `analytics_daily_summary` - Daily aggregated stats
3. `analytics_keyword_stats` - Keyword effectiveness
4. `filter_logs` - Detailed filter logs
5. `ai_classification_cache` - AI result cache with TTL
6. `rate_limit_tracking` - Rate limit usage per user

**Indexes Created**:
- `(user_id, created_at)` - Fast user queries
- `(cache_key)` - Fast cache lookups
- `(expires_at)` - Fast cleanup queries
- `(post_id)` - Fast post lookups
- GIN index on `matched_keywords` JSONB - Full-text search

---

## API Endpoints (Updated)

### Firebase-backed Endpoints
```
GET    /api/v1/users/{id}              # Get user profile
PUT    /api/v1/users/{id}              # Update profile
POST   /api/v1/keywords                # Add keyword
DELETE /api/v1/keywords/{id}           # Remove keyword
GET    /api/v1/filter/config           # Get filter config
PUT    /api/v1/filter/config           # Update config
```

### PostgreSQL-backed Endpoints
```
POST   /api/v1/filter/classify         # Classify post (with cache)
POST   /api/v1/filter/log              # Log filter event
GET    /api/v1/analytics/dashboard     # Get dashboard
GET    /api/v1/analytics/keywords      # Get keyword stats
GET    /api/v1/analytics/daily         # Get daily stats
GET    /api/v1/analytics/export        # Export as CSV
GET    /api/v1/rate-limit/status       # Get rate limit status
```

---

## Performance Characteristics

### Firebase Operations
- **Read**: ~50-100ms
- **Write**: ~100-200ms
- **Real-time updates**: < 100ms
- **Scalability**: Automatic

### PostgreSQL Operations
- **Simple query**: ~10-50ms
- **Complex aggregation**: ~100-500ms
- **Batch insert (500 rows)**: ~50-100ms
- **Full-text search**: ~50-200ms

### Caching Benefits
- **Cache hit**: ~5-10ms (vs 500-800ms for AI call)
- **Expected hit rate**: 70%+
- **Effective AI call reduction**: 70%

---

## Cost Analysis

### Firebase Costs
- **Reads**: $0.06 per 100K reads
- **Writes**: $0.18 per 100K writes
- **Deletes**: $0.02 per 100K deletes
- **Storage**: $0.18 per GB/month

**Estimated for 10K users**:
- ~1M reads/day = $1.80/day
- ~500K writes/day = $2.70/day
- **Total**: ~$135/month

### PostgreSQL Costs (AWS RDS)
- **db.t3.micro**: ~$15/month
- **db.t3.small**: ~$30/month
- **Storage**: $0.10 per GB/month

**Estimated for 10K users**:
- **Total**: ~$30-50/month

### Hybrid Total
- **Firebase**: ~$135/month
- **PostgreSQL**: ~$30/month
- **Total**: ~$165/month

**vs Firebase-only**: ~$300/month (with analytics overhead)
**Savings**: ~45%

---

## Security Considerations

### Firebase Security
- Firebase Authentication handles user auth
- Security rules control data access
- No direct database access
- Encrypted in transit and at rest

### PostgreSQL Security
- Backend API handles all access
- No direct client access
- API authentication required (JWT)
- Encrypted connections (SSL/TLS)
- Row-level security possible

### Data Privacy
- User keywords encrypted in Firebase
- Analytics anonymized in PostgreSQL
- No sensitive data in cache
- GDPR compliance possible

---

## Scalability Plan

### Phase 1: Current (10K users)
- Firebase for user data
- PostgreSQL for analytics
- Redis for caching

### Phase 2: Growth (100K users)
- Firebase auto-scales
- PostgreSQL read replicas
- Redis cluster

### Phase 3: Scale (1M+ users)
- Firebase sharding (by region)
- PostgreSQL horizontal partitioning
- Elasticsearch for search

---

## Implementation Timeline

### Week 1: Firebase Setup
- [ ] Create Firestore collections
- [ ] Set up Firebase Authentication
- [ ] Configure security rules
- [ ] Implement FirebaseService

### Week 2: PostgreSQL Setup
- [ ] Create analytics tables
- [ ] Set up indexes
- [ ] Implement AnalyticsService
- [ ] Run migrations

### Week 3: Services Integration
- [ ] Implement CacheService
- [ ] Implement RateLimitService
- [ ] Integrate with filtering engine
- [ ] Test data flow

### Week 4: API Endpoints
- [ ] Create all endpoints
- [ ] Add error handling
- [ ] Add rate limiting
- [ ] Add logging

### Week 5: Testing & Optimization
- [ ] Unit tests
- [ ] Integration tests
- [ ] Performance testing
- [ ] Optimization

---

## Files Created

```
backend/
├── src/
│   ├── services/
│   │   ├── FirebaseService.ts          ✅ Created
│   │   ├── AnalyticsService.ts         ✅ Created
│   │   ├── CacheService.ts             ✅ Created
│   │   ├── RateLimitService.ts         ✅ Created
│   │   ├── KeywordMatcher.ts           ✅ Existing
│   │   ├── AIClassifierService.ts      ✅ Existing
│   │   └── FilterDecisionEngine.ts     ✅ Existing
│   └── database/
│       └── migrations/
│           └── 001_create_analytics_tables.ts  ✅ Created
│
├── FIREBASE_LIMITATIONS_ANALYSIS.md    ✅ Created
└── HYBRID_DATABASE_ARCHITECTURE.md     ✅ This file
```

---

## Key Decisions Made

1. **Firebase for user data** - Real-time, auth, security rules
2. **PostgreSQL for analytics** - Complex queries, aggregations
3. **Hybrid approach** - Best of both worlds
4. **24-hour cache TTL** - Balance between freshness and performance
5. **Batch logging** - Efficient high-volume event tracking
6. **Tiered rate limiting** - Free/premium/pro tiers
7. **JSONB for keywords** - Flexible, queryable JSON storage

---

## Next Steps

1. **Implement Firebase Integration**
   - Set up Firebase SDK
   - Create Firestore collections
   - Implement FirebaseService methods

2. **Run Database Migrations**
   - Create PostgreSQL tables
   - Set up indexes
   - Verify schema

3. **Integrate Services**
   - Connect services to API
   - Test data flow
   - Add error handling

4. **Create API Endpoints**
   - Implement all endpoints
   - Add validation
   - Add rate limiting

5. **Testing & Deployment**
   - Unit tests
   - Integration tests
   - Performance testing
   - Deploy to production

---

## Conclusion

The **hybrid Firebase + PostgreSQL architecture** provides:
- ✅ Real-time user data with Firebase
- ✅ Complex analytics with PostgreSQL
- ✅ High performance with caching
- ✅ Cost-effective solution (~$165/month)
- ✅ Scalable to millions of users
- ✅ Secure and compliant

**Status**: Ready for implementation
**Next Phase**: Firebase integration and API endpoints
