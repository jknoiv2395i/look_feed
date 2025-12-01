import { getFirestore, getAuth } from '@config/firebase';
import logger from '@config/logger';
import { User, Keyword, FilterConfig, UserStats } from '@types/index';

/**
 * Firebase Service Implementation
 * Handles all Firestore operations for user data
 */

export class FirebaseServiceImpl {
  private db = getFirestore();
  private auth = getAuth();

  /**
   * Create user in Firestore
   */
  public async createUser(userId: string, userData: Partial<User>): Promise<User> {
    try {
      const userRef = this.db.collection('users').doc(userId);
      const user: User = {
        id: userId,
        email: userData.email || '',
        name: userData.name || '',
        createdAt: new Date(),
        updatedAt: new Date(),
        tier: 'free',
        isEmailVerified: false,
      };

      await userRef.set(user);
      logger.info('User created in Firestore', { userId });
      return user;
    } catch (error) {
      logger.error('Error creating user:', error);
      throw error;
    }
  }

  /**
   * Get user from Firestore
   */
  public async getUser(userId: string): Promise<User | null> {
    try {
      const userRef = this.db.collection('users').doc(userId);
      const doc = await userRef.get();

      if (!doc.exists) {
        logger.debug('User not found', { userId });
        return null;
      }

      return doc.data() as User;
    } catch (error) {
      logger.error('Error getting user:', error);
      throw error;
    }
  }

  /**
   * Update user in Firestore
   */
  public async updateUser(userId: string, updates: Partial<User>): Promise<User> {
    try {
      const userRef = this.db.collection('users').doc(userId);
      const updateData = {
        ...updates,
        updatedAt: new Date(),
      };

      await userRef.update(updateData);
      logger.info('User updated in Firestore', { userId });

      const doc = await userRef.get();
      return doc.data() as User;
    } catch (error) {
      logger.error('Error updating user:', error);
      throw error;
    }
  }

  /**
   * Delete user from Firestore
   */
  public async deleteUser(userId: string): Promise<void> {
    try {
      const userRef = this.db.collection('users').doc(userId);
      await userRef.delete();
      logger.info('User deleted from Firestore', { userId });
    } catch (error) {
      logger.error('Error deleting user:', error);
      throw error;
    }
  }

  /**
   * Create keyword for user
   */
  public async createKeyword(userId: string, keyword: string): Promise<Keyword> {
    try {
      const keywordRef = this.db
        .collection('users')
        .doc(userId)
        .collection('keywords')
        .doc();

      const keywordData: Keyword = {
        id: keywordRef.id,
        userId,
        keyword,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      await keywordRef.set(keywordData);
      logger.info('Keyword created', { userId, keyword });
      return keywordData;
    } catch (error) {
      logger.error('Error creating keyword:', error);
      throw error;
    }
  }

  /**
   * Get all keywords for user
   */
  public async getKeywords(userId: string): Promise<Keyword[]> {
    try {
      const keywordsRef = this.db
        .collection('users')
        .doc(userId)
        .collection('keywords');

      const snapshot = await keywordsRef.get();
      const keywords: Keyword[] = [];

      snapshot.forEach((doc) => {
        keywords.push(doc.data() as Keyword);
      });

      logger.debug('Keywords retrieved', { userId, count: keywords.length });
      return keywords;
    } catch (error) {
      logger.error('Error getting keywords:', error);
      throw error;
    }
  }

  /**
   * Get single keyword
   */
  public async getKeyword(userId: string, keywordId: string): Promise<Keyword | null> {
    try {
      const keywordRef = this.db
        .collection('users')
        .doc(userId)
        .collection('keywords')
        .doc(keywordId);

      const doc = await keywordRef.get();

      if (!doc.exists) {
        logger.debug('Keyword not found', { userId, keywordId });
        return null;
      }

      return doc.data() as Keyword;
    } catch (error) {
      logger.error('Error getting keyword:', error);
      throw error;
    }
  }

  /**
   * Update keyword
   */
  public async updateKeyword(
    userId: string,
    keywordId: string,
    keyword: string
  ): Promise<Keyword> {
    try {
      const keywordRef = this.db
        .collection('users')
        .doc(userId)
        .collection('keywords')
        .doc(keywordId);

      const updateData = {
        keyword,
        updatedAt: new Date(),
      };

      await keywordRef.update(updateData);
      logger.info('Keyword updated', { userId, keywordId });

      const doc = await keywordRef.get();
      return doc.data() as Keyword;
    } catch (error) {
      logger.error('Error updating keyword:', error);
      throw error;
    }
  }

  /**
   * Delete keyword
   */
  public async deleteKeyword(userId: string, keywordId: string): Promise<void> {
    try {
      const keywordRef = this.db
        .collection('users')
        .doc(userId)
        .collection('keywords')
        .doc(keywordId);

      await keywordRef.delete();
      logger.info('Keyword deleted', { userId, keywordId });
    } catch (error) {
      logger.error('Error deleting keyword:', error);
      throw error;
    }
  }

  /**
   * Get filter configuration for user
   */
  public async getFilterConfig(userId: string): Promise<FilterConfig | null> {
    try {
      const configRef = this.db.collection('users').doc(userId).collection('config').doc('filter');
      const doc = await configRef.get();

      if (!doc.exists) {
        logger.debug('Filter config not found', { userId });
        return null;
      }

      return doc.data() as FilterConfig;
    } catch (error) {
      logger.error('Error getting filter config:', error);
      throw error;
    }
  }

  /**
   * Update filter configuration
   */
  public async updateFilterConfig(userId: string, config: Partial<FilterConfig>): Promise<FilterConfig> {
    try {
      const configRef = this.db.collection('users').doc(userId).collection('config').doc('filter');

      const updateData = {
        ...config,
        updatedAt: new Date(),
      };

      await configRef.set(updateData, { merge: true });
      logger.info('Filter config updated', { userId });

      const doc = await configRef.get();
      return doc.data() as FilterConfig;
    } catch (error) {
      logger.error('Error updating filter config:', error);
      throw error;
    }
  }

  /**
   * Get user statistics
   */
  public async getUserStats(userId: string): Promise<UserStats | null> {
    try {
      const statsRef = this.db.collection('users').doc(userId).collection('stats').doc('current');
      const doc = await statsRef.get();

      if (!doc.exists) {
        logger.debug('User stats not found', { userId });
        return null;
      }

      return doc.data() as UserStats;
    } catch (error) {
      logger.error('Error getting user stats:', error);
      throw error;
    }
  }

  /**
   * Update user statistics
   */
  public async updateUserStats(userId: string, stats: Partial<UserStats>): Promise<UserStats> {
    try {
      const statsRef = this.db.collection('users').doc(userId).collection('stats').doc('current');

      const updateData = {
        ...stats,
        updatedAt: new Date(),
      };

      await statsRef.set(updateData, { merge: true });
      logger.info('User stats updated', { userId });

      const doc = await statsRef.get();
      return doc.data() as UserStats;
    } catch (error) {
      logger.error('Error updating user stats:', error);
      throw error;
    }
  }

  /**
   * Verify email
   */
  public async verifyEmail(userId: string): Promise<void> {
    try {
      const userRef = this.db.collection('users').doc(userId);
      await userRef.update({
        isEmailVerified: true,
        updatedAt: new Date(),
      });

      logger.info('Email verified', { userId });
    } catch (error) {
      logger.error('Error verifying email:', error);
      throw error;
    }
  }

  /**
   * Check if email exists
   */
  public async emailExists(email: string): Promise<boolean> {
    try {
      const snapshot = await this.db.collection('users').where('email', '==', email).limit(1).get();
      return !snapshot.empty;
    } catch (error) {
      logger.error('Error checking email:', error);
      throw error;
    }
  }

  /**
   * Get user by email
   */
  public async getUserByEmail(email: string): Promise<User | null> {
    try {
      const snapshot = await this.db.collection('users').where('email', '==', email).limit(1).get();

      if (snapshot.empty) {
        logger.debug('User not found by email', { email });
        return null;
      }

      return snapshot.docs[0].data() as User;
    } catch (error) {
      logger.error('Error getting user by email:', error);
      throw error;
    }
  }

  /**
   * Batch create keywords
   */
  public async batchCreateKeywords(userId: string, keywords: string[]): Promise<Keyword[]> {
    try {
      const batch = this.db.batch();
      const createdKeywords: Keyword[] = [];

      keywords.forEach((keyword) => {
        const keywordRef = this.db
          .collection('users')
          .doc(userId)
          .collection('keywords')
          .doc();

        const keywordData: Keyword = {
          id: keywordRef.id,
          userId,
          keyword,
          createdAt: new Date(),
          updatedAt: new Date(),
        };

        batch.set(keywordRef, keywordData);
        createdKeywords.push(keywordData);
      });

      await batch.commit();
      logger.info('Keywords batch created', { userId, count: keywords.length });
      return createdKeywords;
    } catch (error) {
      logger.error('Error batch creating keywords:', error);
      throw error;
    }
  }

  /**
   * Delete all keywords for user
   */
  public async deleteAllKeywords(userId: string): Promise<void> {
    try {
      const keywordsRef = this.db
        .collection('users')
        .doc(userId)
        .collection('keywords');

      const snapshot = await keywordsRef.get();
      const batch = this.db.batch();

      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      logger.info('All keywords deleted', { userId });
    } catch (error) {
      logger.error('Error deleting all keywords:', error);
      throw error;
    }
  }
}

export default new FirebaseServiceImpl();
