/**
 * @summary
 * V1 API router configuration
 *
 * @module routes/v1
 *
 * @description
 * Configures V1 API routes, separating external (public) and internal (authenticated) endpoints.
 */

import { Router } from 'express';
import externalRoutes from './externalRoutes';
import internalRoutes from './internalRoutes';

const router = Router();

router.use('/external', externalRoutes);
router.use('/internal', internalRoutes);

export default router;
