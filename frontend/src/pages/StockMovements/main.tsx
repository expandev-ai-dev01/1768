import { useStockMovements } from '@/domain/stockMovement/_module';

const StockMovementsPage = () => {
  const { data, isLoading, error } = useStockMovements();

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <h1 className="text-3xl font-bold">Stock Movements</h1>
        {/* Add Movement Button will go here */}
      </div>
      {isLoading && <p>Loading movements...</p>}
      {error && <p className="text-red-500">Failed to load movements: {error.message}</p>}
      {data && (
        <div className="bg-white p-4 rounded-lg shadow">
          {/* StockMovementList component will go here */}
          <p>{data.total} movements found.</p>
        </div>
      )}
    </div>
  );
};

export default StockMovementsPage;
