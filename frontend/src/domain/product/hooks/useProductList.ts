import { useQuery } from '@tanstack/react-query';
import { productService } from '../services/productService';

export const useProductList = (params?: { page?: number; pageSize?: number; filter?: string }) => {
  return useQuery({
    queryKey: ['products', params],
    queryFn: () => productService.list(params),
  });
};
