import React, { useState, useRef, useEffect } from 'react';
import { Layout } from '../components/Layout';
import { useStore } from '../context/Store';
import { Product } from '../types';
import api from '../utils/api';
import toast from 'react-hot-toast';
import { motion, AnimatePresence } from 'framer-motion';

export const ProductsScreen: React.FC = () => {
    const { t, shopDetails } = useStore();
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [filter, setFilter] = useState<'all' | 'low_stock'>('all');

    // Pagination state
    const [limit] = useState(10);
    const [offset, setOffset] = useState(0);
    const [total, setTotal] = useState(0);

    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingId, setEditingId] = useState<string | null>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);

    const initialProductState: Partial<Product> = {
        name: '', subText: '', sku: '', category: 'General', qty: 0, costPrice: 0, sellingPrice: 0, imageUrl: 'https://picsum.photos/id/1/100/100', minStockLevel: 5
    };

    const [currentProduct, setCurrentProduct] = useState<Partial<Product>>(initialProductState);

    const fetchProducts = async () => {
        if (!shopDetails.id) return;
        try {
            setLoading(true);
            const params: any = { limit, offset };
            if (searchTerm) params.search = searchTerm;
            if (filter === 'low_stock') params.low_stock = true;

            const { data } = await api.get('/products', { params });
            setProducts(data.products);
            setTotal(data.pagination.total);
        } catch (error) {
            console.error("Failed to fetch products", error);
            toast.error("Failed to load products");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchProducts();
    }, [shopDetails.id, offset, filter]);

    useEffect(() => {
        const handler = setTimeout(() => {
            setOffset(0);
            fetchProducts();
        }, 500);
        return () => clearTimeout(handler);
    }, [searchTerm]);

    const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files[0]) {
            const file = e.target.files[0];
            const reader = new FileReader();
            reader.onloadend = () => {
                setCurrentProduct({ ...currentProduct, imageUrl: reader.result as string });
            };
            reader.readAsDataURL(file);
        }
    };

    const handleEditClick = (product: any) => {
        setEditingId(product.id);
        setCurrentProduct(product);
        setIsModalOpen(true);
    };

    const handleAddNewClick = () => {
        setEditingId(null);
        setCurrentProduct(initialProductState);
        setIsModalOpen(true);
    };

    const handleDeleteClick = async (id: string) => {
        if (window.confirm("Are you sure you want to delete this product?")) {
            try {
                await api.delete(`/products/${id}`);
                toast.success("Product deleted successfully");
                fetchProducts();
            } catch (error) {
                console.error("Failed to delete product", error);
                toast.error("Failed to delete product");
            }
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            const productData = {
                ...currentProduct,
                stock_quantity: currentProduct.qty,
                selling_price: currentProduct.sellingPrice,
                cost_price: currentProduct.costPrice,
                min_stock_level: currentProduct.minStockLevel || 5,
                engine_no: currentProduct.engineNo,
                chassis_no: currentProduct.chassisNo,
                model_year: currentProduct.modelYear,
                material_cost: currentProduct.materialCost
            };

            if (editingId) {
                await api.put(`/products/${editingId}`, productData);
                toast.success("Product updated successfully");
            } else {
                await api.post('/products', productData);
                toast.success("Product added successfully");
            }

            setIsModalOpen(false);
            setCurrentProduct(initialProductState);
            fetchProducts();
        } catch (error) {
            console.error("Failed to save product", error);
            toast.error("Failed to save product");
        }
    };

    return (
        <Layout title={t('inventory')}>
            <div className="w-full max-w-7xl flex flex-col gap-8 mx-auto relative h-full">

                {/* Header Section */}
                <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
                    <div>
                        <h2 className="text-3xl font-black tracking-tight text-slate-900 dark:text-white mb-2">{t('inventory')}</h2>
                        <p className="text-slate-500 dark:text-slate-400 text-base max-w-2xl">Manage your shop's stock levels, track pricing, and organize inventory efficiently.</p>
                    </div>
                    <div className="flex gap-3">
                        <button onClick={handleAddNewClick} className="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-2xl bg-primary text-white font-black text-sm shadow-xl shadow-primary/20 hover:bg-primary/90 transition-all active:scale-95">
                            <span className="material-symbols-outlined text-[20px]">add</span>
                            <span>{t('addProduct')}</span>
                        </button>
                    </div>
                </div>

                {/* Table Container */}
                <div className="bg-white dark:bg-surface-dark rounded-3xl border border-[#f0f2f5] dark:border-[#2d3748] shadow-sm overflow-hidden flex flex-col flex-1 min-h-0">
                    <div className="p-6 border-b border-[#f0f2f5] dark:border-[#2d3748] flex flex-col lg:flex-row lg:items-center justify-between gap-6">
                        <div className="relative flex-1 max-w-lg">
                            <span className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 material-symbols-outlined">search</span>
                            <input
                                value={searchTerm}
                                onChange={e => setSearchTerm(e.target.value)}
                                className="w-full h-12 pl-12 pr-4 rounded-2xl bg-[#f8fafc] dark:bg-slate-900 border border-[#e5e7eb] dark:border-[#2d3748] text-sm font-bold focus:outline-none focus:ring-4 focus:ring-primary/5 focus:border-primary transition-all placeholder:text-slate-400 dark:text-white"
                                placeholder={`${t('search')} products...`}
                                type="text"
                            />
                        </div>
                        <div className="flex flex-wrap items-center gap-2 bg-[#f8fafc] dark:bg-slate-900 p-1.5 rounded-2xl border border-[#e5e7eb] dark:border-[#2d3748]">
                            <button className={`whitespace-nowrap px-6 py-2 rounded-xl text-xs font-black uppercase tracking-widest transition-all ${filter === 'all' ? 'bg-white dark:bg-slate-800 text-primary shadow-sm' : 'text-slate-500 hover:text-primary'}`} onClick={() => setFilter('all')}>All Items</button>
                            <button className={`whitespace-nowrap px-6 py-2 rounded-xl text-xs font-black uppercase tracking-widest transition-all ${filter === 'low_stock' ? 'bg-white dark:bg-slate-800 text-red-500 shadow-sm' : 'text-slate-500 hover:text-red-500'}`} onClick={() => setFilter('low_stock')}>Low Stock</button>
                        </div>
                    </div>

                    <div className="flex-1 overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-[#f8fafc]/50 dark:bg-slate-900/50 border-b border-[#f0f2f5] dark:border-[#2d3748]">
                                    <th className="py-5 px-6 text-[10px] font-black uppercase tracking-[0.2em] text-slate-500">{t('productName')}</th>
                                    <th className="py-5 px-6 text-[10px] font-black uppercase tracking-[0.2em] text-slate-500">{t('sku')}</th>
                                    <th className="py-5 px-6 text-[10px] font-black uppercase tracking-[0.2em] text-slate-500">{t('category')}</th>
                                    <th className="py-5 px-6 text-[10px] font-black uppercase tracking-[0.2em] text-slate-500">{t('qty')}</th>
                                    <th className="py-5 px-6 text-[10px] font-black uppercase tracking-[0.2em] text-slate-500 hidden md:table-cell">{t('cost')}</th>
                                    <th className="py-5 px-6 text-[10px] font-black uppercase tracking-[0.2em] text-slate-500 text-right">{t('price')}</th>
                                    <th className="py-5 px-6 text-[10px] font-black uppercase tracking-[0.2em] text-slate-500 text-right">{t('actions')}</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-[#f0f2f5] dark:divide-[#2d3748]">
                                {loading ? (
                                    <tr>
                                        <td colSpan={6} className="py-20 text-center">
                                            <div className="w-10 h-10 border-4 border-primary/20 border-t-primary rounded-full animate-spin mx-auto"></div>
                                        </td>
                                    </tr>
                                ) : products.length === 0 ? (
                                    <tr>
                                        <td colSpan={6} className="py-20 text-center text-slate-400 font-bold">No products found.</td>
                                    </tr>
                                ) : products.map((prod: any) => (
                                    <tr key={prod.id} className="group hover:bg-[#f8fafc] dark:hover:bg-slate-800/30 transition-all">
                                        <td className="py-5 px-6">
                                            <div className="flex items-center gap-4">
                                                <div className="w-12 h-12 rounded-2xl bg-slate-100 dark:bg-slate-800 flex-shrink-0 bg-cover bg-center border border-[#e5e7eb] dark:border-[#2d3748]" style={{ backgroundImage: `url('${prod.image_url || 'https://picsum.photos/id/1/100/100'}')` }}></div>
                                                <div className="flex flex-col">
                                                    <span className="font-bold text-sm text-slate-900 dark:text-white group-hover:text-primary transition-colors">{prod.name}</span>
                                                    <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">{prod.sub_text}</span>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="py-5 px-6"><span className="font-mono text-[11px] font-black text-slate-500 bg-slate-100 dark:bg-slate-800 px-2.5 py-1 rounded-lg border border-[#e5e7eb] dark:border-[#2d3748]">{prod.sku}</span></td>
                                        <td className="py-5 px-6"><span className="text-xs font-bold text-slate-600 dark:text-slate-400">{prod.category}</span></td>
                                        <td className="py-5 px-6">
                                            <div className="flex items-center gap-2">
                                                <span className={`text-sm font-black ${prod.stock_quantity <= (prod.min_stock_level || 5) ? 'text-red-500' : 'text-slate-900 dark:text-white'}`}>{prod.stock_quantity}</span>
                                                {prod.stock_quantity <= (prod.min_stock_level || 5) && (
                                                    <span className="px-2 py-0.5 rounded-full bg-red-50 dark:bg-red-500/10 text-[9px] font-black text-red-600 uppercase tracking-tighter border border-red-100 dark:border-red-500/20">Low Stock</span>
                                                )}
                                            </div>
                                        </td>
                                        <td className="py-5 px-6 hidden md:table-cell"><span className="text-sm font-bold text-slate-500">৳{prod.cost_price?.toLocaleString()}</span></td>
                                        <td className="py-5 px-6 text-right font-black text-slate-900 dark:text-white text-sm">৳{prod.selling_price?.toLocaleString()}</td>
                                        <td className="py-5 px-6 text-right">
                                            <div className="flex justify-end gap-1.5 opacity-0 group-hover:opacity-100 transition-opacity">
                                                <button onClick={() => handleEditClick({
                                                    ...prod,
                                                    qty: prod.stock_quantity,
                                                    sellingPrice: prod.selling_price,
                                                    costPrice: prod.cost_price,
                                                    imageUrl: prod.image_url,
                                                    minStockLevel: prod.min_stock_level,
                                                    subText: prod.sub_text,
                                                    engineNo: prod.engine_no,
                                                    chassisNo: prod.chassis_no,
                                                    modelYear: prod.model_year,
                                                    materialCost: prod.material_cost
                                                })} className="p-2 rounded-xl text-slate-400 hover:text-primary hover:bg-primary/5 transition-all">
                                                    <span className="material-symbols-outlined text-[18px]">edit</span>
                                                </button>
                                                <button onClick={() => handleDeleteClick(prod.id)} className="p-2 rounded-xl text-slate-400 hover:text-red-500 hover:bg-red-50 transition-all">
                                                    <span className="material-symbols-outlined text-[18px]">delete</span>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>

                    {/* Pagination */}
                    <div className="p-6 border-t border-[#f0f2f5] dark:border-[#2d3748] flex items-center justify-between bg-[#f8fafc]/30 dark:bg-slate-900/30">
                        <span className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                            {Math.min(offset + 1, total)}-{Math.min(offset + limit, total)} OF {total} ITEMS
                        </span>
                        <div className="flex gap-2">
                            <button
                                disabled={offset === 0}
                                onClick={() => setOffset(Math.max(0, offset - limit))}
                                className="w-10 h-10 rounded-xl border border-[#e5e7eb] dark:border-[#2d3748] flex items-center justify-center disabled:opacity-30 hover:bg-white dark:hover:bg-slate-800 transition-all active:scale-90"
                            >
                                <span className="material-symbols-outlined text-[18px]">chevron_left</span>
                            </button>
                            <button
                                disabled={offset + limit >= total}
                                onClick={() => setOffset(offset + limit)}
                                className="w-10 h-10 rounded-xl border border-[#e5e7eb] dark:border-[#2d3748] flex items-center justify-center disabled:opacity-30 hover:bg-white dark:hover:bg-slate-800 transition-all active:scale-90"
                            >
                                <span className="material-symbols-outlined text-[18px]">chevron_right</span>
                            </button>
                        </div>
                    </div>
                </div>

                {/* Modal with AnimatePresence */}
                <AnimatePresence>
                    {isModalOpen && (
                        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
                            <motion.div
                                initial={{ opacity: 0 }}
                                animate={{ opacity: 1 }}
                                exit={{ opacity: 0 }}
                                className="absolute inset-0 bg-black/60 backdrop-blur-md"
                                onClick={() => setIsModalOpen(false)}
                            />
                            <motion.div
                                initial={{ opacity: 0, scale: 0.9, y: 20 }}
                                animate={{ opacity: 1, scale: 1, y: 0 }}
                                exit={{ opacity: 0, scale: 0.9, y: 20 }}
                                className="relative w-full max-w-xl bg-white dark:bg-surface-dark rounded-[2.5rem] shadow-2xl overflow-hidden border border-[#f0f2f5] dark:border-[#2d3748]"
                            >
                                <div className="px-10 pt-10 pb-6 flex items-center justify-between border-b border-[#f0f2f5] dark:border-[#2d3748]">
                                    <div>
                                        <h3 className="text-2xl font-black text-text-main dark:text-white tracking-tight">{editingId ? 'Edit Product File' : 'Register New Product'}</h3>
                                        <p className="text-[10px] text-text-muted mt-1 uppercase font-bold tracking-[0.2em]">Inventory Management</p>
                                    </div>
                                    <button onClick={() => setIsModalOpen(false)} className="w-10 h-10 flex items-center justify-center rounded-2xl bg-gray-50 dark:bg-[#111621] text-text-muted hover:text-primary transition-all active:scale-95 border border-[#f0f2f5] dark:border-[#2d3748]">
                                        <span className="material-symbols-outlined">close</span>
                                    </button>
                                </div>
                                <form onSubmit={handleSubmit} className="p-10 space-y-4 max-h-[75vh] overflow-y-auto no-scrollbar">
                                    <div className="flex justify-center mb-8">
                                        <div
                                            className="relative w-28 h-28 rounded-[2rem] bg-gray-50 dark:bg-slate-900 border-2 border-dashed border-[#e5e7eb] dark:border-[#2d3748] flex items-center justify-center cursor-pointer overflow-hidden group hover:border-primary transition-all shadow-sm"
                                            onClick={() => fileInputRef.current?.click()}
                                        >
                                            {currentProduct.imageUrl && currentProduct.imageUrl !== 'https://picsum.photos/id/1/100/100' ? (
                                                <img src={currentProduct.imageUrl} alt="Preview" className="w-full h-full object-cover transition-transform group-hover:scale-110" />
                                            ) : (
                                                <div className="flex flex-col items-center text-slate-400 group-hover:text-primary">
                                                    <span className="material-symbols-outlined text-3xl">add_photo_alternate</span>
                                                    <span className="text-[10px] font-black uppercase mt-1 tracking-widest">Upload Photo</span>
                                                </div>
                                            )}
                                            <input type="file" ref={fileInputRef} onChange={handleImageChange} className="hidden" accept="image/*" />
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 pb-6">
                                        <div className="col-span-1 sm:col-span-2 space-y-2">
                                            <label className="text-[10px] font-black text-text-muted uppercase tracking-widest ml-1">{t('productName')}</label>
                                            <input required placeholder="Item name" className="w-full bg-[#f8fafc] dark:bg-[#111621] border border-[#e5e7eb] dark:border-[#2d3748] rounded-2xl px-5 py-4 text-sm font-bold text-text-main dark:text-white outline-none focus:border-primary focus:ring-4 focus:ring-primary/5 transition-all" value={currentProduct.name} onChange={e => setCurrentProduct({ ...currentProduct, name: e.target.value })} />
                                        </div>

                                        <div className="space-y-2">
                                            <label className="text-[10px] font-black text-text-muted uppercase tracking-widest ml-1">{t('sku')}</label>
                                            <input required placeholder="SKU-XXXX" className="w-full bg-[#f8fafc] dark:bg-[#111621] border border-[#e5e7eb] dark:border-[#2d3748] rounded-2xl px-5 py-4 text-sm font-bold text-text-main dark:text-white outline-none focus:border-primary focus:ring-4 focus:ring-primary/5 transition-all" value={currentProduct.sku} onChange={e => setCurrentProduct({ ...currentProduct, sku: e.target.value })} />
                                        </div>

                                        <div className="space-y-2">
                                            <label className="text-[10px] font-black text-text-muted uppercase tracking-widest ml-1">{t('category')}</label>
                                            <input placeholder="Category" className="w-full bg-[#f8fafc] dark:bg-[#111621] border border-[#e5e7eb] dark:border-[#2d3748] rounded-2xl px-5 py-4 text-sm font-bold text-text-main dark:text-white outline-none focus:border-primary focus:ring-4 focus:ring-primary/5 transition-all" value={currentProduct.category} onChange={e => setCurrentProduct({ ...currentProduct, category: e.target.value })} />
                                        </div>

                                        <div className="space-y-2">
                                            <label className="text-[10px] font-black text-text-muted uppercase tracking-widest ml-1">Stock Level</label>
                                            <input required type="number" className="w-full bg-[#f8fafc] dark:bg-[#111621] border border-[#e5e7eb] dark:border-[#2d3748] rounded-2xl px-5 py-4 text-sm font-bold text-text-main dark:text-white outline-none focus:border-primary focus:ring-4 focus:ring-primary/5 transition-all" value={currentProduct.qty || ''} onChange={e => setCurrentProduct({ ...currentProduct, qty: parseInt(e.target.value) })} />
                                        </div>

                                        <div className="space-y-2">
                                            <label className="text-[10px] font-black text-text-muted uppercase tracking-widest ml-1">{t('cost')}</label>
                                            <div className="relative">
                                                <span className="absolute left-5 top-1/2 -translate-y-1/2 text-text-muted font-bold text-sm">৳</span>
                                                <input required type="number" className="w-full bg-[#f8fafc] dark:bg-[#111621] border border-[#e5e7eb] dark:border-[#2d3748] rounded-2xl px-10 py-4 text-sm font-bold text-text-main dark:text-white outline-none focus:border-primary focus:ring-4 focus:ring-primary/5 transition-all" value={currentProduct.costPrice || ''} onChange={e => setCurrentProduct({ ...currentProduct, costPrice: parseFloat(e.target.value) })} />
                                            </div>
                                        </div>

                                        <div className="col-span-1 sm:col-span-2 space-y-2">
                                            <label className="text-[10px] font-black text-text-muted uppercase tracking-widest ml-1">Retail Price</label>
                                            <div className="relative">
                                                <span className="absolute left-5 top-1/2 -translate-y-1/2 text-primary font-black text-lg">৳</span>
                                                <input required type="number" className="w-full bg-primary/5 border border-primary/20 dark:border-primary/40 rounded-2xl px-10 py-5 text-xl font-black text-primary dark:text-white outline-none focus:ring-4 focus:ring-primary/10 transition-all font-display" value={currentProduct.sellingPrice || ''} onChange={e => setCurrentProduct({ ...currentProduct, sellingPrice: parseFloat(e.target.value) })} />
                                            </div>
                                        </div>
                                    </div>

                                    {/* Specialized Fields */}
                                    <div className="col-span-2 border-t border-[#f0f2f5] dark:border-[#2d3748] pt-8 mt-4">
                                        <div className="flex items-center gap-3 mb-6">
                                            <div className="w-8 h-8 rounded-lg bg-primary/10 flex items-center justify-center">
                                                <span className="material-symbols-outlined text-primary text-[18px]">verified</span>
                                            </div>
                                            <h4 className="text-[10px] font-black text-text-main dark:text-white uppercase tracking-[0.2em]">Industry Specific Data</h4>
                                        </div>

                                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-8">
                                            {(shopDetails.businessType === 'bike_sales' || shopDetails.businessType === 'showroom' || !shopDetails.businessType) && (
                                                <>
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-black text-text-muted uppercase tracking-widest ml-1">Engine Number</label>
                                                        <input className="w-full bg-[#f8fafc] dark:bg-[#111621] border border-[#e5e7eb] dark:border-[#2d3748] rounded-2xl px-5 py-4 text-sm font-bold text-text-main dark:text-white outline-none focus:border-primary focus:ring-4 focus:ring-primary/5 transition-all" value={currentProduct.engineNo || ''} onChange={e => setCurrentProduct({ ...currentProduct, engineNo: e.target.value })} placeholder="ENG-XXXX" />
                                                    </div>
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-black text-text-muted uppercase tracking-widest ml-1">Chassis Number</label>
                                                        <input className="w-full bg-[#f8fafc] dark:bg-[#111621] border border-[#e5e7eb] dark:border-[#2d3748] rounded-2xl px-5 py-4 text-sm font-bold text-text-main dark:text-white outline-none focus:border-primary focus:ring-4 focus:ring-primary/5 transition-all" value={currentProduct.chassisNo || ''} onChange={e => setCurrentProduct({ ...currentProduct, chassisNo: e.target.value })} placeholder="CHS-XXXX" />
                                                    </div>
                                                    <div className="space-y-2">
                                                        <label className="text-[10px] font-black text-text-muted uppercase tracking-widest ml-1">Model Year</label>
                                                        <select className="w-full bg-[#f8fafc] dark:bg-[#111621] border border-[#e5e7eb] dark:border-[#2d3748] rounded-2xl px-5 py-4 text-sm font-bold text-text-main dark:text-white outline-none focus:border-primary focus:ring-4 focus:ring-primary/5 transition-all appearance-none" value={currentProduct.modelYear || ''} onChange={e => setCurrentProduct({ ...currentProduct, modelYear: e.target.value })}>
                                                            <option value="">Select Year</option>
                                                            {Array.from({ length: 15 }, (_, i) => 2026 - i).map(year => (
                                                                <option key={year} value={year}>{year}</option>
                                                            ))}
                                                        </select>
                                                    </div>
                                                </>
                                            )}

                                            {(shopDetails.businessType === 'furniture' || !shopDetails.businessType) && (
                                                <div className="space-y-2">
                                                    <label className="text-[10px] font-black text-text-muted uppercase tracking-widest ml-1">Material Production Cost</label>
                                                    <div className="relative">
                                                        <span className="absolute left-5 top-1/2 -translate-y-1/2 text-slate-400 font-bold">৳</span>
                                                        <input type="number" className="w-full bg-[#f8fafc] dark:bg-[#111621] border border-[#e5e7eb] dark:border-[#2d3748] rounded-2xl px-10 py-4 text-sm font-bold text-text-main dark:text-white outline-none focus:border-primary focus:ring-4 focus:ring-primary/5 transition-all" value={currentProduct.materialCost || ''} onChange={e => setCurrentProduct({ ...currentProduct, materialCost: parseFloat(e.target.value) })} />
                                                    </div>
                                                </div>
                                            )}
                                        </div>
                                    </div>

                                    <div className="pt-10 flex gap-4 sticky bottom-0 bg-white dark:bg-surface-dark pb-4 border-t border-[#f0f2f5] dark:border-[#2d3748]">
                                        <button
                                            type="button"
                                            onClick={() => setIsModalOpen(false)}
                                            className="flex-1 px-8 py-4 rounded-2xl text-sm font-black text-text-muted hover:bg-gray-50 transition-all border border-[#e5e7eb] dark:border-[#2d3748]"
                                        >
                                            {t('cancel')}
                                        </button>
                                        <button
                                            type="submit"
                                            className="flex-[2] bg-primary hover:bg-primary/90 text-white px-8 py-4 rounded-2xl text-sm font-black shadow-xl shadow-primary/20 transition-all active:scale-95"
                                        >
                                            {editingId ? 'Save Product Changes' : 'Complete Registration'}
                                        </button>
                                    </div>
                                </form>
                            </motion.div>
                        </div>
                    )}
                </AnimatePresence>
            </div>
        </Layout>
    );
};

export default ProductsScreen;