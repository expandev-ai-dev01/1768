import { useMutation, useQueryClient } from '@tanstack/react-query';
import { productService } from '../services/productService';
import { ProductUpdateDTO } from '../types';

export const useUpdateProduct = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: ProductUpdateDTO) => productService.update(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
};
