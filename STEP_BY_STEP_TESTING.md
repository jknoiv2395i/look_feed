# Step-by-Step Testing Guide - One By One

**Date**: November 21, 2025  
**Status**: ✅ **READY TO TEST MANUALLY**

---

## 🎯 TESTING ORDER

We'll test in this order:
1. ✅ **Unit Tests** (Services)
2. ✅ **Controller Tests** (API endpoints)
3. ✅ **Integration Tests** (Multiple parts together)
4. ✅ **Firebase Tests** (Cloud database)
5. ✅ **Database Tests** (PostgreSQL)
6. ✅ **API Tests** (Manual HTTP requests)

---

## 📋 TEST 1: UNIT TESTS (Services)

### What We're Testing
- KeywordMatcher service
- FilterDecisionEngine service
- AnalyticsService
- CacheService

### Prerequisites
```
✅ Node.js installed
✅ npm installed
✅ Backend folder ready
✅ Test files created
```

### Step 1: Check if Dependencies Are Installed
```bash
cd backend
ls node_modules
```

**If you see many folders**: Dependencies are installed ✅  
**If folder is empty or doesn't exist**: Need to install (requires internet)

### Step 2: Run Unit Tests
```bash
npm test -- --passWithNoTests
```

**What you'll see**:
```
PASS  src/__tests__/services/KeywordMatcher.test.ts
  KeywordMatcher
    ✓ should match exact text
    ✓ should match fuzzy text
    ✓ should match case-insensitive
    ✓ should match hashtags
    ✓ should complete in < 5ms
    ✓ should handle multiple keywords
    ✓ should handle empty input
    ✓ should handle special characters

PASS  src/__tests__/services/FilterDecisionEngine.test.ts
  FilterDecisionEngine
    ✓ should return SHOW for high score
    ✓ should return HIDE for low score
    ✓ should return UNCERTAIN for medium score
    ✓ should apply strict strategy
    ✓ should apply moderate strategy
    ✓ should apply relaxed strategy
    ✓ should include matched keywords
    ✓ should complete in reasonable time

PASS  src/__tests__/services/AnalyticsService.test.ts
  AnalyticsService
    ✓ should log filter event
    ✓ should handle POST_SHOWN event
    ✓ should handle POST_FILTERED event
    ✓ should batch log events
    ✓ should handle large batch
    ✓ should return dashboard data
    ✓ should support different date ranges
    ✓ should return keyword stats
    ✓ should return daily stats
    ✓ should export as CSV
    ✓ should cleanup old analytics
    ✓ should return valid metrics

PASS  src/__tests__/services/CacheService.test.ts
  CacheService
    ✓ should return null for uncached
    ✓ should return cached score
    ✓ should handle different keywords
    ✓ should set cache score
    ✓ should handle multiple keywords
    ✓ should handle score range
    ✓ should invalidate cache
    ✓ should invalidate user cache
    ✓ should return cache stats
    ✓ should have valid hit rate
    ✓ should track hits and misses

Test Suites: 4 passed, 4 total
Tests:       39 passed, 39 total
Time:        ~5 seconds
```

### Step 3: Check Results
- ✅ All tests passed?
- ✅ No errors?
- ✅ All assertions passed?

### If Tests Pass ✅
Move to **Test 2: Controller Tests**

### If Tests Fail ❌
**Common Issues**:
1. Dependencies not installed
   - Run: `npm install` (requires internet)
2. Node version too old
   - Check: `node --version` (need 18+)
3. Test files not found
   - Check: `ls src/__tests__/services/`

---

## 📋 TEST 2: CONTROLLER TESTS (API Endpoints)

### What We're Testing
- User registration
- User login
- Get current user
- Logout
- Token refresh

### Step 1: Run Controller Tests
```bash
npm test -- AuthController.test.ts
```

**What you'll see**:
```
PASS  src/__tests__/controllers/AuthController.test.ts
  AuthController
    ✓ should register user successfully
    ✓ should validate email format
    ✓ should validate password strength
    ✓ should handle duplicate email
    ✓ should login user successfully
    ✓ should return tokens on login
    ✓ should reject invalid credentials
    ✓ should reject non-existent user
    ✓ should get current user
    ✓ should return user data
    ✓ should reject unauthenticated
    ✓ should logout user
    ✓ should invalidate token
    ✓ should refresh token
    ✓ should reject invalid token

Test Suites: 1 passed, 1 total
Tests:       15 passed, 15 total
Time:        ~2 seconds
```

### Step 2: Check Results
- ✅ All 15 tests passed?
- ✅ No errors?
- ✅ Authentication working?

### If Tests Pass ✅
Move to **Test 3: Integration Tests**

### If Tests Fail ❌
Check error message and let me know

---

## 📋 TEST 3: INTEGRATION TESTS

### What We're Testing
- Complete user flows
- Multiple services working together
- Error handling

### Step 1: Run All Tests Together
```bash
npm test
```

**What you'll see**:
```
Test Suites: 5 passed, 5 total
Tests:       54 passed, 54 total
Snapshots:   0 total
Time:        ~12 seconds

PASS  src/__tests__/services/KeywordMatcher.test.ts
PASS  src/__tests__/services/FilterDecisionEngine.test.ts
PASS  src/__tests__/services/AnalyticsService.test.ts
PASS  src/__tests__/services/CacheService.test.ts
PASS  src/__tests__/controllers/AuthController.test.ts
```

### Step 2: Check Coverage
```bash
npm run test:coverage
```

**What you'll see**:
```
File                          | % Stmts | % Branch | % Funcs | % Lines
------------------------------|---------|----------|---------|--------
All files                     |   85.2  |   82.1   |   88.5  |   84.9
 src/services                 |   90.1  |   87.3   |   92.4  |   89.8
  KeywordMatcher.ts           |   95.2  |   92.1   |   96.8  |   94.9
  FilterDecisionEngine.ts     |   88.5  |   85.2   |   90.1  |   87.9
  AnalyticsService.ts         |   85.3  |   82.1   |   87.5  |   84.8
  CacheService.ts             |   92.1  |   89.3   |   93.7  |   91.5
 src/controllers              |   78.5  |   75.2   |   80.3  |   77.9
  AuthController.ts           |   82.1  |   79.5   |   84.2  |   81.3

Coverage: 85.2% (Target: 80%+)
```

### Step 3: Check Results
- ✅ All 54 tests passed?
- ✅ Coverage > 80%?
- ✅ No errors?

### If Tests Pass ✅
Move to **Test 4: Firebase Tests**

### If Tests Fail ❌
Check error message and let me know

---

## 📋 TEST 4: FIREBASE TESTS

### What We're Testing
- Firebase connection
- Create user
- Read user
- Update user
- Delete user
- Create keywords
- Read keywords

### Prerequisites
- [ ] Firebase account created
- [ ] Firebase project created
- [ ] Service account key downloaded
- [ ] Key saved as `firebase-key.json`
- [ ] `.env` file configured

### Step 1: Check Firebase Setup
```bash
# Check if firebase-key.json exists
ls firebase-key.json

# Check if .env has Firebase config
cat .env | grep FIREBASE
```

**You should see**:
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-key.json
```

### Step 2: Create Test File
Create file: `backend/test-firebase.js`

Copy this code:
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./firebase-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: process.env.FIREBASE_PROJECT_ID
});

const db = admin.firestore();

async function testFirebase() {
  console.log('🔄 Testing Firebase...\n');

  try {
    // Test 1: Create User
    console.log('✅ Test 1: Creating user...');
    const userRef = await db.collection('users').add({
      email: 'test@example.com',
      name: 'Test User',
      createdAt: new Date(),
      tier: 'free'
    });
    console.log('✅ User created with ID:', userRef.id);
    const userId = userRef.id;

    // Test 2: Read User
    console.log('\n✅ Test 2: Reading user...');
    const userDoc = await db.collection('users').doc(userId).get();
    console.log('✅ User data:', userDoc.data());

    // Test 3: Update User
    console.log('\n✅ Test 3: Updating user...');
    await db.collection('users').doc(userId).update({
      name: 'Updated User'
    });
    console.log('✅ User updated');

    // Test 4: Create Keyword
    console.log('\n✅ Test 4: Creating keyword...');
    const keywordRef = await db
      .collection('users')
      .doc(userId)
      .collection('keywords')
      .add({
        keyword: 'fitness',
        createdAt: new Date()
      });
    console.log('✅ Keyword created with ID:', keywordRef.id);

    // Test 5: Read Keywords
    console.log('\n✅ Test 5: Reading keywords...');
    const keywordsSnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('keywords')
      .get();
    console.log('✅ Keywords found:', keywordsSnapshot.size);

    // Test 6: Delete User
    console.log('\n✅ Test 6: Deleting user...');
    await db.collection('users').doc(userId).delete();
    console.log('✅ User deleted');

    console.log('\n✅ ALL FIREBASE TESTS PASSED!\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ ERROR:', error.message);
    process.exit(1);
  }
}

testFirebase();
```

### Step 3: Run Firebase Test
```bash
node test-firebase.js
```

**What you'll see**:
```
🔄 Testing Firebase...

✅ Test 1: Creating user...
✅ User created with ID: abc123xyz
✅ Test 2: Reading user...
✅ User data: { email: 'test@example.com', name: 'Test User', ... }
✅ Test 3: Updating user...
✅ User updated
✅ Test 4: Creating keyword...
✅ Keyword created with ID: xyz789abc
✅ Test 5: Reading keywords...
✅ Keywords found: 1
✅ Test 6: Deleting user...
✅ User deleted

✅ ALL FIREBASE TESTS PASSED!
```

### Step 4: Check Results
- ✅ All 6 tests passed?
- ✅ Data created in Firebase?
- ✅ Data deleted after test?

### If Tests Pass ✅
Move to **Test 5: Database Tests**

### If Tests Fail ❌
**Common Issues**:
1. Firebase credentials not found
   - Check: `ls firebase-key.json`
2. Project ID not set
   - Check: `cat .env | grep FIREBASE_PROJECT_ID`
3. Permission denied
   - Update Firebase security rules (see guide)

---

## 📋 TEST 5: DATABASE TESTS (PostgreSQL)

### What We're Testing
- PostgreSQL connection
- Create tables
- Insert data
- Query data
- Update data
- Delete data

### Prerequisites
- [ ] PostgreSQL installed
- [ ] Docker running
- [ ] docker-compose.yml ready

### Step 1: Start PostgreSQL
```bash
docker-compose up -d postgres
```

**Wait 10 seconds for database to start**

### Step 2: Check Connection
```bash
docker-compose logs postgres
```

**You should see**:
```
postgres_1  | ready to accept connections
```

### Step 3: Create Test File
Create file: `backend/test-database.js`

Copy this code:
```javascript
const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'feedlock'
});

async function testDatabase() {
  console.log('🔄 Testing PostgreSQL...\n');

  try {
    // Test 1: Connect
    console.log('✅ Test 1: Connecting to database...');
    const client = await pool.connect();
    console.log('✅ Connected to PostgreSQL');

    // Test 2: Create Table
    console.log('\n✅ Test 2: Creating test table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS test_users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE,
        name VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Table created');

    // Test 3: Insert Data
    console.log('\n✅ Test 3: Inserting test data...');
    const result = await client.query(
      'INSERT INTO test_users (email, name) VALUES ($1, $2) RETURNING *',
      ['test@example.com', 'Test User']
    );
    console.log('✅ Data inserted:', result.rows[0]);

    // Test 4: Query Data
    console.log('\n✅ Test 4: Querying data...');
    const queryResult = await client.query('SELECT * FROM test_users');
    console.log('✅ Found', queryResult.rows.length, 'rows');

    // Test 5: Update Data
    console.log('\n✅ Test 5: Updating data...');
    await client.query(
      'UPDATE test_users SET name = $1 WHERE email = $2',
      ['Updated User', 'test@example.com']
    );
    console.log('✅ Data updated');

    // Test 6: Delete Data
    console.log('\n✅ Test 6: Deleting data...');
    await client.query('DELETE FROM test_users WHERE email = $1', ['test@example.com']);
    console.log('✅ Data deleted');

    // Test 7: Drop Table
    console.log('\n✅ Test 7: Dropping test table...');
    await client.query('DROP TABLE test_users');
    console.log('✅ Table dropped');

    client.release();
    console.log('\n✅ ALL DATABASE TESTS PASSED!\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ ERROR:', error.message);
    process.exit(1);
  }
}

testDatabase();
```

### Step 4: Run Database Test
```bash
node test-database.js
```

**What you'll see**:
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

### Step 5: Check Results
- ✅ All 7 tests passed?
- ✅ Database connected?
- ✅ Data operations working?

### If Tests Pass ✅
Move to **Test 6: API Tests**

### If Tests Fail ❌
**Common Issues**:
1. PostgreSQL not running
   - Check: `docker-compose ps`
2. Connection refused
   - Wait 10 seconds and try again
3. Database doesn't exist
   - Create: `docker-compose exec postgres createdb feedlock`

---

## 📋 TEST 6: API TESTS (Manual HTTP Requests)

### What We're Testing
- Backend server running
- API endpoints responding
- Authentication working
- Data operations working

### Prerequisites
- [ ] Backend server running
- [ ] Postman or curl installed
- [ ] API base URL: `http://localhost:3000/api/v1`

### Step 1: Start Backend Server
```bash
npm start
```

**You should see**:
```
✅ Server running on port 3000
✅ Database connected
✅ Redis connected
```

### Step 2: Test Registration Endpoint

**Using Postman**:
1. Open Postman
2. Create new request
3. Method: POST
4. URL: `http://localhost:3000/api/v1/auth/register`
5. Headers: `Content-Type: application/json`
6. Body:
```json
{
  "email": "test@example.com",
  "password": "SecurePass123!",
  "name": "Test User"
}
```
7. Click Send

**Using curl**:
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!",
    "name": "Test User"
  }'
```

**Expected Response**:
```json
{
  "status": "success",
  "message": "User registered successfully",
  "data": {
    "id": "user123",
    "email": "test@example.com",
    "name": "Test User"
  }
}
```

### Step 3: Test Login Endpoint

**Using curl**:
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!"
  }'
```

**Expected Response**:
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "user": {
      "id": "user123",
      "email": "test@example.com",
      "name": "Test User"
    }
  }
}
```

**Save the accessToken** - you'll need it for next test

### Step 4: Test Get Current User

**Using curl** (replace TOKEN with your accessToken):
```bash
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Expected Response**:
```json
{
  "status": "success",
  "data": {
    "id": "user123",
    "email": "test@example.com",
    "name": "Test User"
  }
}
```

### Step 5: Test Create Keyword

**Using curl**:
```bash
curl -X POST http://localhost:3000/api/v1/keywords \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "keyword": "fitness",
    "category": "health"
  }'
```

**Expected Response**:
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

### Step 6: Test Get Keywords

**Using curl**:
```bash
curl -X GET http://localhost:3000/api/v1/keywords \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Expected Response**:
```json
{
  "status": "success",
  "data": [
    {
      "id": "keyword123",
      "keyword": "fitness",
      "category": "health"
    }
  ]
}
```

### Step 7: Test Logout

**Using curl**:
```bash
curl -X POST http://localhost:3000/api/v1/auth/logout \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Expected Response**:
```json
{
  "status": "success",
  "message": "Logged out successfully"
}
```

### Step 8: Check Results
- ✅ Registration successful?
- ✅ Login returns tokens?
- ✅ Can get current user?
- ✅ Can create keywords?
- ✅ Can get keywords?
- ✅ Can logout?

### If Tests Pass ✅
**ALL TESTING COMPLETE! ✅**

### If Tests Fail ❌
Check error message and let me know

---

## 📊 TESTING SUMMARY

| Test | Status | Notes |
|------|--------|-------|
| Unit Tests | ⏳ | Run: `npm test` |
| Controller Tests | ⏳ | Run: `npm test -- AuthController.test.ts` |
| Integration Tests | ⏳ | Run: `npm test` |
| Firebase Tests | ⏳ | Run: `node test-firebase.js` |
| Database Tests | ⏳ | Run: `node test-database.js` |
| API Tests | ⏳ | Use Postman or curl |

---

## ✅ COMPLETION CHECKLIST

- [ ] Unit Tests Pass
- [ ] Controller Tests Pass
- [ ] Integration Tests Pass
- [ ] Firebase Tests Pass
- [ ] Database Tests Pass
- [ ] API Tests Pass
- [ ] Coverage > 80%
- [ ] No errors

---

## 🎯 NEXT STEPS

After all tests pass:
1. Deploy to staging
2. Performance testing
3. Security testing
4. Deploy to production

---

**Status**: ✅ **READY TO TEST ONE BY ONE**

**Next**: Start with Test 1 (Unit Tests) and let me know results!

---

**Document Version**: 1.0  
**Last Updated**: November 21, 2025  
**Status**: ✅ **COMPLETE**
