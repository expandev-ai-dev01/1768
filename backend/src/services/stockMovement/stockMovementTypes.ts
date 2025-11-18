export interface StockMovement {
  idStockMovement: number;
  idAccount: number;
  idUser: number;
  idProduct: number;
  productName: string;
  productCode: string;
  idSupplier: number | null;
  supplierName: string | null;
  type: 'CADASTRO' | 'ENTRADA' | 'SAIDA' | 'AJUSTE' | 'EXCLUSAO';
  quantity: number;
  quantityBefore: number | null;
  movementDate: Date;
  reason: string | null;
  referenceDocument: string | null;
  destination: string | null;
  lot: string | null;
  expirationDate: Date | null;
}

export interface CreateEntryParams {
  idAccount: number;
  idUser: number;
  idProduct: number;
  quantity: number;
  idSupplier?: number | null;
  reason?: string | null;
  referenceDocument?: string | null;
  lot?: string | null;
  expirationDate?: string | null; // YYYY-MM-DD
}

export interface CreateExitParams {
  idAccount: number;
  idUser: number;
  idProduct: number;
  quantity: number;
  reason: string;
  allowNegativeStock?: boolean;
  referenceDocument?: string | null;
  destination?: string | null;
  lot?: string | null;
}

export interface CreateAdjustmentParams {
  idAccount: number;
  idUser: number;
  idProduct: number;
  newQuantity: number;
  reason: string;
  lot?: string | null;
}

export interface ListMovementsParams {
  idAccount: number;
  idProduct?: number | null;
  type?: 'ENTRADA' | 'SAIDA' | 'AJUSTE' | 'CADASTRO' | 'EXCLUSAO' | null;
  startDate?: string | null; // YYYY-MM-DD
  endDate?: string | null; // YYYY-MM-DD
  idUser?: number | null;
}
