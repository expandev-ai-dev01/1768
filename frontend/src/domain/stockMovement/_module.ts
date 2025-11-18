/**
 * @module stockMovement
 * @summary Manages stock movements like entries, exits, and adjustments.
 * @domain functional
 * @dependencies @/core/lib/api, @tanstack/react-query
 * @version 1.0.0
 */

// Types
export * from './types';

// Services
export * from './services/stockMovementService';

// Hooks
export * from './hooks/useStockMovements';
export * from './hooks/useCreateStockMovement';

// Components
// export * from './components/StockMovementList';
// export * from './components/StockMovementForm';
