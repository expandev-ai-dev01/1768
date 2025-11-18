import { Request, Response, NextFunction } from 'express';
import { CrudController, successResponse } from '@/middleware/crud';
import * as productService from '@/services/product/productService';
import {
  productCreateSchema,
  productUpdateSchema,
  productListSchema,
  productIdSchema,
  productDeleteSchema,
} from '@/services/product/productValidation';
import { z } from 'zod';

const securable = 'PRODUCT';

export async function createHandler(req: Request, res: Response, next: NextFunction) {
  const operation = new CrudController([{ securable, permission: 'CREATE' }]);
  const [validated, error] = await operation.create(req, productCreateSchema);
  if (!validated) return next(error);

  try {
    const data = await productService.productCreate({
      ...validated.credential,
      ...validated.params,
    });
    res.status(201).json(successResponse(data));
  } catch (err) {
    next(err);
  }
}

export async function listHandler(req: Request, res: Response, next: NextFunction) {
  const operation = new CrudController([{ securable, permission: 'READ' }]);
  const [validated, error] = await operation.list(req, productListSchema);
  if (!validated) return next(error);

  try {
    const data = await productService.productList({
      ...validated.credential,
      ...validated.params,
    });
    res.json(successResponse(data));
  } catch (err) {
    next(err);
  }
}

export async function getHandler(req: Request, res: Response, next: NextFunction) {
  const operation = new CrudController([{ securable, permission: 'READ' }]);
  const [validated, error] = await operation.read(req, productIdSchema);
  if (!validated) return next(error);

  try {
    const data = await productService.productGet({
      ...validated.credential,
      idProduct: validated.params.id,
    });
    res.json(successResponse(data));
  } catch (err) {
    next(err);
  }
}

export async function updateHandler(req: Request, res: Response, next: NextFunction) {
  const operation = new CrudController([{ securable, permission: 'UPDATE' }]);
  const params = { ...req.body, ...req.params };
  const [validated, error] = await operation.update(
    req,
    productUpdateSchema.extend({ id: z.coerce.number() })
  );
  if (!validated) return next(error);

  try {
    const data = await productService.productUpdate({
      ...validated.credential,
      idProduct: validated.params.id,
      ...validated.params,
    });
    res.json(successResponse(data));
  } catch (err) {
    next(err);
  }
}

export async function deleteHandler(req: Request, res: Response, next: NextFunction) {
  const operation = new CrudController([{ securable, permission: 'DELETE' }]);
  const [validated, error] = await operation.delete(req, productDeleteSchema);
  if (!validated) return next(error);

  try {
    await productService.productDelete({
      ...validated.credential,
      idProduct: validated.params.id,
      reason: validated.params.reason,
    });
    res.status(204).send();
  } catch (err) {
    next(err);
  }
}
