# 📚 DETAILED TESTING STRATEGY - PART 2 (Integration, Database, API Tests)

**Date**: November 21, 2025  
**Status**: ✅ **COMPREHENSIVE TESTING PLAN**

---

## 🔗 PHASE 3: INTEGRATION TESTS (4 Tests)

### Overview
Integration tests validate complete workflows where multiple services work together.

**Duration**: 30 minutes | **Command**: `npm test -- --testPathPattern="integration"`

---

### 3.1 Authentication Flow Test

**Purpose**: Validate complete user authentication workflow

**Scenario**: User Registration → Login → Token Refresh → Logout

#### Step 1: Register User
```
Input: {
  email: "testuser@example.com",
  password: "SecurePass123!",
  name: "Test User"
}

Expected:
- Status: 201 Created
- Response: {
    id: "user123",
    email: "testuser@example.com",
    name: "Test User",
    tier: "free",
    createdAt: "2025-11-21T..."
  }

Verification:
- User exists in database
- Password hashed (not stored plaintext)
- User tier set to "free"
```

#### Step 2: Verify User in Database
```
Query: SELECT * FROM users WHERE email = "testuser@example.com"

Expected:
- User record exists
- Email verified
- Password hashed
- Tier = "free"
- createdAt timestamp valid
```

#### Step 3: Login User
```
Input: {
  email: "testuser@example.com",
  password: "SecurePass123!"
}

Expected:
- Status: 200 OK
- Response: {
    accessToken: "eyJhbGc...",
    refreshToken: "eyJhbGc...",
    expiresIn: 3600,
    user: {
      id: "user123",
      email: "testuser@example.com",
      name: "Test User"
    }
  }

Verification:
- Access token valid JWT
- Refresh token valid JWT
- Tokens have correct expiration
- User data returned
```

#### Step 4: Refresh Token
```
Input: {
  refreshToken: "eyJhbGc..."
}

Expected:
- Status: 200 OK
- Response: {
    accessToken: "eyJhbGc..." (new token),
    expiresIn: 3600
  }

Verification:
- New access token generated
- Old token still valid (grace period)
- Refresh token unchanged
```

#### Step 5: Logout User
```
Input: {
  token: "eyJhbGc..."
}

Expected:
- Status: 200 OK
- Response: {
    message: "Logged out successfully"
  }

Verification:
- Token added to blacklist
- Token no longer valid for requests
- User session ended
```

#### Step 6: Verify Token Invalidated
```
Input: {
  token: "eyJhbGc..." (logout token)
}

Expected:
- Status: 401 Unauthorized
- Error: "Token has been revoked"

Verification:
- Token cannot be used for authenticated requests
- Logout was successful
```

**Success Criteria**:
- ✅ All 6 steps complete successfully
- ✅ User created in database
- ✅ Tokens valid and working
- ✅ Logout invalidates token

---

### 3.2 Keyword Management Flow Test

**Purpose**: Validate complete keyword CRUD workflow

**Scenario**: Create → Read → Update → Delete Keywords

#### Step 1: Create Keyword
```
Input: {
  keyword: "fitness",
  category: "health"
}

Expected:
- Status: 201 Created
- Response: {
    id: "keyword123",
    keyword: "fitness",
    category: "health",
    createdAt: "2025-11-21T..."
  }

Verification:
- Keyword created in database
- Associated with user
- Timestamp valid
```

#### Step 2: Verify Keyword in Database
```
Query: SELECT * FROM keywords WHERE id = "keyword123"

Expected:
- Keyword record exists
- Linked to correct user
- Category saved
- createdAt timestamp valid
```

#### Step 3: Read Keyword
```
Input: keywordId = "keyword123"

Expected:
- Status: 200 OK
- Response: {
    id: "keyword123",
    keyword: "fitness",
    category: "health",
    createdAt: "2025-11-21T..."
  }

Verification:
- Correct keyword returned
- All fields present
- User ownership verified
```

#### Step 4: Update Keyword
```
Input: {
  keywordId: "keyword123",
  keyword: "gym",
  category: "fitness"
}

Expected:
- Status: 200 OK
- Response: {
    id: "keyword123",
    keyword: "gym",
    category: "fitness",
    updatedAt: "2025-11-21T..."
  }

Verification:
- Keyword updated in database
- Old value replaced
- updatedAt timestamp set
```

#### Step 5: Verify Update in Database
```
Query: SELECT * FROM keywords WHERE id = "keyword123"

Expected:
- keyword = "gym" (updated)
- category = "fitness" (updated)
- updatedAt timestamp valid
```

#### Step 6: Delete Keyword
```
Input: keywordId = "keyword123"

Expected:
- Status: 200 OK
- Response: {
    message: "Keyword deleted successfully"
  }

Verification:
- Keyword removed from database
- No longer accessible
```

#### Step 7: Verify Deletion
```
Query: SELECT * FROM keywords WHERE id = "keyword123"

Expected:
- No record found
- Deletion confirmed
```

**Success Criteria**:
- ✅ All 7 steps complete successfully
- ✅ CRUD operations working
- ✅ Database state correct
- ✅ User ownership enforced

---

### 3.3 Classification Flow Test

**Purpose**: Validate complete post classification workflow

**Scenario**: Create Keywords → Submit Post → Classify → Log Analytics → Cache Hit

#### Step 1: Create User Keywords
```
Input: [
  {keyword: "fitness", category: "health"},
  {keyword: "gym", category: "fitness"},
  {keyword: "workout", category: "exercise"}
]

Expected:
- Status: 201 Created (per keyword)
- 3 keywords created
- All linked to user
```

#### Step 2: Submit Post for Classification
```
Input: {
  postId: "post123",
  caption: "Just finished an amazing fitness workout at the gym!",
  hashtags: ["#fitness", "#gym", "#workout"],
  author: "instagram_user_123"
}

Expected:
- Status: 200 OK
- Response: {
    decision: "SHOW",
    confidence: 0.98,
    matchedKeywords: ["fitness", "gym", "workout"],
    reason: "Matched 3 user keywords"
  }

Verification:
- All 3 keywords matched
- High confidence score
- Correct decision (SHOW)
- Reason provided
```

#### Step 3: Verify Keyword Matching
```
Matching Logic:
- "fitness" in caption → Match
- "gym" in caption → Match
- "workout" in caption → Match
- Total matches: 3/3 keywords

Expected:
- All keywords found
- Matching algorithm working
- Score calculation correct
```

#### Step 4: Verify AI Classification
```
AI Model Input:
- Caption: "Just finished an amazing fitness workout at the gym!"
- Hashtags: ["#fitness", "#gym", "#workout"]
- Matched keywords: 3

Expected:
- AI confidence: 0.95+
- Classification: Relevant content
- Combined with keyword match: 0.98
```

#### Step 5: Verify Decision Made
```
Decision Logic:
- Matched keywords: 3 (high signal)
- AI confidence: 0.95 (high signal)
- Combined confidence: 0.98
- Threshold: 0.7
- Result: 0.98 > 0.7 → SHOW

Expected:
- Decision: SHOW
- Confidence: 0.98
- Reasoning: Matched keywords + AI confidence
```

#### Step 6: Verify Analytics Logged
```
Event Logged:
{
  type: "POST_SHOWN",
  postId: "post123",
  userId: "user123",
  matchedKeywords: ["fitness", "gym", "workout"],
  confidence: 0.98,
  timestamp: "2025-11-21T..."
}

Expected:
- Event in database
- All fields populated
- Timestamp valid
```

#### Step 7: Cache Hit on Second Request
```
Input: Same post (postId: "post123")

Expected:
- Status: 200 OK (faster)
- Response: Cached result
- No re-classification needed
- Response time: < 50ms

Verification:
- Cache hit recorded
- Same decision returned
- Performance improved
```

**Success Criteria**:
- ✅ All 7 steps complete successfully
- ✅ Keyword matching working
- ✅ AI classification working
- ✅ Decision logic correct
- ✅ Analytics logged
- ✅ Cache working

---

### 3.4 Analytics Pipeline Test

**Purpose**: Validate complete analytics workflow

**Scenario**: Log Events → Query Dashboard → Export Data

#### Step 1: Log 100 Classification Events
```
Input: 100 posts classified over 1 hour
- 70 posts shown (SHOW decision)
- 20 posts hidden (HIDE decision)
- 10 posts uncertain (UNCERTAIN decision)

Expected:
- All 100 events logged
- Correct counts per decision
- Timestamps valid
```

#### Step 2: Query Analytics Dashboard
```
Input: {
  userId: "user123",
  dateRange: "today"
}

Expected:
- Status: 200 OK
- Response: {
    totalPosts: 100,
    totalShown: 70,
    totalHidden: 20,
    totalUncertain: 10,
    showRate: 0.70,
    hideRate: 0.20,
    uncertainRate: 0.10,
    cacheHitRate: 0.65,
    topKeywords: [
      {keyword: "fitness", matches: 45, percentage: 45},
      {keyword: "gym", matches: 38, percentage: 38},
      {keyword: "workout", matches: 32, percentage: 32}
    ],
    dailyStats: [
      {date: "2025-11-21", shown: 70, hidden: 20, uncertain: 10}
    ]
  }

Verification:
- Correct totals
- Correct percentages
- Top keywords ranked
- Daily stats accurate
```

#### Step 3: Verify Keyword Statistics
```
Expected:
- fitness: 45 matches (45%)
- gym: 38 matches (38%)
- workout: 32 matches (32%)
- Total: 115 matches (some posts match multiple)

Verification:
- Counts accurate
- Percentages calculated correctly
- Ranked by frequency
```

#### Step 4: Verify Daily Statistics
```
Expected:
- Date: 2025-11-21
- Posts shown: 70
- Posts hidden: 20
- Posts uncertain: 10
- Total: 100

Verification:
- Daily aggregation correct
- Counts match events
- Timestamp valid
```

#### Step 5: Export as CSV
```
Input: {
  userId: "user123",
  dateRange: "today",
  format: "csv"
}

Expected:
- Status: 200 OK
- Content-Type: text/csv
- File: analytics_2025-11-21.csv
- Content:
  ```
  date,keyword,matches,percentage,shown,hidden,uncertain
  2025-11-21,fitness,45,45%,70,20,10
  2025-11-21,gym,38,38%,70,20,10
  2025-11-21,workout,32,32%,70,20,10
  ```

Verification:
- CSV format valid
- All data included
- Percentages correct
- File downloadable
```

#### Step 6: Export as JSON
```
Input: {
  userId: "user123",
  dateRange: "today",
  format: "json"
}

Expected:
- Status: 200 OK
- Content-Type: application/json
- File: analytics_2025-11-21.json
- Content: Complete analytics object

Verification:
- JSON format valid
- All data included
- File downloadable
```

**Success Criteria**:
- ✅ All 6 steps complete successfully
- ✅ Events logged correctly
- ✅ Dashboard data accurate
- ✅ Export formats working
- ✅ Data integrity verified

---

## 💾 PHASE 4: DATABASE TESTS (13 Operations)

### Overview
Database tests validate connectivity and CRUD operations on both Firebase and PostgreSQL.

**Duration**: 1 hour

---

### 4.1 Firebase Tests (6 Operations)

**Prerequisites**:
- Firebase account created
- Service account key downloaded
- .env configured with FIREBASE_PROJECT_ID

**Test File**: `backend/test-firebase.js`

#### Operation 1: Create User
```javascript
Input: {
  email: "test@example.com",
  name: "Test User",
  tier: "free",
  createdAt: new Date()
}

Expected:
- Document created
- Auto-generated ID
- All fields saved

Command: node test-firebase.js
Result: ✅ User created: abc123xyz
```

#### Operation 2: Read User
```javascript
Input: userId = "abc123xyz"

Expected:
- Document retrieved
- All fields present
- Data matches input

Result: ✅ User data: { email: 'test@example.com', ... }
```

#### Operation 3: Update User
```javascript
Input: {
  userId: "abc123xyz",
  name: "Updated User"
}

Expected:
- Document updated
- Only specified field changed
- Other fields unchanged

Result: ✅ User updated
```

#### Operation 4: Create Keyword
```javascript
Input: {
  userId: "abc123xyz",
  keyword: "fitness",
  createdAt: new Date()
}

Expected:
- Subcollection document created
- Linked to user
- Auto-generated ID

Result: ✅ Keyword created: xyz789abc
```

#### Operation 5: Read Keywords
```javascript
Input: userId = "abc123xyz"

Expected:
- All user keywords retrieved
- Correct count
- All fields present

Result: ✅ Keywords found: 1
```

#### Operation 6: Delete User
```javascript
Input: userId = "abc123xyz"

Expected:
- Document deleted
- No longer retrievable
- Cascading delete of subcollections

Result: ✅ User deleted
```

**Run Command**:
```bash
node test-firebase.js
```

**Expected Output**:
```
🔄 Testing Firebase...

✅ Test 1: Creating user...
✅ User created: abc123xyz
✅ Test 2: Reading user...
✅ User data: { email: 'test@example.com', name: 'Test User', ... }
✅ Test 3: Updating user...
✅ User updated
✅ Test 4: Creating keyword...
✅ Keyword created: xyz789abc
✅ Test 5: Reading keywords...
✅ Keywords found: 1
✅ Test 6: Deleting user...
✅ User deleted

✅ ALL FIREBASE TESTS PASSED!
```

**Success Criteria**:
- ✅ All 6 operations successful
- ✅ No connection errors
- ✅ Data persisted correctly

---

### 4.2 PostgreSQL Tests (7 Operations)

**Prerequisites**:
- Docker installed
- docker-compose.yml ready
- PostgreSQL running

**Test File**: `backend/test-database.js`

#### Operation 1: Connect to Database
```javascript
Expected:
- Connection established
- No timeout
- Ready for queries

Result: ✅ Connected to PostgreSQL
```

#### Operation 2: Create Table
```javascript
SQL:
CREATE TABLE IF NOT EXISTS test_users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  name VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

Expected:
- Table created
- Columns defined
- Constraints applied

Result: ✅ Table created
```

#### Operation 3: Insert Data
```javascript
SQL:
INSERT INTO test_users (email, name) VALUES ($1, $2) RETURNING *

Input: ['test@example.com', 'Test User']

Expected:
- Row inserted
- ID auto-generated
- Timestamp set

Result: ✅ Data inserted: { id: 1, email: 'test@example.com', ... }
```

#### Operation 4: Query Data
```javascript
SQL:
SELECT * FROM test_users

Expected:
- All rows returned
- Correct count
- All columns present

Result: ✅ Found 1 rows
```

#### Operation 5: Update Data
```javascript
SQL:
UPDATE test_users SET name = $1 WHERE email = $2

Input: ['Updated User', 'test@example.com']

Expected:
- Row updated
- Only specified field changed
- Other fields unchanged

Result: ✅ Data updated
```

#### Operation 6: Delete Data
```javascript
SQL:
DELETE FROM test_users WHERE email = $1

Input: ['test@example.com']

Expected:
- Row deleted
- No longer retrievable
- Count decremented

Result: ✅ Data deleted
```

#### Operation 7: Drop Table
```javascript
SQL:
DROP TABLE test_users

Expected:
- Table removed
- Schema cleaned
- No errors

Result: ✅ Table dropped
```

**Run Commands**:
```bash
docker-compose up -d postgres
sleep 10
node test-database.js
```

**Expected Output**:
```
🔄 Testing PostgreSQL...

✅ Test 1: Connecting to database...
✅ Connected to PostgreSQL
✅ Test 2: Creating test table...
✅ Table created
✅ Test 3: Inserting test data...
✅ Data inserted: { id: 1, email: 'test@example.com', name: 'Test User', ... }
✅ Test 4: Querying data...
✅ Found 1 rows
✅ Test 5: Updating data...
✅ Data updated
✅ Test 6: Deleting data...
✅ Data deleted
✅ Test 7: Dropping test table...
✅ Table dropped

✅ ALL DATABASE TESTS PASSED!
```

**Success Criteria**:
- ✅ All 7 operations successful
- ✅ No connection errors
- ✅ Data persisted correctly
- ✅ CRUD operations working

---

## 🌐 PHASE 5: API TESTS (8 Endpoints)

### Overview
API tests validate HTTP endpoints with real requests.

**Duration**: 1 hour | **Start Server**: `npm start`

---

### 5.1 Registration Endpoint

**Endpoint**: POST `/api/v1/auth/register`

**Test Case 1: Successful Registration**
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!",
    "name": "Test User"
  }'
```

**Expected Response** (Status 201):
```json
{
  "status": "success",
  "message": "User registered successfully",
  "data": {
    "id": "user123",
    "email": "test@example.com",
    "name": "Test User",
    "tier": "free",
    "createdAt": "2025-11-21T07:00:00Z"
  }
}
```

**Verification**:
- ✅ Status code: 201
- ✅ User created in database
- ✅ Password hashed
- ✅ Tier set to "free"

**Test Case 2: Invalid Email**
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "password": "SecurePass123!",
    "name": "Test User"
  }'
```

**Expected Response** (Status 400):
```json
{
  "status": "error",
  "message": "Invalid email format",
  "errors": ["email must be a valid email"]
}
```

**Verification**:
- ✅ Status code: 400
- ✅ Error message clear
- ✅ User not created

**Test Case 3: Weak Password**
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "weak",
    "name": "Test User"
  }'
```

**Expected Response** (Status 400):
```json
{
  "status": "error",
  "message": "Password does not meet strength requirements",
  "errors": ["password must be at least 8 characters", "password must contain uppercase letter"]
}
```

**Verification**:
- ✅ Status code: 400
- ✅ Error message clear
- ✅ User not created

---

### 5.2 Login Endpoint

**Endpoint**: POST `/api/v1/auth/login`

**Test Case 1: Successful Login**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!"
  }'
```

**Expected Response** (Status 200):
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600,
    "user": {
      "id": "user123",
      "email": "test@example.com",
      "name": "Test User",
      "tier": "free"
    }
  }
}
```

**Verification**:
- ✅ Status code: 200
- ✅ Access token valid JWT
- ✅ Refresh token valid JWT
- ✅ User data returned

**⚠️ Save accessToken for next tests**

**Test Case 2: Invalid Credentials**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "WrongPassword"
  }'
```

**Expected Response** (Status 401):
```json
{
  "status": "error",
  "message": "Invalid email or password",
  "errors": ["Authentication failed"]
}
```

**Verification**:
- ✅ Status code: 401
- ✅ No tokens returned
- ✅ Error message generic (prevent enumeration)

---

### 5.3 Get Current User Endpoint

**Endpoint**: GET `/api/v1/auth/me`

**Test Case 1: Successful Request**
```bash
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Expected Response** (Status 200):
```json
{
  "status": "success",
  "data": {
    "id": "user123",
    "email": "test@example.com",
    "name": "Test User",
    "tier": "free",
    "createdAt": "2025-11-21T07:00:00Z"
  }
}
```

**Verification**:
- ✅ Status code: 200
- ✅ User data returned
- ✅ Correct user ID
- ✅ All fields present

**Test Case 2: Missing Token**
```bash
curl -X GET http://localhost:3000/api/v1/auth/me
```

**Expected Response** (Status 401):
```json
{
  "status": "error",
  "message": "No token provided",
  "errors": ["Authorization header missing"]
}
```

**Verification**:
- ✅ Status code: 401
- ✅ Error message clear

---

### 5.4 Create Keyword Endpoint

**Endpoint**: POST `/api/v1/keywords`

**Test Case 1: Successful Creation**
```bash
curl -X POST http://localhost:3000/api/v1/keywords \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "keyword": "fitness",
    "category": "health"
  }'
```

**Expected Response** (Status 201):
```json
{
  "status": "success",
  "data": {
    "id": "keyword123",
    "keyword": "fitness",
    "category": "health",
    "createdAt": "2025-11-21T07:00:00Z"
  }
}
```

**Verification**:
- ✅ Status code: 201
- ✅ Keyword created in database
- ✅ Linked to user
- ✅ ID generated

---

### 5.5 Get Keywords Endpoint

**Endpoint**: GET `/api/v1/keywords`

**Test Case 1: Successful Request**
```bash
curl -X GET http://localhost:3000/api/v1/keywords \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Expected Response** (Status 200):
```json
{
  "status": "success",
  "data": [
    {
      "id": "keyword123",
      "keyword": "fitness",
      "category": "health",
      "createdAt": "2025-11-21T07:00:00Z"
    }
  ]
}
```

**Verification**:
- ✅ Status code: 200
- ✅ Array of keywords returned
- ✅ Correct count
- ✅ All fields present

---

### 5.6 Classify Post Endpoint

**Endpoint**: POST `/api/v1/filter/classify`

**Test Case 1: Successful Classification**
```bash
curl -X POST http://localhost:3000/api/v1/filter/classify \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "postId": "post123",
    "caption": "Just finished an amazing fitness workout!",
    "hashtags": ["#fitness", "#gym", "#workout"]
  }'
```

**Expected Response** (Status 200):
```json
{
  "status": "success",
  "data": {
    "decision": "SHOW",
    "confidence": 0.95,
    "matchedKeywords": ["fitness"],
    "reason": "Matched user keyword: fitness"
  }
}
```

**Verification**:
- ✅ Status code: 200
- ✅ Decision returned
- ✅ Confidence score present
- ✅ Matched keywords listed

---

### 5.7 Get Analytics Endpoint

**Endpoint**: GET `/api/v1/analytics/dashboard`

**Test Case 1: Successful Request**
```bash
curl -X GET http://localhost:3000/api/v1/analytics/dashboard \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Expected Response** (Status 200):
```json
{
  "status": "success",
  "data": {
    "totalPosts": 1,
    "totalShown": 1,
    "totalHidden": 0,
    "cacheHitRate": 0.5,
    "topKeywords": ["fitness"],
    "dailyStats": [
      {
        "date": "2025-11-21",
        "shown": 1,
        "hidden": 0,
        "uncertain": 0
      }
    ]
  }
}
```

**Verification**:
- ✅ Status code: 200
- ✅ Dashboard metrics returned
- ✅ Correct counts
- ✅ Daily stats included

---

### 5.8 Logout Endpoint

**Endpoint**: POST `/api/v1/auth/logout`

**Test Case 1: Successful Logout**
```bash
curl -X POST http://localhost:3000/api/v1/auth/logout \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Expected Response** (Status 200):
```json
{
  "status": "success",
  "message": "Logged out successfully"
}
```

**Verification**:
- ✅ Status code: 200
- ✅ Token invalidated
- ✅ Logout message clear

**Test Case 2: Use Invalidated Token**
```bash
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Expected Response** (Status 401):
```json
{
  "status": "error",
  "message": "Token has been revoked",
  "errors": ["Invalid token"]
}
```

**Verification**:
- ✅ Status code: 401
- ✅ Token no longer valid
- ✅ Logout successful

---

## ✅ EXECUTION CHECKLIST

### Integration Tests
```bash
npm test -- --testPathPattern="integration"
```
- [ ] Auth flow: ✅ Pass
- [ ] Keyword flow: ✅ Pass
- [ ] Classification flow: ✅ Pass
- [ ] Analytics flow: ✅ Pass

### Database Tests
```bash
node test-firebase.js
docker-compose up -d postgres
node test-database.js
```
- [ ] Firebase: 6/6 operations pass
- [ ] PostgreSQL: 7/7 operations pass

### API Tests
```bash
npm start
# Run all curl commands
```
- [ ] Registration: 201 ✅
- [ ] Login: 200 ✅
- [ ] Get User: 200 ✅
- [ ] Create Keyword: 201 ✅
- [ ] Get Keywords: 200 ✅
- [ ] Classify Post: 200 ✅
- [ ] Get Analytics: 200 ✅
- [ ] Logout: 200 ✅

---

**Next**: Read DETAILED_TESTING_PART_3.md for Performance, Load, and Security Tests
