import * as admin from 'firebase-admin';
import logger from '@config/logger';

/**
 * Firebase Admin SDK Configuration
 * Initializes Firebase for Firestore and Authentication
 */

let firebaseApp: admin.app.App | null = null;
let firestore: admin.firestore.Firestore | null = null;
let auth: admin.auth.Auth | null = null;

/**
 * Initialize Firebase Admin SDK
 */
export function initializeFirebase(): void {
  try {
    if (firebaseApp) {
      logger.debug('Firebase already initialized');
      return;
    }

    const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
    if (!serviceAccountPath) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT_PATH not set');
    }

    // Initialize Firebase Admin SDK
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccountPath),
      projectId: process.env.FIREBASE_PROJECT_ID,
      databaseURL: process.env.FIREBASE_DATABASE_URL,
    });

    // Get Firestore instance
    firestore = admin.firestore(firebaseApp);

    // Get Auth instance
    auth = admin.auth(firebaseApp);

    logger.info('Firebase initialized successfully');
  } catch (error) {
    logger.error('Firebase initialization error:', error);
    throw error;
  }
}

/**
 * Get Firestore instance
 */
export function getFirestore(): admin.firestore.Firestore {
  if (!firestore) {
    throw new Error('Firebase not initialized. Call initializeFirebase() first.');
  }
  return firestore;
}

/**
 * Get Auth instance
 */
export function getAuth(): admin.auth.Auth {
  if (!auth) {
    throw new Error('Firebase not initialized. Call initializeFirebase() first.');
  }
  return auth;
}

/**
 * Get Firebase app instance
 */
export function getFirebaseApp(): admin.app.App {
  if (!firebaseApp) {
    throw new Error('Firebase not initialized. Call initializeFirebase() first.');
  }
  return firebaseApp;
}

/**
 * Close Firebase connection
 */
export async function closeFirebase(): Promise<void> {
  if (firebaseApp) {
    await firebaseApp.delete();
    firebaseApp = null;
    firestore = null;
    auth = null;
    logger.info('Firebase connection closed');
  }
}

/**
 * Test Firebase connection
 */
export async function testFirebaseConnection(): Promise<boolean> {
  try {
    const db = getFirestore();
    const testRef = db.collection('_health_check').doc('test');
    await testRef.set({ timestamp: new Date() });
    await testRef.delete();
    logger.info('Firebase connection test passed');
    return true;
  } catch (error) {
    logger.error('Firebase connection test failed:', error);
    return false;
  }
}

export default {
  initializeFirebase,
  getFirestore,
  getAuth,
  getFirebaseApp,
  closeFirebase,
  testFirebaseConnection,
};
