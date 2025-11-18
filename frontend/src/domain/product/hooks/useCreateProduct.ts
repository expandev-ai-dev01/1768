import { useMutation, useQueryClient } from '@tanstack/react-query';
import { productService } from '../services/productService';
import { ProductCreateDTO } from '../types';

export const useCreateProduct = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: ProductCreateDTO) => productService.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });
};
