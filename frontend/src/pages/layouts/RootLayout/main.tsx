import { Outlet } from 'react-router-dom';

export const RootLayout = () => {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header or Navigation can go here */}
      <main>
        <Outlet />
      </main>
      {/* Footer can go here */}
    </div>
  );
};
