import { dbRequest, ExpectedReturn } from '@/utils/database';
import {
  CreateEntryParams,
  CreateExitParams,
  CreateAdjustmentParams,
  ListMovementsParams,
  StockMovement,
} from './stockMovementTypes';

export async function createEntry(params: CreateEntryParams): Promise<void> {
  await dbRequest('[functional].[spStockMovementCreateEntry]', params, ExpectedReturn.None);
}

export async function createExit(params: CreateExitParams): Promise<void> {
  await dbRequest('[functional].[spStockMovementCreateExit]', params, ExpectedReturn.None);
}

export async function createAdjustment(params: CreateAdjustmentParams): Promise<void> {
  await dbRequest('[functional].[spStockMovementCreateAdjustment]', params, ExpectedReturn.None);
}

export async function listMovements(params: ListMovementsParams): Promise<StockMovement[]> {
  return dbRequest('[functional].[spStockMovementList]', params, ExpectedReturn.Multi);
}
