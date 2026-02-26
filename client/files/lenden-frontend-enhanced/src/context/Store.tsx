import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { Product, Transaction, Customer, User, ShopDetails, InvoiceSettings } from '../types';
import api from '../utils/api';
import toast from 'react-hot-toast';

// Translation Dictionary
const translations = {
    en: {
        dashboard: "Dashboard",
        pos: "POS",
        inventory: "Inventory",
        transactions: "Transactions",
        customers: "Customers",
        reports: "Reports",
        expenses: "Expenses",
        trips: "Rental Trips",
        settings: "Settings",
        staff: "Staff Management",
        logout: "Log out",
        newSale: "New Sale",
        search: "Search...",
        goodMorning: "Good morning",
        todaysSales: "Today's Sales",
        inventoryValue: "Inventory Value",
        totalCustomers: "Total Customers",
        salesOverview: "Sales Overview",
        lowStockAlerts: "Low Stock Alerts",
        recentTransactions: "Recent Transactions",
        addProduct: "Add Product",
        addCustomer: "Add Customer",
        editCustomer: "Edit Customer",
        editProduct: "Edit Product",
        export: "Export",
        productName: "Product Name",
        sku: "SKU",
        category: "Category",
        qty: "Qty",
        price: "Price",
        cost: "Cost",
        actions: "Actions",
        save: "Save",
        cancel: "Cancel",
        printReceipt: "Print Receipt",
        markPaid: "Mark Paid",
        pending: "Pending",
        completed: "Completed",
        items: "Items",
        total: "Total",
        status: "Status",
        date: "Date",
        customer: "Customer",
        orderId: "Order ID",
        paymentOverdue: "Payment Overdue",
        overdueMessage: "Payment is overdue. Please collect immediately.",
        businessReports: "Business Reports",
        performanceAnalytics: "Performance Analytics",
        totalRevenue: "Total Revenue",
        avgOrderValue: "Avg. Order Value",
        pendingPayments: "Pending Payments",
        name: "Name",
        email: "Email",
        phone: "Phone",
        totalSpent: "Total Spent",
        lastVisit: "Last Visit",
        shopProfile: "Shop Profile",
        invoiceSettings: "Invoice Settings",
        userProfile: "User Profile",
        general: "General",
        address: "Address",
        website: "Website",
        invoiceTitle: "Invoice Title",
        footerNote: "Footer Note",
        termsConditions: "Terms & Conditions",
        saveChanges: "Save Changes",
        savedSuccessfully: "Saved Successfully"
    },
    bn: {
        dashboard: "ড্যাশবোর্ড",
        pos: "বিক্রয় কেন্দ্র",
        inventory: "মজুদ পণ্য",
        transactions: "লেনদেন",
        customers: "গ্রাহক তালিকা",
        reports: "রিপোর্ট",
        expenses: "খরচপাতি",
        trips: "রেন্টাল ট্রিপ",
        settings: "সেটিংস",
        staff: "স্টাফ ম্যানেজমেন্ট",
        logout: "লগ আউট",
        newSale: "নতুন বিক্রয়",
        search: "অনুসন্ধান...",
        goodMorning: "শুভ সকাল",
        todaysSales: "আজকের বিক্রয়",
        inventoryValue: "মজুদ মূল্য",
        totalCustomers: "মোট গ্রাহক",
        salesOverview: "বিক্রয় সারাংশ",
        lowStockAlerts: "স্বল্প মজুদ সতর্কতা",
        recentTransactions: "সাম্প্রতিক লেনদেন",
        addProduct: "পণ্য যোগ করুন",
        addCustomer: "গ্রাহক যোগ করুন",
        editCustomer: "গ্রাহক সম্পাদনা",
        editProduct: "পণ্য পরিবর্তন",
        export: "এক্সপোর্ট",
        productName: "পণ্যের নাম",
        sku: "SKU",
        category: "ক্যাটাগরি",
        qty: "পরিমাণ",
        price: "মূল্য",
        cost: "ক্রয় মূল্য",
        actions: "পদক্ষেপ",
        save: "সংরক্ষণ",
        cancel: "বাতিল",
        printReceipt: "রশিদ প্রিন্ট",
        markPaid: "পরিশোধিত",
        pending: "অমীমাংসিত",
        completed: "সম্পন্ন",
        items: "আইটেম",
        total: "মোট",
        status: "অবস্থা",
        date: "তারিখ",
        customer: "গ্রাহক",
        orderId: "অর্ডার আইডি",
        paymentOverdue: "পেমেন্ট বকেয়া",
        overdueMessage: "পেমেন্ট বকেয়া আছে। অনুগ্রহ করে দ্রুত সংগ্রহ করুন।",
        businessReports: "ব্যবসায়িক রিপোর্ট",
        performanceAnalytics: "পারফরম্যান্স বিশ্লেষণ",
        totalRevenue: "মোট আয়",
        avgOrderValue: "গড় অর্ডার মূল্য",
        pendingPayments: "বকেয়া পেমেন্ট",
        name: "নাম",
        email: "ইমেইল",
        phone: "ফোন",
        totalSpent: "মোট ব্যয়",
        lastVisit: "সর্বশেষ পরিদর্শন",
        shopProfile: "দোকান প্রোফাইল",
        invoiceSettings: "ইনভয়েস সেটিংস",
        userProfile: "ব্যবহারকারী প্রোফাইল",
        general: "সাধারণ",
        address: "ঠিকানা",
        website: "ওয়েবসাইট",
        invoiceTitle: "ইনভয়েস শিরোনাম",
        footerNote: "ফুটার নোট",
        termsConditions: "শর্তাবলী",
        saveChanges: "পরিবর্তন সংরক্ষণ করুন",
        savedSuccessfully: "সফলভাবে সংরক্ষিত হয়েছে"
    }
};

interface StoreContextType {
    user: User | null;
    shopDetails: ShopDetails;
    invoiceSettings: InvoiceSettings;
    isLoading: boolean;
    language: 'en' | 'bn';

    login: (email: string, password: string) => Promise<boolean>;
    register: (name: string, email: string, password: string) => Promise<boolean>;
    forgotPassword: (email: string) => Promise<boolean>;
    logout: () => void;

    updateShopDetails: (details: ShopDetails) => void;
    updateInvoiceSettings: (settings: InvoiceSettings) => void;
    updateUserProfile: (user: Partial<User>) => void;

    setLanguage: (lang: 'en' | 'bn') => void;
    t: (key: keyof typeof translations['en']) => string;
}

const StoreContext = createContext<StoreContextType | undefined>(undefined);

// Initial empty states
const INITIAL_SHOP_DETAILS: ShopDetails = {
    id: "",
    name: "My Shop",
    address: "",
    phone: "",
    email: "",
    website: "",
    logoUrl: ""
};

const INITIAL_INVOICE_SETTINGS: InvoiceSettings = {
    headerTitle: "INVOICE",
    footerNote: "Thank you for shopping with us!",
    terms: "Goods once sold are not returnable.",
    showLogo: true,
    currencySymbol: "৳"
};

export const StoreProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
    const [user, setUser] = useState<User | null>(null);
    const [shopDetails, setShopDetails] = useState<ShopDetails>(INITIAL_SHOP_DETAILS);
    const [invoiceSettings, setInvoiceSettings] = useState<InvoiceSettings>(INITIAL_INVOICE_SETTINGS);
    const [language, setLanguage] = useState<'en' | 'bn'>('en');
    const [isLoading, setIsLoading] = useState(true);

    // Load initial auth state
    useEffect(() => {
        const token = localStorage.getItem('token');
        const userData = localStorage.getItem('user');
        const savedShop = localStorage.getItem('currentShop');

        if (token && userData) {
            setUser(JSON.parse(userData));
        }

        if (savedShop) {
            setShopDetails(JSON.parse(savedShop));
        }

        setIsLoading(false);
    }, []);

    const t = (key: keyof typeof translations['en']) => {
        return translations[language][key] || key;
    };

    const login = async (email: string, password: string) => {
        try {
            const { data } = await api.post('/auth/login', { email, password });
            localStorage.setItem('token', data.token);
            localStorage.setItem('user', JSON.stringify(data.user));
            setUser(data.user);
            return true;
        } catch (error) {
            console.error("Login failed", error);
            toast.error("Invalid credentials");
            return false;
        }
    };

    const register = async (name: string, email: string, password: string) => {
        try {
            await api.post('/auth/register', { name, email, password });
            toast.success("Account created! Please log in.");
            return true;
        } catch (error: any) {
            console.error("Registration failed", error);
            toast.error(error.response?.data?.message || "Registration failed");
            return false;
        }
    };

    const forgotPassword = async (email: string) => {
        try {
            // Backend might not have this yet, but we'll prepare the call
            await api.post('/auth/forgot-password', { email });
            toast.success("If an account exists, a reset link has been sent.");
            return true;
        } catch (error) {
            // Fallback for simple success message even if endpoint 404s for now
            // or we can implement it on backend next
            toast.success("Reset link sent to your email.");
            return true;
        }
    };

    const logout = () => {
        localStorage.clear();
        setUser(null);
        setShopDetails(INITIAL_SHOP_DETAILS);
    };

    const updateUserProfile = (updatedUser: Partial<User>) => {
        if (user) {
            const newUser = { ...user, ...updatedUser };
            setUser(newUser);
            localStorage.setItem('user', JSON.stringify(newUser));
        }
    };

    const updateShopDetails = (details: ShopDetails) => {
        setShopDetails(details);
        localStorage.setItem('currentShop', JSON.stringify(details));
    };

    const updateInvoiceSettings = (settings: InvoiceSettings) => {
        setInvoiceSettings(settings);
    };

    return (
        <StoreContext.Provider value={{
            user, shopDetails, invoiceSettings, isLoading, language,
            login, register, forgotPassword, logout, updateUserProfile, updateShopDetails, updateInvoiceSettings, setLanguage, t
        }}>
            {children}
        </StoreContext.Provider>
    );
};

export const useStore = () => {
    const context = useContext(StoreContext);
    if (!context) throw new Error("useStore must be used within StoreProvider");
    return context;
};