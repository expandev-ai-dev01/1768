import { NavLink, Outlet } from 'react-router-dom';
import { cn } from '@/core/lib/utils';

const navigation = [
  { name: 'Dashboard', href: '/dashboard', end: true },
  { name: 'Products', href: '/dashboard/products' },
  { name: 'Stock Movements', href: '/dashboard/stock-movements' },
];

export const DashboardLayout = () => {
  return (
    <div className="flex min-h-screen">
      <aside className="w-64 bg-gray-800 text-white flex-shrink-0">
        <div className="p-4">
          <h1 className="text-2xl font-bold">StockBox</h1>
        </div>
        <nav className="mt-4">
          <ul>
            {navigation.map((item) => (
              <li key={item.name}>
                <NavLink
                  to={item.href}
                  end={item.end}
                  className={({ isActive }) =>
                    cn('block px-4 py-2 hover:bg-gray-700', isActive ? 'bg-gray-900' : '')
                  }
                >
                  {item.name}
                </NavLink>
              </li>
            ))}
          </ul>
        </nav>
      </aside>
      <div className="flex-1 flex flex-col">
        <header className="bg-white shadow-sm p-4">{/* Header content, e.g., user menu */}</header>
        <main className="flex-1 p-6 bg-gray-100">
          <Outlet />
        </main>
      </div>
    </div>
  );
};
