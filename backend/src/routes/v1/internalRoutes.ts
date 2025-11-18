/**
 * @summary
 * Internal (authenticated) API routes configuration
 *
 * @module routes/v1/internalRoutes
 *
 * @description
 * Configures authenticated API endpoints that require valid credentials.
 */

import { Router } from 'express';
import * as productController from '@/api/v1/internal/product/controller';
import * as stockMovementController from '@/api/v1/internal/stock-movement/controller';

const router = Router();

// Product routes
router.post('/product', productController.createHandler);
router.get('/product', productController.listHandler);
router.get('/product/:id', productController.getHandler);
router.put('/product/:id', productController.updateHandler);
router.delete('/product/:id', productController.deleteHandler);

// Stock Movement routes
router.post('/stock-movement/entry', stockMovementController.createEntryHandler);
router.post('/stock-movement/exit', stockMovementController.createExitHandler);
router.post('/stock-movement/adjustment', stockMovementController.createAdjustmentHandler);
router.get('/stock-movement', stockMovementController.listHandler);

export default router;
