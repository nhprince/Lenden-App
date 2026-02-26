import React, { useState, useEffect, useCallback } from 'react';
import { Layout } from '../components/LayoutEnhanced';
import { useStore } from '../context/Store';
import { Product, CartItem, Customer } from '../types';
import api from '../utils/api';
import toast from 'react-hot-toast';
import { motion, AnimatePresence } from 'framer-motion';

export const POSScreenEnhanced: React.FC = () => {
    const { t, shopDetails } = useStore();
    const [products, setProducts] = useState<Product[]>([]);
    const [customers, setCustomers] = useState<Customer[]>([]);
    const [cart, setCart] = useState<CartItem[]>([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedCategory, setSelectedCategory] = useState('All');
    const [customerSearch, setCustomerSearch] = useState('Walk-in Customer');
    const [selectedCustomerId, setSelectedCustomerId] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);
    const [categories, setCategories] = useState<string[]>(['All']);
    const [paymentMethod, setPaymentMethod] = useState<'cash' | 'card' | 'mobile'>('cash');
    const [isCheckoutOpen, setIsCheckoutOpen] = useState(false);
    const [discount, setDiscount] = useState(0);

    // Fetch Initial Data
    const fetchInitialData = async () => {
        if (!shopDetails.id) return;
        try {
            const [custRes, prodRes] = await Promise.all([
                api.get('/customers'),
                api.get('/products?limit=50')
            ]);
            setCustomers(custRes.data);
            const fetchedProducts = prodRes.data.products.map((p: any) => ({
                id: p.id,
                name: p.name,
                subText: p.sub_text,
                sku: p.sku,
                category: p.category,
                qty: p.stock_quantity,
                costPrice: p.cost_price,
                sellingPrice: p.selling_price,
                imageUrl: p.image_url || 'https://api.dicebear.com/7.x/shapes/svg?seed=' + p.name
            }));
            setProducts(fetchedProducts);

            const cats = ['All', ...new Set(fetchedProducts.map((p: any) => p.category))];
            setCategories(cats as string[]);
        } catch (error) {
            console.error("Failed to fetch POS data", error);
            toast.error("Failed to load POS data");
        }
    };

    useEffect(() => {
        fetchInitialData();
    }, [shopDetails.id]);

    // Search Products
    const fetchProducts = useCallback(async (search: string, category: string) => {
        if (!shopDetails.id) return;
        try {
            setLoading(true);
            const params: any = { limit: 50 };
            if (search) params.search = search;
            
            const { data } = await api.get('/products', { params });
            const fetched = data.products.map((p: any) => ({
                id: p.id,
                name: p.name,
                subText: p.sub_text,
                sku: p.sku,
                category: p.category,
                qty: p.stock_quantity,
                costPrice: p.cost_price,
                sellingPrice: p.selling_price,
                imageUrl: p.image_url || 'https://api.dicebear.com/7.x/shapes/svg?seed=' + p.name
            }));

            if (category !== 'All') {
                setProducts(fetched.filter((p: any) => p.category === category));
            } else {
                setProducts(fetched);
            }
        } catch (error) {
            console.error("Search failed", error);
        } finally {
            setLoading(false);
        }
    }, [shopDetails.id]);

    useEffect(() => {
        const handler = setTimeout(() => {
            fetchProducts(searchTerm, selectedCategory);
        }, 300);
        return () => clearTimeout(handler);
    }, [searchTerm, selectedCategory, fetchProducts]);

    const addToCart = (product: Product) => {
        if (product.qty <= 0) {
            toast.error("Out of stock");
            return;
        }
        setCart(prev => {
            const existing = prev.find(item => item.id === product.id);
            if (existing) {
                if (existing.cartQty >= product.qty) {
                    toast.error("Cannot add more than available stock");
                    return prev;
                }
                toast.success(`Added another ${product.name}`);
                return prev.map(item =>
                    item.id === product.id
                        ? { ...item, cartQty: item.cartQty + 1 }
                        : item
                );
            }
            toast.success(`${product.name} added to cart`);
            return [...prev, { ...product, cartQty: 1 }];
        });
    };

    const updateCartQuantity = (id: string, newQty: number) => {
        const product = products.find(p => p.id === id);
        if (newQty <= 0) {
            removeFromCart(id);
            return;
        }
        if (product && newQty > product.qty) {
            toast.error("Quantity exceeds available stock");
            return;
        }
        setCart(prev => prev.map(item =>
            item.id === id ? { ...item, cartQty: newQty } : item
        ));
    };

    const removeFromCart = (id: string) => {
        setCart(prev => prev.filter(item => item.id !== id));
        toast.success("Item removed from cart");
    };

    const clearCart = () => {
        setCart([]);
        setDiscount(0);
        setCustomerSearch('Walk-in Customer');
        setSelectedCustomerId(null);
        toast.success("Cart cleared");
    };

    const calculateTotal = () => {
        const subtotal = cart.reduce((sum, item) => sum + (item.sellingPrice * item.cartQty), 0);
        const discountAmount = (subtotal * discount) / 100;
        return {
            subtotal,
            discount: discountAmount,
            total: subtotal - discountAmount
        };
    };

    const handleCheckout = async () => {
        if (cart.length === 0) {
            toast.error("Cart is empty");
            return;
        }

        try {
            const totals = calculateTotal();
            const saleData = {
                customer_id: selectedCustomerId || null,
                customer_name: customerSearch,
                items: cart.map(item => ({
                    product_id: item.id,
                    quantity: item.cartQty,
                    price: item.sellingPrice
                })),
                subtotal: totals.subtotal,
                discount: totals.discount,
                total: totals.total,
                payment_method: paymentMethod,
                status: 'Completed'
            };

            await api.post('/transactions', saleData);
            toast.success("Sale completed successfully!");
            clearCart();
            setIsCheckoutOpen(false);
        } catch (error) {
            console.error("Checkout failed", error);
            toast.error("Failed to complete sale");
        }
    };

    const totals = calculateTotal();

    return (
        <Layout title={t('pos')}>
            <div className="max-w-7xl mx-auto h-[calc(100vh-180px)]">
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 h-full">
                    {/* Products Section */}
                    <div className="lg:col-span-2 flex flex-col gap-4 h-full">
                        {/* Search and Filters */}
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="bg-white dark:bg-gray-900 rounded-2xl p-4 border border-gray-200 dark:border-gray-800 shadow-soft"
                        >
                            <div className="flex flex-col sm:flex-row gap-3">
                                <div className="flex-1 relative group">
                                    <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                        <span className="material-symbols-outlined text-gray-400 text-[20px] group-focus-within:text-primary-600 transition-colors">
                                            search
                                        </span>
                                    </div>
                                    <input
                                        type="text"
                                        value={searchTerm}
                                        onChange={e => setSearchTerm(e.target.value)}
                                        placeholder="Search products..."
                                        className="w-full pl-12 pr-4 py-3 rounded-xl border-2 border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:border-primary-500 focus:ring-4 focus:ring-primary-500/10 transition-all outline-none text-sm"
                                    />
                                </div>
                                <div className="flex gap-2 overflow-x-auto scrollbar-thin">
                                    {categories.map(cat => (
                                        <motion.button
                                            key={cat}
                                            whileHover={{ scale: 1.05 }}
                                            whileTap={{ scale: 0.95 }}
                                            onClick={() => setSelectedCategory(cat)}
                                            className={`px-4 py-2 rounded-xl font-semibold text-sm whitespace-nowrap transition-all ${
                                                selectedCategory === cat
                                                    ? 'bg-gradient-to-r from-primary-600 to-primary-500 text-white shadow-lg shadow-primary-600/30'
                                                    : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700'
                                            }`}
                                        >
                                            {cat}
                                        </motion.button>
                                    ))}
                                </div>
                            </div>
                        </motion.div>

                        {/* Products Grid */}
                        <div className="flex-1 overflow-y-auto scrollbar-thin">
                            {loading ? (
                                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                                    {[...Array(8)].map((_, i) => (
                                        <div key={i} className="bg-gray-100 dark:bg-gray-800 rounded-2xl p-4 animate-pulse">
                                            <div className="w-full h-32 bg-gray-200 dark:bg-gray-700 rounded-xl mb-3"></div>
                                            <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded mb-2"></div>
                                            <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-2/3"></div>
                                        </div>
                                    ))}
                                </div>
                            ) : products.length > 0 ? (
                                <motion.div 
                                    initial="hidden"
                                    animate="visible"
                                    variants={{
                                        visible: { transition: { staggerChildren: 0.05 } }
                                    }}
                                    className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4"
                                >
                                    {products.map((product, index) => (
                                        <motion.div
                                            key={product.id}
                                            variants={{
                                                hidden: { opacity: 0, y: 20 },
                                                visible: { opacity: 1, y: 0 }
                                            }}
                                            whileHover={{ y: -4 }}
                                            onClick={() => addToCart(product)}
                                            className="bg-white dark:bg-gray-900 rounded-2xl p-4 border border-gray-200 dark:border-gray-800 shadow-soft hover:shadow-hard cursor-pointer transition-all group"
                                        >
                                            <div className="relative mb-3">
                                                <img
                                                    src={product.imageUrl}
                                                    alt={product.name}
                                                    className="w-full h-32 object-cover rounded-xl bg-gray-100 dark:bg-gray-800"
                                                />
                                                {product.qty <= 0 && (
                                                    <div className="absolute inset-0 bg-black/60 rounded-xl flex items-center justify-center">
                                                        <span className="text-white text-xs font-bold">Out of Stock</span>
                                                    </div>
                                                )}
                                                {product.qty > 0 && product.qty <= 10 && (
                                                    <div className="absolute top-2 right-2 bg-danger-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-full">
                                                        Low
                                                    </div>
                                                )}
                                            </div>
                                            <h4 className="font-bold text-sm text-gray-900 dark:text-white mb-1 line-clamp-1 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors">
                                                {product.name}
                                            </h4>
                                            <p className="text-xs text-gray-500 dark:text-gray-400 mb-2 line-clamp-1">
                                                {product.subText || product.sku}
                                            </p>
                                            <div className="flex items-center justify-between">
                                                <span className="text-lg font-bold text-gray-900 dark:text-white">
                                                    ৳{product.sellingPrice}
                                                </span>
                                                <span className="text-xs text-gray-500 dark:text-gray-400">
                                                    Stock: {product.qty}
                                                </span>
                                            </div>
                                        </motion.div>
                                    ))}
                                </motion.div>
                            ) : (
                                <div className="flex items-center justify-center h-full">
                                    <div className="text-center">
                                        <span className="material-symbols-outlined text-6xl text-gray-300 dark:text-gray-700 mb-3">inventory_2</span>
                                        <p className="text-gray-500 dark:text-gray-400">No products found</p>
                                    </div>
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Cart Section */}
                    <div className="flex flex-col gap-4 h-full">
                        <motion.div
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            className="bg-white dark:bg-gray-900 rounded-2xl p-6 border border-gray-200 dark:border-gray-800 shadow-soft flex flex-col h-full"
                        >
                            <div className="flex items-center justify-between mb-4">
                                <h3 className="text-xl font-bold text-gray-900 dark:text-white">Cart</h3>
                                {cart.length > 0 && (
                                    <motion.button
                                        whileHover={{ scale: 1.05 }}
                                        whileTap={{ scale: 0.95 }}
                                        onClick={clearCart}
                                        className="text-sm font-semibold text-danger-600 dark:text-danger-400 hover:text-danger-700 dark:hover:text-danger-300 transition-colors"
                                    >
                                        Clear All
                                    </motion.button>
                                )}
                            </div>

                            {/* Customer Selection */}
                            <div className="mb-4">
                                <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                                    Customer
                                </label>
                                <div className="relative group">
                                    <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                        <span className="material-symbols-outlined text-gray-400 text-[18px]">person</span>
                                    </div>
                                    <input
                                        type="text"
                                        value={customerSearch}
                                        onChange={e => setCustomerSearch(e.target.value)}
                                        placeholder="Walk-in Customer"
                                        className="w-full pl-11 pr-4 py-2.5 rounded-xl border-2 border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:border-primary-500 focus:ring-4 focus:ring-primary-500/10 transition-all outline-none text-sm"
                                    />
                                </div>
                            </div>

                            {/* Cart Items */}
                            <div className="flex-1 overflow-y-auto scrollbar-thin mb-4">
                                <AnimatePresence>
                                    {cart.length > 0 ? (
                                        cart.map(item => (
                                            <motion.div
                                                key={item.id}
                                                initial={{ opacity: 0, x: -10 }}
                                                animate={{ opacity: 1, x: 0 }}
                                                exit={{ opacity: 0, x: 10 }}
                                                className="flex items-center gap-3 p-3 rounded-xl bg-gray-50 dark:bg-gray-800 mb-2 group hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                                            >
                                                <img
                                                    src={item.imageUrl}
                                                    alt={item.name}
                                                    className="w-12 h-12 rounded-lg object-cover bg-gray-200 dark:bg-gray-700"
                                                />
                                                <div className="flex-1 min-w-0">
                                                    <p className="font-semibold text-sm text-gray-900 dark:text-white truncate">
                                                        {item.name}
                                                    </p>
                                                    <p className="text-xs text-gray-500 dark:text-gray-400">
                                                        ৳{item.sellingPrice} × {item.cartQty}
                                                    </p>
                                                </div>
                                                <div className="flex items-center gap-2">
                                                    <button
                                                        onClick={() => updateCartQuantity(item.id, item.cartQty - 1)}
                                                        className="w-7 h-7 flex items-center justify-center rounded-lg bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
                                                    >
                                                        <span className="material-symbols-outlined text-[16px]">remove</span>
                                                    </button>
                                                    <span className="text-sm font-bold text-gray-900 dark:text-white min-w-[20px] text-center">
                                                        {item.cartQty}
                                                    </span>
                                                    <button
                                                        onClick={() => updateCartQuantity(item.id, item.cartQty + 1)}
                                                        className="w-7 h-7 flex items-center justify-center rounded-lg bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
                                                    >
                                                        <span className="material-symbols-outlined text-[16px]">add</span>
                                                    </button>
                                                    <button
                                                        onClick={() => removeFromCart(item.id)}
                                                        className="w-7 h-7 flex items-center justify-center rounded-lg bg-danger-100 dark:bg-danger-950/30 text-danger-600 dark:text-danger-400 hover:bg-danger-200 dark:hover:bg-danger-900/40 transition-colors ml-2"
                                                    >
                                                        <span className="material-symbols-outlined text-[16px]">delete</span>
                                                    </button>
                                                </div>
                                            </motion.div>
                                        ))
                                    ) : (
                                        <motion.div
                                            initial={{ opacity: 0 }}
                                            animate={{ opacity: 1 }}
                                            className="flex flex-col items-center justify-center h-full text-center py-12"
                                        >
                                            <span className="material-symbols-outlined text-6xl text-gray-300 dark:text-gray-700 mb-3">shopping_cart</span>
                                            <p className="text-gray-500 dark:text-gray-400 text-sm">Cart is empty</p>
                                            <p className="text-gray-400 dark:text-gray-500 text-xs mt-1">Add products to get started</p>
                                        </motion.div>
                                    )}
                                </AnimatePresence>
                            </div>

                            {/* Discount */}
                            {cart.length > 0 && (
                                <div className="mb-4">
                                    <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                                        Discount (%)
                                    </label>
                                    <input
                                        type="number"
                                        min="0"
                                        max="100"
                                        value={discount}
                                        onChange={e => setDiscount(Math.min(100, Math.max(0, Number(e.target.value))))}
                                        className="w-full px-4 py-2.5 rounded-xl border-2 border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 focus:border-primary-500 focus:ring-4 focus:ring-primary-500/10 transition-all outline-none text-sm"
                                    />
                                </div>
                            )}

                            {/* Totals */}
                            {cart.length > 0 && (
                                <div className="space-y-2 mb-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-xl">
                                    <div className="flex justify-between text-sm">
                                        <span className="text-gray-600 dark:text-gray-400">Subtotal</span>
                                        <span className="font-semibold text-gray-900 dark:text-white">৳{totals.subtotal.toLocaleString()}</span>
                                    </div>
                                    {discount > 0 && (
                                        <div className="flex justify-between text-sm">
                                            <span className="text-gray-600 dark:text-gray-400">Discount ({discount}%)</span>
                                            <span className="font-semibold text-danger-600 dark:text-danger-400">-৳{totals.discount.toLocaleString()}</span>
                                        </div>
                                    )}
                                    <div className="flex justify-between text-lg pt-2 border-t border-gray-200 dark:border-gray-700">
                                        <span className="font-bold text-gray-900 dark:text-white">Total</span>
                                        <span className="font-bold text-primary-600 dark:text-primary-400">৳{totals.total.toLocaleString()}</span>
                                    </div>
                                </div>
                            )}

                            {/* Checkout Button */}
                            <motion.button
                                whileHover={{ scale: cart.length > 0 ? 1.02 : 1 }}
                                whileTap={{ scale: cart.length > 0 ? 0.98 : 1 }}
                                onClick={() => cart.length > 0 && setIsCheckoutOpen(true)}
                                disabled={cart.length === 0}
                                className={`w-full py-4 rounded-xl font-bold text-sm flex items-center justify-center gap-2 transition-all ${
                                    cart.length > 0
                                        ? 'bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-700 hover:to-primary-600 text-white shadow-lg shadow-primary-600/30 hover:shadow-xl'
                                        : 'bg-gray-200 dark:bg-gray-800 text-gray-400 dark:text-gray-600 cursor-not-allowed'
                                }`}
                            >
                                <span className="material-symbols-outlined text-[20px]">shopping_cart_checkout</span>
                                <span>Checkout (৳{totals.total.toLocaleString()})</span>
                            </motion.button>
                        </motion.div>
                    </div>
                </div>
            </div>

            {/* Checkout Modal */}
            <AnimatePresence>
                {isCheckoutOpen && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4"
                        onClick={() => setIsCheckoutOpen(false)}
                    >
                        <motion.div
                            initial={{ scale: 0.9, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            exit={{ scale: 0.9, opacity: 0 }}
                            onClick={(e) => e.stopPropagation()}
                            className="bg-white dark:bg-gray-900 rounded-3xl p-8 max-w-md w-full border border-gray-200 dark:border-gray-800 shadow-2xl"
                        >
                            <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">Complete Sale</h3>
                            
                            <div className="space-y-4 mb-6">
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                                        Payment Method
                                    </label>
                                    <div className="grid grid-cols-3 gap-2">
                                        {(['cash', 'card', 'mobile'] as const).map(method => (
                                            <button
                                                key={method}
                                                onClick={() => setPaymentMethod(method)}
                                                className={`px-4 py-3 rounded-xl font-semibold text-sm capitalize transition-all ${
                                                    paymentMethod === method
                                                        ? 'bg-primary-600 text-white shadow-lg shadow-primary-600/30'
                                                        : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700'
                                                }`}
                                            >
                                                {method}
                                            </button>
                                        ))}
                                    </div>
                                </div>

                                <div className="p-4 bg-gray-50 dark:bg-gray-800 rounded-xl space-y-2">
                                    <div className="flex justify-between">
                                        <span className="text-gray-600 dark:text-gray-400">Items</span>
                                        <span className="font-semibold text-gray-900 dark:text-white">{cart.length}</span>
                                    </div>
                                    <div className="flex justify-between">
                                        <span className="text-gray-600 dark:text-gray-400">Subtotal</span>
                                        <span className="font-semibold text-gray-900 dark:text-white">৳{totals.subtotal.toLocaleString()}</span>
                                    </div>
                                    {discount > 0 && (
                                        <div className="flex justify-between">
                                            <span className="text-gray-600 dark:text-gray-400">Discount</span>
                                            <span className="font-semibold text-danger-600 dark:text-danger-400">-৳{totals.discount.toLocaleString()}</span>
                                        </div>
                                    )}
                                    <div className="flex justify-between text-lg font-bold pt-2 border-t border-gray-200 dark:border-gray-700">
                                        <span className="text-gray-900 dark:text-white">Total</span>
                                        <span className="text-primary-600 dark:text-primary-400">৳{totals.total.toLocaleString()}</span>
                                    </div>
                                </div>
                            </div>

                            <div className="flex gap-3">
                                <motion.button
                                    whileHover={{ scale: 1.02 }}
                                    whileTap={{ scale: 0.98 }}
                                    onClick={() => setIsCheckoutOpen(false)}
                                    className="flex-1 py-3 rounded-xl font-bold text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transition-all"
                                >
                                    Cancel
                                </motion.button>
                                <motion.button
                                    whileHover={{ scale: 1.02 }}
                                    whileTap={{ scale: 0.98 }}
                                    onClick={handleCheckout}
                                    className="flex-1 py-3 rounded-xl font-bold text-white bg-gradient-to-r from-secondary-600 to-secondary-500 hover:from-secondary-700 hover:to-secondary-600 shadow-lg shadow-secondary-600/30 transition-all"
                                >
                                    Confirm Sale
                                </motion.button>
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </Layout>
    );
};
