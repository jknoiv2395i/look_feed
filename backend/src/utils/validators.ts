import Joi from 'joi';
import { ValidationError } from './errors';

// User validation schemas
export const userRegistrationSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Invalid email format',
    'any.required': 'Email is required',
  }),
  password: Joi.string().min(8).required().messages({
    'string.min': 'Password must be at least 8 characters',
    'any.required': 'Password is required',
  }),
  firstName: Joi.string().optional(),
  lastName: Joi.string().optional(),
});

export const userLoginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

// Keyword validation schema
export const keywordSchema = Joi.object({
  keyword: Joi.string().min(1).max(100).required().messages({
    'string.min': 'Keyword cannot be empty',
    'string.max': 'Keyword cannot exceed 100 characters',
    'any.required': 'Keyword is required',
  }),
});

// Filter log validation schema
export const filterLogSchema = Joi.object({
  postId: Joi.string().required(),
  action: Joi.string().valid('shown', 'hidden').required(),
  relevanceScore: Joi.number().min(0).max(1).required(),
  matchedKeywords: Joi.array().items(Joi.string()).optional(),
  method: Joi.string().valid('keyword', 'ai', 'hybrid').optional(),
});

// Classification request schema
export const classificationRequestSchema = Joi.object({
  postData: Joi.object({
    id: Joi.string().required(),
    caption: Joi.string().allow('').optional(),
    hashtags: Joi.array().items(Joi.string()).optional(),
    username: Joi.string().required(),
    postUrl: Joi.string().uri().required(),
    imageUrls: Joi.array().items(Joi.string()).optional(),
    videoUrl: Joi.string().uri().allow(null).optional(),
    postType: Joi.string().valid('image', 'video', 'carousel', 'reel', 'unknown').required(),
    timestamp: Joi.string().optional(),
    likeCount: Joi.number().optional(),
    extractedAt: Joi.number().required(),
  }).required(),
  keywords: Joi.array().items(Joi.string()).min(1).required(),
});

// Filter config schema
export const filterConfigSchema = Joi.object({
  strategy: Joi.string().valid('strict', 'moderate', 'relaxed').optional(),
  enableAiClassification: Joi.boolean().optional(),
});

// Generic validation function
export function validate<T>(data: any, schema: Joi.ObjectSchema): T {
  const { error, value } = schema.validate(data, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    const details = error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message,
    }));
    throw new ValidationError('Validation failed', details);
  }

  return value as T;
}

// Email validation
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

// Password strength validation
export function validatePasswordStrength(password: string): {
  isStrong: boolean;
  feedback: string[];
} {
  const feedback: string[] = [];

  if (password.length < 8) {
    feedback.push('Password must be at least 8 characters');
  }
  if (!/[A-Z]/.test(password)) {
    feedback.push('Password must contain at least one uppercase letter');
  }
  if (!/[a-z]/.test(password)) {
    feedback.push('Password must contain at least one lowercase letter');
  }
  if (!/[0-9]/.test(password)) {
    feedback.push('Password must contain at least one number');
  }
  if (!/[!@#$%^&*]/.test(password)) {
    feedback.push('Password must contain at least one special character (!@#$%^&*)');
  }

  return {
    isStrong: feedback.length === 0,
    feedback,
  };
}
