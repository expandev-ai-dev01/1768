import { useMutation, useQueryClient } from '@tanstack/react-query';
import { stockMovementService } from '../services/stockMovementService';
import { EntryCreateDTO, ExitCreateDTO, AdjustmentCreateDTO } from '../types';

export const useCreateStockMovement = () => {
  const queryClient = useQueryClient();

  const mutation = useMutation({
    mutationFn: (data: {
      type: 'ENTRY' | 'EXIT' | 'ADJUSTMENT';
      payload: EntryCreateDTO | ExitCreateDTO | AdjustmentCreateDTO;
    }) => {
      switch (data.type) {
        case 'ENTRY':
          return stockMovementService.createEntry(data.payload as EntryCreateDTO);
        case 'EXIT':
          return stockMovementService.createExit(data.payload as ExitCreateDTO);
        case 'ADJUSTMENT':
          return stockMovementService.createAdjustment(data.payload as AdjustmentCreateDTO);
        default:
          return Promise.reject(new Error('Invalid movement type'));
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['stockMovements'] });
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });

  return mutation;
};
