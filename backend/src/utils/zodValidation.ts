/**
 * @summary
 * Zod validation utilities and reusable schemas
 *
 * @module utils/zodValidation
 *
 * @description
 * Provides reusable Zod validation schemas and helper functions for common data types.
 * Ensures consistent validation patterns across the application.
 */

import { z } from 'zod';

export const zString = z.string().min(1);
export const zNullableString = (maxLength?: number) => {
  let schema = z.string();
  if (maxLength) {
    schema = schema.max(maxLength);
  }
  return schema.nullable();
};

export const zName = z.string().min(1).max(200);
export const zNullableDescription = z.string().max(500).nullable();

export const zBit = z.coerce.number().int().min(0).max(1);
export const zFK = z.coerce.number().int().positive();
export const zNullableFK = z.coerce.number().int().positive().nullable();

export const zDateString = z.string().datetime();
export const zNullableDateString = z.string().datetime().nullable();

export const zNumeric = z.coerce.number();
export const zNullableNumeric = z.coerce.number().nullable();

export const zEmail = z.string().email();
export const zNullableEmail = z.string().email().nullable();
