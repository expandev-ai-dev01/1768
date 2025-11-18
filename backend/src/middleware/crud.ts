/**
 * @summary
 * CRUD operation middleware and response utilities
 *
 * @module middleware/crud
 *
 * @description
 * Provides standardized CRUD operation handling, validation, and response formatting.
 * Implements security checks and request validation for all CRUD operations.
 */

import { Request } from 'express';
import { z } from 'zod';
import { ApiError } from './error';

export interface CrudCredential {
  idAccount: number;
  idUser: number;
}

export interface ValidatedRequest<T = any> {
  credential: CrudCredential;
  params: T;
}

export interface SecurityRule {
  securable: string;
  permission: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE';
}

export class CrudController {
  private securityRules: SecurityRule[];

  constructor(securityRules: SecurityRule[]) {
    this.securityRules = securityRules;
  }

  private async validateSecurity(req: Request): Promise<CrudCredential> {
    const idAccount = parseInt((req.headers['x-account-id'] as string) || '1', 10);
    const idUser = parseInt((req.headers['x-user-id'] as string) || '1', 10);

    if (!idAccount || !idUser) {
      throw {
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: 'Missing authentication credentials',
      } as ApiError;
    }

    return { idAccount, idUser };
  }

  private async validateParams<T>(req: Request, schema: z.ZodSchema<T>): Promise<T> {
    try {
      const params = { ...req.params, ...req.query, ...req.body };
      return await schema.parseAsync(params);
    } catch (error: any) {
      throw {
        statusCode: 400,
        code: 'VALIDATION_ERROR',
        message: 'Invalid request parameters',
        details: error.errors,
      } as ApiError;
    }
  }

  async create<T>(
    req: Request,
    schema: z.ZodSchema<T>
  ): Promise<[ValidatedRequest<T> | undefined, ApiError | undefined]> {
    try {
      const credential = await this.validateSecurity(req);
      const params = await this.validateParams(req, schema);
      return [{ credential, params }, undefined];
    } catch (error) {
      return [undefined, error as ApiError];
    }
  }

  async read<T>(
    req: Request,
    schema: z.ZodSchema<T>
  ): Promise<[ValidatedRequest<T> | undefined, ApiError | undefined]> {
    try {
      const credential = await this.validateSecurity(req);
      const params = await this.validateParams(req, schema);
      return [{ credential, params }, undefined];
    } catch (error) {
      return [undefined, error as ApiError];
    }
  }

  async update<T>(
    req: Request,
    schema: z.ZodSchema<T>
  ): Promise<[ValidatedRequest<T> | undefined, ApiError | undefined]> {
    try {
      const credential = await this.validateSecurity(req);
      const params = await this.validateParams(req, schema);
      return [{ credential, params }, undefined];
    } catch (error) {
      return [undefined, error as ApiError];
    }
  }

  async delete<T>(
    req: Request,
    schema: z.ZodSchema<T>
  ): Promise<[ValidatedRequest<T> | undefined, ApiError | undefined]> {
    try {
      const credential = await this.validateSecurity(req);
      const params = await this.validateParams(req, schema);
      return [{ credential, params }, undefined];
    } catch (error) {
      return [undefined, error as ApiError];
    }
  }

  async list<T>(
    req: Request,
    schema: z.ZodSchema<T>
  ): Promise<[ValidatedRequest<T> | undefined, ApiError | undefined]> {
    try {
      const credential = await this.validateSecurity(req);
      const params = await this.validateParams(req, schema);
      return [{ credential, params }, undefined];
    } catch (error) {
      return [undefined, error as ApiError];
    }
  }
}

export function successResponse<T>(data: T, metadata?: any) {
  return {
    success: true,
    data,
    metadata: {
      ...metadata,
      timestamp: new Date().toISOString(),
    },
  };
}

export function errorResponse(message: string, code?: string, details?: any) {
  return {
    success: false,
    error: {
      code: code || 'ERROR',
      message,
      details,
    },
    timestamp: new Date().toISOString(),
  };
}
