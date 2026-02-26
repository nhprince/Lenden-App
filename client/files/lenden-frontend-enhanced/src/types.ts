export interface Product {
    id: string;
    name: string;
    subText: string;
    sku: string;
    category: string;
    qty: number;
    costPrice: number;
    sellingPrice: number;
    imageUrl: string;
    isLowStock?: boolean;
    isOutOfStock?: boolean;
    engineNo?: string;
    chassisNo?: string;
    modelYear?: string;
    materialCost?: number;
    minStockLevel?: number;
}

export interface Transaction {
    id: string;
    orderId: string;
    customerName: string;
    date: string;
    itemCount: number;
    total: number;
    amount: number;
    paid_amount?: number;
    due_amount?: number;
    status: 'Completed' | 'Pending' | 'Cancelled';
}

export interface StatItem {
    label: string;
    value: string;
    icon: string;
    trend: string;
    trendUp?: boolean;
    colorClass?: string;
    trendColorClass?: string;
}

export interface Customer {
    id: string;
    name: string;
    email: string;
    phone: string;
    totalSpent: number;
    lastVisit: string;
    avatarUrl: string;
}

export interface CartItem extends Product {
    cartQty: number;
}

export interface User {
    name: string;
    email: string;
    role: string;
    avatarUrl: string;
}

export interface ShopDetails {
    id: string;
    name: string;
    address: string;
    phone: string;
    email: string;
    website: string;
    logoUrl: string;
    businessType?: 'bike_sales' | 'garage' | 'furniture' | 'showroom' | 'pickup_rental';
}

export const INITIAL_SHOP_DETAILS: ShopDetails = {
    id: "",
    name: "My Shop",
    address: "",
    phone: "",
    email: "",
    website: "",
    logoUrl: ""
};

export interface InvoiceSettings {
    headerTitle: string;
    footerNote: string;
    terms: string;
    showLogo: boolean;
    currencySymbol: string;
}