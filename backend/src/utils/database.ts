/**
 * @summary
 * Database utility functions and connection management
 *
 * @module utils/database
 *
 * @description
 * Provides database connection pooling, query execution utilities,
 * and transaction management for SQL Server operations.
 */

import sql from 'mssql';
import { config } from '@/config';

export enum ExpectedReturn {
  Single = 'single',
  Multi = 'multi',
  None = 'none',
}

export interface IRecordSet<T = any> {
  recordset: T[];
}

let pool: sql.ConnectionPool | null = null;

export async function getPool(): Promise<sql.ConnectionPool> {
  if (!pool) {
    pool = await sql.connect(config.database);
  }
  return pool;
}

export async function dbRequest(
  routine: string,
  parameters: any,
  expectedReturn: ExpectedReturn,
  transaction?: sql.Transaction,
  resultSetNames?: string[]
): Promise<any> {
  const currentPool = transaction || (await getPool());
  const request = currentPool.request();

  if (parameters) {
    Object.keys(parameters).forEach((key) => {
      request.input(key, parameters[key]);
    });
  }

  const result = await request.execute(routine);

  if (expectedReturn === ExpectedReturn.None) {
    return null;
  }

  if (expectedReturn === ExpectedReturn.Single) {
    return result.recordset[0];
  }

  if (expectedReturn === ExpectedReturn.Multi) {
    if (resultSetNames && resultSetNames.length > 0) {
      const namedResults: any = {};
      resultSetNames.forEach((name, index) => {
        namedResults[name] = result.recordsets[index];
      });
      return namedResults;
    }
    return result.recordsets;
  }

  return result.recordset;
}

export async function beginTransaction(): Promise<sql.Transaction> {
  const currentPool = await getPool();
  const transaction = new sql.Transaction(currentPool);
  await transaction.begin();
  return transaction;
}

export async function commitTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.commit();
}

export async function rollbackTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.rollback();
}

export async function closePool(): Promise<void> {
  if (pool) {
    await pool.close();
    pool = null;
  }
}
