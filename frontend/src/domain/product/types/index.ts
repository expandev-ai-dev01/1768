import { z } from 'zod';

export const productSchema = z.object({
  id: z.string().uuid(),
  code: z.string(),
  name: z.string(),
  description: z.string().nullable(),
  unitOfMeasure: z.string(),
  minimumStock: z.number(),
  balance: z.number(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
});

export const productCreateSchema = z.object({
  code: z
    .string()
    .min(3)
    .max(20)
    .regex(/^[A-Z0-9]+$/, 'Code must be uppercase letters and numbers'),
  name: z.string().min(3).max(100),
  description: z.string().max(500).optional(),
  unitOfMeasure: z.string(),
  minimumStock: z.coerce.number().min(0).optional().default(0),
});

export const productUpdateSchema = productCreateSchema.partial().extend({
  id: z.string().uuid(),
});

export const productDeleteSchema = z.object({
  id: z.string().uuid(),
  reason: z.string().min(10, 'Reason is required and must be at least 10 characters long.'),
});

export type Product = z.infer<typeof productSchema>;
export type ProductCreateDTO = z.infer<typeof productCreateSchema>;
export type ProductUpdateDTO = z.infer<typeof productUpdateSchema>;
export type ProductDeleteDTO = z.infer<typeof productDeleteSchema>;
