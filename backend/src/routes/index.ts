/**
 * @summary
 * Main API router with version management
 *
 * @module routes
 *
 * @description
 * Configures API versioning and routes requests to appropriate version handlers.
 */

import { Router } from 'express';
import v1Routes from './v1';

const router = Router();

router.use('/v1', v1Routes);

export default router;
