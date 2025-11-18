import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { lazy, Suspense } from 'react';
import { ErrorBoundary } from '@/core/components/ErrorBoundary';
import { LoadingSpinner } from '@/core/components/LoadingSpinner';
import { RootLayout } from '@/pages/layouts/RootLayout';
import { DashboardLayout } from '@/pages/layouts/DashboardLayout';

const HomePage = lazy(() => import('@/pages/Home'));
const NotFoundPage = lazy(() => import('@/pages/NotFound'));
const DashboardPage = lazy(() => import('@/pages/Dashboard'));
const ProductsPage = lazy(() => import('@/pages/Products'));
const StockMovementsPage = lazy(() => import('@/pages/StockMovements'));

export const router = createBrowserRouter([
  {
    path: '/',
    element: <RootLayout />,
    errorElement: <ErrorBoundary />,
    children: [
      {
        index: true,
        element: (
          <Suspense fallback={<LoadingSpinner />}>
            <HomePage />
          </Suspense>
        ),
      },
      {
        path: 'dashboard',
        element: <DashboardLayout />,
        children: [
          {
            index: true,
            element: (
              <Suspense fallback={<LoadingSpinner />}>
                <DashboardPage />
              </Suspense>
            ),
          },
          {
            path: 'products',
            element: (
              <Suspense fallback={<LoadingSpinner />}>
                <ProductsPage />
              </Suspense>
            ),
          },
          {
            path: 'stock-movements',
            element: (
              <Suspense fallback={<LoadingSpinner />}>
                <StockMovementsPage />
              </Suspense>
            ),
          },
        ],
      },
      {
        path: '*',
        element: (
          <Suspense fallback={<LoadingSpinner />}>
            <NotFoundPage />
          </Suspense>
        ),
      },
    ],
  },
]);

export const AppRouter = () => {
  return <RouterProvider router={router} />;
};
