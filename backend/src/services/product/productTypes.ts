export interface Product {
  idProduct: number;
  idAccount: number;
  idCategory: number;
  categoryName: string;
  idUnitOfMeasure: number;
  unitOfMeasureName: string;
  code: string;
  name: string;
  description: string | null;
  minimumStock: number;
  dateCreated: Date;
  currentStock: number;
  stockStatus: 'NORMAL' | 'BAIXO' | 'CRITICO' | 'ZERADO' | 'NEGATIVO';
}

export interface ProductCreateParams {
  idAccount: number;
  idUser: number;
  idCategory: number;
  idUnitOfMeasure: number;
  code: string;
  name: string;
  description?: string | null;
  minimumStock?: number;
}

export interface ProductListParams {
  idAccount: number;
  searchTerm?: string | null;
  idCategory?: number | null;
}

export interface ProductGetParams {
  idAccount: number;
  idProduct: number;
}

export interface ProductUpdateParams {
  idAccount: number;
  idProduct: number;
  idCategory: number;
  idUnitOfMeasure: number;
  name: string;
  description?: string | null;
  minimumStock: number;
}

export interface ProductDeleteParams {
  idAccount: number;
  idUser: number;
  idProduct: number;
  reason: string;
}
