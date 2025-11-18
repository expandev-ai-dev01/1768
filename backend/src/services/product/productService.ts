import { dbRequest, ExpectedReturn } from '@/utils/database';
import {
  Product,
  ProductCreateParams,
  ProductListParams,
  ProductGetParams,
  ProductUpdateParams,
  ProductDeleteParams,
} from './productTypes';

export async function productCreate(params: ProductCreateParams): Promise<Product> {
  return dbRequest('[functional].[spProductCreate]', params, ExpectedReturn.Single);
}

export async function productList(params: ProductListParams): Promise<Product[]> {
  return dbRequest('[functional].[spProductList]', params, ExpectedReturn.Multi);
}

export async function productGet(params: ProductGetParams): Promise<Product> {
  return dbRequest('[functional].[spProductGet]', params, ExpectedReturn.Single);
}

export async function productUpdate(params: ProductUpdateParams): Promise<Product> {
  return dbRequest('[functional].[spProductUpdate]', params, ExpectedReturn.Single);
}

export async function productDelete(params: ProductDeleteParams): Promise<void> {
  await dbRequest('[functional].[spProductDelete]', params, ExpectedReturn.None);
}
