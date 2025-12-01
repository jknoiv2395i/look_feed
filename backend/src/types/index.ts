// User Types
export interface User {
  id: string;
  email: string;
  passwordHash: string;
  firstName?: string;
  lastName?: string;
  tier: 'free' | 'premium' | 'pro';
  filterStrategy: 'strict' | 'moderate' | 'relaxed';
  isEmailVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserDTO {
  email: string;
  password: string;
  firstName?: string;
  lastName?: string;
}

export interface LoginDTO {
  email: string;
  password: string;
}

export interface TokenPayload {
  userId: string;
  email: string;
  tier: string;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  user: Omit<User, 'passwordHash'>;
}

// Keyword Types
export interface Keyword {
  id: string;
  userId: string;
  keyword: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateKeywordDTO {
  keyword: string;
}

// Post Types
export interface PostData {
  id: string;
  caption: string;
  hashtags: string[];
  username: string;
  postUrl: string;
  imageUrls: string[];
  videoUrl: string | null;
  postType: 'image' | 'video' | 'carousel' | 'reel' | 'unknown';
  timestamp?: string;
  likeCount?: number;
  extractedAt: number;
}

// Filter Types
export enum FilterDecision {
  SHOW = 'SHOW',
  HIDE = 'HIDE',
  UNCERTAIN = 'UNCERTAIN',
}

export interface MatchResult {
  score: number;
  matchedKeywords: string[];
  decision: FilterDecision;
  method: 'keyword';
}

export interface AIClassificationResult {
  score: number;
  method: 'ai' | 'cached';
  processingTimeMs: number;
}

export interface FilterResult {
  decision: FilterDecision;
  score: number;
  method: 'keyword' | 'ai' | 'hybrid';
  matchedKeywords: string[];
  processingTimeMs: number;
}

export interface ClassificationRequest {
  postData: PostData;
  keywords: string[];
}

export interface ClassificationResponse {
  relevanceScore: number;
  method: 'ai' | 'cached';
  processingTimeMs: number;
}

// Filter Log Types
export interface FilterLog {
  id: string;
  userId: string;
  postId: string;
  action: 'shown' | 'hidden';
  relevanceScore: number;
  matchedKeywords: string[];
  method: 'keyword' | 'ai' | 'hybrid';
  createdAt: Date;
}

export interface CreateFilterLogDTO {
  postId: string;
  action: 'shown' | 'hidden';
  relevanceScore: number;
  matchedKeywords?: string[];
  method?: 'keyword' | 'ai' | 'hybrid';
}

// Analytics Types
export interface AnalyticsEvent {
  id: string;
  userId: string;
  eventType: 'POST_DETECTED' | 'POST_FILTERED' | 'POST_SHOWN';
  postId: string;
  relevanceScore: number;
  matchedKeywords: string[];
  filterMethod: 'keyword' | 'ai' | 'hybrid';
  processingTimeMs: number;
  createdAt: Date;
}

export interface DailyAnalytics {
  id: string;
  userId: string;
  date: string;
  totalPostsViewed: number;
  totalPostsBlocked: number;
  blockingRate: number;
  timeSavedMinutes: number;
  createdAt: Date;
}

export interface AnalyticsDashboard {
  totalPostsViewed: number;
  totalPostsBlocked: number;
  blockingRate: number;
  timeSavedMinutes: number;
  topKeywords: Array<{
    keyword: string;
    matchCount: number;
    effectiveness: number;
  }>;
  dailyStats: Array<{
    date: string;
    postsViewed: number;
    postsBlocked: number;
  }>;
}

// Error Types
export interface ApiError {
  status: number;
  message: string;
  code: string;
  details?: any;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: ApiError;
  timestamp: string;
}

// Request Types
export interface AuthenticatedRequest {
  userId: string;
  user: User;
  token: string;
}

// Rate Limit Types
export interface RateLimitInfo {
  limit: number;
  current: number;
  remaining: number;
  resetAt: Date;
}

// Filter Config Types
export interface FilterConfig {
  userId: string;
  strategy: 'strict' | 'moderate' | 'relaxed';
  keywordShowThreshold: number;
  keywordHideThreshold: number;
  aiShowThreshold: number;
  enableAiClassification: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface UpdateFilterConfigDTO {
  strategy?: 'strict' | 'moderate' | 'relaxed';
  enableAiClassification?: boolean;
}
