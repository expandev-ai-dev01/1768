import { z } from 'zod';

export const stockMovementSchema = z.object({
  id: z.string().uuid(),
  productId: z.string().uuid(),
  productName: z.string(),
  type: z.enum(['ENTRY', 'EXIT', 'ADJUSTMENT', 'INITIAL']),
  quantity: z.number(),
  reason: z.string().nullable(),
  document: z.string().nullable(),
  createdAt: z.string().datetime(),
  user: z.object({
    id: z.string().uuid(),
    name: z.string(),
  }),
});

export const entryCreateSchema = z.object({
  productId: z.string().uuid({ message: 'Product is required.' }),
  quantity: z.coerce.number().gt(0, 'Quantity must be greater than 0.'),
  reason: z.string().optional(),
  document: z.string().optional(),
});

export const exitCreateSchema = z.object({
  productId: z.string().uuid({ message: 'Product is required.' }),
  quantity: z.coerce.number().gt(0, 'Quantity must be greater than 0.'),
  reason: z.string().min(1, 'Reason is required for exits.'),
  document: z.string().optional(),
});

export const adjustmentCreateSchema = z.object({
  productId: z.string().uuid({ message: 'Product is required.' }),
  newQuantity: z.coerce.number().min(0, 'New quantity must be 0 or greater.'),
  reason: z
    .string()
    .min(10, 'A detailed reason of at least 10 characters is required for adjustments.'),
});

export type StockMovement = z.infer<typeof stockMovementSchema>;
export type EntryCreateDTO = z.infer<typeof entryCreateSchema>;
export type ExitCreateDTO = z.infer<typeof exitCreateSchema>;
export type AdjustmentCreateDTO = z.infer<typeof adjustmentCreateSchema>;
