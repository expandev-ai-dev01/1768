import { authenticatedClient } from '@/core/lib/api';
import { ApiResponse, PaginatedData } from '@/core/types';
import { StockMovement, EntryCreateDTO, ExitCreateDTO, AdjustmentCreateDTO } from '../types';

/**
 * @service stockMovementService
 * @summary Manages API calls for stock movements.
 * @domain stockMovement
 * @type api-service
 */
export const stockMovementService = {
  /**
   * @endpoint GET /api/v1/internal/stock-movement
   * @summary Fetches a list of stock movements.
   */
  async list(params?: {
    page?: number;
    pageSize?: number;
    filter?: string;
  }): Promise<PaginatedData<StockMovement>> {
    const response = await authenticatedClient.get<ApiResponse<PaginatedData<StockMovement>>>(
      '/stock-movement',
      { params }
    );
    return response.data.data;
  },

  /**
   * @endpoint POST /api/v1/internal/stock-movement/entry
   * @summary Creates a new stock entry.
   */
  async createEntry(data: EntryCreateDTO): Promise<void> {
    await authenticatedClient.post('/stock-movement/entry', data);
  },

  /**
   * @endpoint POST /api/v1/internal/stock-movement/exit
   * @summary Creates a new stock exit.
   */
  async createExit(data: ExitCreateDTO): Promise<void> {
    await authenticatedClient.post('/stock-movement/exit', data);
  },

  /**
   * @endpoint POST /api/v1/internal/stock-movement/adjustment
   * @summary Creates a new stock adjustment.
   */
  async createAdjustment(data: AdjustmentCreateDTO): Promise<void> {
    await authenticatedClient.post('/stock-movement/adjustment', data);
  },
};
