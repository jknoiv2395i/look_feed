# Feed Lock Backend API

Instagram Content Filtering Engine - Backend API built with Node.js, Express, and TypeScript.

## Overview

Feed Lock is a SaaS platform that intelligently filters Instagram feeds based on user-defined keywords and AI classification. This is the backend API that powers the filtering engine.

## Features

- **Keyword-based Filtering**: Fast client-side keyword matching with fuzzy logic
- **User Authentication**: JWT-based authentication with refresh tokens
- **Keyword Management**: CRUD operations for user keywords
- **Analytics**: Track filtering effectiveness and user behavior
- **Rate Limiting**: Tiered rate limits (free/premium/pro)
- **Caching**: Redis-based caching for performance optimization
- **Error Handling**: Comprehensive error handling and logging
- **Firebase Integration**: Spark Plan compatible (100% free)

## Tech Stack

- **Runtime**: Node.js 18+
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: Firebase Realtime Database / Firestore
- **Authentication**: Firebase Auth
- **Cache**: In-memory (optional Redis)
- **Logging**: Winston
- **Note**: AI Classification moved to client-side (Google Gemini)

## Prerequisites

- Node.js 18+
- Firebase Project (free Spark Plan)
- Firebase Admin SDK credentials

## Installation

### 1. Clone and Install Dependencies

```bash
cd backend
npm install
```

### 2. Environment Setup

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# Application
NODE_ENV=development
PORT=3000

# Firebase
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY=your-firebase-private-key
FIREBASE_CLIENT_EMAIL=your-firebase-client-email
FIREBASE_DATABASE_URL=your-firebase-database-url

# JWT
JWT_SECRET=your-secret-key-here

# Note: AI Classification is now client-side (Google Gemini)
# No OpenAI API key needed
```

### 3. Database Setup

```bash
# Run migrations
npm run migrate

# Seed database (optional)
npm run seed
```

### 4. Start Development Server

```bash
npm run dev
```

Server will start on `http://localhost:3000`

## Project Structure

```
backend/
├── src/
│   ├── config/              # Configuration files
│   │   ├── environment.ts   # Environment variables
│   │   ├── database.ts      # Database connection
│   │   ├── redis.ts         # Redis connection
│   │   └── logger.ts        # Logging setup
│   ├── middleware/          # Express middleware
│   │   ├── auth.ts          # Authentication middleware
│   │   └── errorHandler.ts  # Error handling
│   ├── services/            # Business logic
│   │   ├── KeywordMatcher.ts        # Keyword matching engine
│   │   ├── AIClassifierService.ts   # AI classification
│   │   └── FilterDecisionEngine.ts  # Filter decision logic
│   ├── controllers/         # Route controllers (TODO)
│   ├── repositories/        # Data access layer (TODO)
│   ├── routes/              # API routes (TODO)
│   ├── utils/               # Utility functions
│   │   ├── errors.ts        # Custom error classes
│   │   ├── validators.ts    # Input validation
│   │   ├── jwt.ts           # JWT utilities
│   │   └── crypto.ts        # Cryptography utilities
│   ├── types/               # TypeScript types
│   ├── database/            # Database migrations and seeds (TODO)
│   └── index.ts             # Application entry point
├── tests/                   # Test files (TODO)
├── .env.example             # Environment variables template
├── package.json             # Dependencies
├── tsconfig.json            # TypeScript configuration
└── README.md                # This file
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - Logout user

### Keywords
- `GET /api/v1/keywords` - List user keywords
- `POST /api/v1/keywords` - Add keyword
- `DELETE /api/v1/keywords/:id` - Remove keyword
- `PUT /api/v1/keywords/:id` - Update keyword

### Filtering
- `POST /api/v1/filter/log` - Log filter decision (optional)
- `GET /api/v1/filter/config` - Get filter configuration
- `POST /api/v1/filter/config` - Update filter configuration
- **Note**: Post classification is now done client-side using Google Gemini

### Analytics
- `GET /api/v1/analytics/dashboard` - Get analytics dashboard
- `GET /api/v1/analytics/keywords` - Get keyword effectiveness
- `GET /api/v1/analytics/daily` - Get daily statistics
- `GET /api/v1/analytics/export` - Export analytics as CSV

## Development

### Build

```bash
npm run build
```

### Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test:watch

# Generate coverage report
npm test:coverage
```

### Linting

```bash
# Check for linting errors
npm run lint

# Fix linting errors
npm run lint:fix
```

### Database Migrations

```bash
# Create new migration
npx knex migrate:make migration_name

# Run migrations
npm run migrate

# Rollback last migration
npm run migrate:rollback

# Reset database
npm run db:reset
```

## Deployment

### Docker

```bash
# Build Docker image
docker build -t feedlock-api .

# Run container
docker run -p 3000:3000 --env-file .env feedlock-api
```

### Environment Variables for Production

```env
NODE_ENV=production
JWT_SECRET=your-production-secret-key
OPENAI_API_KEY=sk-your-production-openai-key
DB_HOST=your-production-db-host
REDIS_HOST=your-production-redis-host
```

## Performance Targets

- Keyword matching: < 5ms per post
- API response time: < 500ms (p95)
- AI classification: < 800ms (p95)
- Cache hit rate: > 70%

## Security

- All passwords are hashed with bcrypt
- JWT tokens expire after 7 days
- Refresh tokens expire after 30 days
- All API requests require authentication
- Rate limiting prevents abuse
- Input validation on all endpoints
- SQL injection prevention with parameterized queries

## Monitoring

- Winston logging to console and files
- Error tracking with Sentry (optional)
- Performance monitoring with APM tools
- Redis cache hit rate monitoring
- Database query performance monitoring

## Troubleshooting

### Firebase Connection Error

```
Error: Failed to initialize Firebase Admin SDK
```

- Verify Firebase credentials in .env
- Check FIREBASE_PROJECT_ID is correct
- Ensure service account JSON is valid

### JWT Token Error

```
Error: Invalid token
```

- Verify JWT_SECRET is set in .env
- Check token expiration
- Ensure token format is correct (Bearer <token>)

### Note: AI Classification

AI classification is now handled client-side by the mobile app using Google Gemini. The backend no longer performs AI classification, eliminating the need for OpenAI API keys and reducing backend complexity.

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Run tests: `npm test`
4. Commit: `git commit -am 'Add feature'`
5. Push: `git push origin feature/your-feature`
6. Create Pull Request

## License

MIT

## Support

For issues and questions, please open an issue on GitHub.
