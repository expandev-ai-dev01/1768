import { z } from 'zod';
import { zFK, zNullableNumeric, zNullableString } from '@/utils/zodValidation';

export const productCreateSchema = z.object({
  idCategory: zFK,
  idUnitOfMeasure: zFK,
  code: z
    .string()
    .min(3)
    .max(20)
    .regex(/^[A-Z0-9]+$/, 'Código deve conter apenas letras maiúsculas e números'),
  name: z.string().min(3).max(100),
  description: z.string().max(500).optional().nullable(),
  minimumStock: z.coerce.number().min(0).optional().default(0),
});

export const productUpdateSchema = z.object({
  idCategory: zFK,
  idUnitOfMeasure: zFK,
  name: z.string().min(3).max(100),
  description: z.string().max(500).optional().nullable(),
  minimumStock: z.coerce.number().min(0),
});

export const productListSchema = z.object({
  searchTerm: z.string().optional().nullable(),
  idCategory: z.coerce.number().int().positive().optional().nullable(),
});

export const productIdSchema = z.object({
  id: z.coerce.number().int().positive(),
});

export const productDeleteSchema = z.object({
  id: z.coerce.number().int().positive(),
  reason: z.string().min(10).max(500),
});
