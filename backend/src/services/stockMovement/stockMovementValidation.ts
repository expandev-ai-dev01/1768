import { z } from 'zod';
import { zFK, zNullableFK } from '@/utils/zodValidation';

export const entryCreateSchema = z.object({
  idProduct: zFK,
  quantity: z.coerce.number().gt(0),
  idSupplier: zNullableFK.optional(),
  reason: z.string().max(200).optional().nullable(),
  referenceDocument: z.string().max(50).optional().nullable(),
  lot: z.string().max(30).optional().nullable(),
  expirationDate: z
    .string()
    .date()
    .refine((val) => new Date(val) > new Date(), {
      message: 'A data de validade deve ser futura',
    })
    .optional()
    .nullable(),
});

export const exitCreateSchema = z.object({
  idProduct: zFK,
  quantity: z.coerce.number().gt(0),
  reason: z.string().min(1).max(200),
  allowNegativeStock: z.boolean().optional().default(false),
  referenceDocument: z.string().max(50).optional().nullable(),
  destination: z.string().max(100).optional().nullable(),
  lot: z.string().max(30).optional().nullable(),
});

export const adjustmentCreateSchema = z.object({
  idProduct: zFK,
  newQuantity: z.coerce.number().gte(0),
  reason: z.string().min(10).max(500),
  lot: z.string().max(30).optional().nullable(),
});

export const movementListSchema = z
  .object({
    idProduct: zFK.optional().nullable(),
    type: z.enum(['ENTRADA', 'SAIDA', 'AJUSTE', 'CADASTRO', 'EXCLUSAO']).optional().nullable(),
    startDate: z.string().date().optional().nullable(),
    endDate: z.string().date().optional().nullable(),
    idUser: zFK.optional().nullable(),
  })
  .refine(
    (data) => {
      if (data.startDate && data.endDate) {
        return new Date(data.endDate) >= new Date(data.startDate);
      }
      return true;
    },
    { message: 'A data final deve ser maior ou igual à data inicial' }
  );
