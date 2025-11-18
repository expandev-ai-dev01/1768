import { authenticatedClient } from '@/core/lib/api';
import { ApiResponse, PaginatedData } from '@/core/types';
import { Product, ProductCreateDTO, ProductUpdateDTO, ProductDeleteDTO } from '../types';

/**
 * @service productService
 * @summary Manages API calls for products.
 * @domain product
 * @type api-service
 */
export const productService = {
  /**
   * @endpoint GET /api/v1/internal/product
   * @summary Fetches a list of products.
   */
  async list(params?: {
    page?: number;
    pageSize?: number;
    filter?: string;
  }): Promise<PaginatedData<Product>> {
    const response = await authenticatedClient.get<ApiResponse<PaginatedData<Product>>>(
      '/product',
      { params }
    );
    return response.data.data;
  },

  /**
   * @endpoint POST /api/v1/internal/product
   * @summary Creates a new product.
   */
  async create(data: ProductCreateDTO): Promise<Product> {
    const response = await authenticatedClient.post<ApiResponse<Product>>('/product', data);
    return response.data.data;
  },

  /**
   * @endpoint PUT /api/v1/internal/product/:id
   * @summary Updates an existing product.
   */
  async update({ id, ...data }: ProductUpdateDTO): Promise<Product> {
    const response = await authenticatedClient.put<ApiResponse<Product>>(`/product/${id}`, data);
    return response.data.data;
  },

  /**
   * @endpoint DELETE /api/v1/internal/product/:id
   * @summary Deletes a product.
   */
  async delete({ id, reason }: ProductDeleteDTO): Promise<void> {
    await authenticatedClient.delete(`/product/${id}`, { data: { reason } });
  },
};
