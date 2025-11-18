import { Request, Response, NextFunction } from 'express';
import { CrudController, successResponse } from '@/middleware/crud';
import * as stockMovementService from '@/services/stockMovement/stockMovementService';
import {
  entryCreateSchema,
  exitCreateSchema,
  adjustmentCreateSchema,
  movementListSchema,
} from '@/services/stockMovement/stockMovementValidation';

const securable = 'STOCK_MOVEMENT';

export async function createEntryHandler(req: Request, res: Response, next: NextFunction) {
  const operation = new CrudController([{ securable, permission: 'CREATE' }]);
  const [validated, error] = await operation.create(req, entryCreateSchema);
  if (!validated) return next(error);

  try {
    await stockMovementService.createEntry({
      ...validated.credential,
      ...validated.params,
    });
    res.status(204).send();
  } catch (err) {
    next(err);
  }
}

export async function createExitHandler(req: Request, res: Response, next: NextFunction) {
  const operation = new CrudController([{ securable, permission: 'CREATE' }]);
  const [validated, error] = await operation.create(req, exitCreateSchema);
  if (!validated) return next(error);

  try {
    await stockMovementService.createExit({
      ...validated.credential,
      ...validated.params,
    });
    res.status(204).send();
  } catch (err) {
    next(err);
  }
}

export async function createAdjustmentHandler(req: Request, res: Response, next: NextFunction) {
  const operation = new CrudController([{ securable, permission: 'CREATE' }]);
  const [validated, error] = await operation.create(req, adjustmentCreateSchema);
  if (!validated) return next(error);

  try {
    await stockMovementService.createAdjustment({
      ...validated.credential,
      ...validated.params,
    });
    res.status(204).send();
  } catch (err) {
    next(err);
  }
}

export async function listHandler(req: Request, res: Response, next: NextFunction) {
  const operation = new CrudController([{ securable, permission: 'READ' }]);
  const [validated, error] = await operation.list(req, movementListSchema);
  if (!validated) return next(error);

  try {
    const data = await stockMovementService.listMovements({
      ...validated.credential,
      ...validated.params,
    });
    res.json(successResponse(data));
  } catch (err) {
    next(err);
  }
}
