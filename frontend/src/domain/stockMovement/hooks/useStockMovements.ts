import { useQuery } from '@tanstack/react-query';
import { stockMovementService } from '../services/stockMovementService';

export const useStockMovements = (params?: {
  page?: number;
  pageSize?: number;
  filter?: string;
}) => {
  return useQuery({
    queryKey: ['stockMovements', params],
    queryFn: () => stockMovementService.list(params),
  });
};
