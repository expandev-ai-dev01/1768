import { useMutation, useQueryClient } from '@tanstack/react-query';
import { productService } from '../services/productService';
import { ProductDeleteDTO } from '../types';

export const useDeleteProduct = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: ProductDeleteDTO) => productService.delete(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
};
