import { useProductList } from '@/domain/product/_module';

const ProductsPage = () => {
  const { data, isLoading, error } = useProductList();

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <h1 className="text-3xl font-bold">Products</h1>
        {/* Add Product Button will go here */}
      </div>
      {isLoading && <p>Loading products...</p>}
      {error && <p className="text-red-500">Failed to load products: {error.message}</p>}
      {data && (
        <div className="bg-white p-4 rounded-lg shadow">
          {/* ProductList component will go here */}
          <p>{data.total} products found.</p>
        </div>
      )}
    </div>
  );
};

export default ProductsPage;
