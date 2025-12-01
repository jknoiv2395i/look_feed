import { Request, Response } from 'express';
import AuthController from '@controllers/AuthController';

describe('AuthController', () => {
  let controller: AuthController;
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;

  beforeEach(() => {
    controller = new AuthController();
    mockReq = {
      body: {},
      userId: undefined,
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
  });

  describe('register', () => {
    it('should register user successfully', async () => {
      mockReq.body = {
        email: 'test@example.com',
        password: 'SecurePass123!',
        name: 'Test User',
      };

      await controller.register(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalled();
    });

    it('should validate email format', async () => {
      mockReq.body = {
        email: 'invalid-email',
        password: 'SecurePass123!',
        name: 'Test User',
      };

      await controller.register(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(400);
    });

    it('should validate password strength', async () => {
      mockReq.body = {
        email: 'test@example.com',
        password: 'weak',
        name: 'Test User',
      };

      await controller.register(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(400);
    });

    it('should handle duplicate email', async () => {
      mockReq.body = {
        email: 'existing@example.com',
        password: 'SecurePass123!',
        name: 'Test User',
      };

      // First registration
      await controller.register(mockReq as Request, mockRes as Response);

      // Second registration with same email
      await controller.register(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(409);
    });
  });

  describe('login', () => {
    it('should login user successfully', async () => {
      mockReq.body = {
        email: 'test@example.com',
        password: 'SecurePass123!',
      };

      await controller.login(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalled();
    });

    it('should return tokens on successful login', async () => {
      mockReq.body = {
        email: 'test@example.com',
        password: 'SecurePass123!',
      };

      await controller.login(mockReq as Request, mockRes as Response);

      const response = (mockRes.json as jest.Mock).mock.calls[0][0];
      expect(response).toHaveProperty('accessToken');
      expect(response).toHaveProperty('refreshToken');
    });

    it('should reject invalid credentials', async () => {
      mockReq.body = {
        email: 'test@example.com',
        password: 'WrongPassword123!',
      };

      await controller.login(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(401);
    });

    it('should reject non-existent user', async () => {
      mockReq.body = {
        email: 'nonexistent@example.com',
        password: 'SecurePass123!',
      };

      await controller.login(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(401);
    });
  });

  describe('getCurrentUser', () => {
    it('should return current user', async () => {
      mockReq.userId = 'user123';

      await controller.getCurrentUser(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(200);
      expect(mockRes.json).toHaveBeenCalled();
    });

    it('should return user data', async () => {
      mockReq.userId = 'user123';

      await controller.getCurrentUser(mockReq as Request, mockRes as Response);

      const response = (mockRes.json as jest.Mock).mock.calls[0][0];
      expect(response).toHaveProperty('id');
      expect(response).toHaveProperty('email');
      expect(response).toHaveProperty('name');
    });

    it('should reject unauthenticated request', async () => {
      mockReq.userId = undefined;

      await controller.getCurrentUser(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(401);
    });
  });

  describe('logout', () => {
    it('should logout user successfully', async () => {
      mockReq.userId = 'user123';

      await controller.logout(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(200);
    });

    it('should invalidate token', async () => {
      mockReq.userId = 'user123';

      await controller.logout(mockReq as Request, mockRes as Response);

      expect(mockRes.json).toHaveBeenCalledWith({ message: 'Logged out successfully' });
    });
  });

  describe('refreshToken', () => {
    it('should refresh token successfully', async () => {
      mockReq.body = {
        refreshToken: 'valid-refresh-token',
      };

      await controller.refreshToken(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(200);
    });

    it('should return new access token', async () => {
      mockReq.body = {
        refreshToken: 'valid-refresh-token',
      };

      await controller.refreshToken(mockReq as Request, mockRes as Response);

      const response = (mockRes.json as jest.Mock).mock.calls[0][0];
      expect(response).toHaveProperty('accessToken');
    });

    it('should reject invalid refresh token', async () => {
      mockReq.body = {
        refreshToken: 'invalid-token',
      };

      await controller.refreshToken(mockReq as Request, mockRes as Response);

      expect(mockRes.status).toHaveBeenCalledWith(401);
    });
  });
});
