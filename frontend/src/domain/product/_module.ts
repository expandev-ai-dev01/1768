/**
 * @module product
 * @summary Manages product information, including creation, listing, updating, and deletion.
 * @domain functional
 * @dependencies @/core/lib/api, @tanstack/react-query
 * @version 1.0.0
 */

// Types
export * from './types';

// Services
export * from './services/productService';

// Hooks
export * from './hooks/useProductList';
export * from './hooks/useCreateProduct';
export * from './hooks/useUpdateProduct';
export * from './hooks/useDeleteProduct';

// Components
// export * from './components/ProductList';
// export * from './components/ProductForm';
// export * from './components/DeleteProductDialog';
