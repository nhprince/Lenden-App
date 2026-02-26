import React, { useEffect, useState } from 'react';
import { Layout } from '../components/LayoutEnhanced';
import { AreaChart, Area, ResponsiveContainer, Tooltip, XAxis, YAxis, BarChart, Bar, LineChart, Line } from 'recharts';
import { useStore } from '../context/Store';
import api from '../utils/api';
import { Transaction, Product } from '../types';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';

const chartData = [
    { name: 'Mon', value: 3000, orders: 12 },
    { name: 'Tue', value: 4500, orders: 18 },
    { name: 'Wed', value: 3200, orders: 14 },
    { name: 'Thu', value: 5100, orders: 22 },
    { name: 'Fri', value: 4800, orders: 20 },
    { name: 'Sat', value: 6500, orders: 28 },
    { name: 'Sun', value: 3800, orders: 16 },
];

export const DashboardScreenEnhanced: React.FC = () => {
    const { user, t, shopDetails } = useStore();
    const [stats, setStats] = useState({
        total_sales: 0,
        sales_count: 0,
        total_expenses: 0,
        product_count: 0,
        inventory_value: 0,
        customer_count: 0,
        net_profit: 0
    });
    const [recentTransactions, setRecentTransactions] = useState<Transaction[]>([]);
    const [lowStockProducts, setLowStockProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchDashboardData = async () => {
            if (!shopDetails.id) return;

            try {
                setLoading(true);
                const today = new Date().toISOString().split('T')[0];

                const [summaryRes, transactionsRes, lowStockRes] = await Promise.all([
                    api.get(`/reports/summary?start_date=${today}&end_date=${today}`),
                    api.get('/transactions?limit=5'),
                    api.get('/products?low_stock=true&limit=5')
                ]);

                setStats(summaryRes.data);
                setRecentTransactions(transactionsRes.data.transactions);
                setLowStockProducts(lowStockRes.data.products);
            } catch (error) {
                console.error("Failed to fetch dashboard data", error);
            } finally {
                setLoading(false);
            }
        };

        fetchDashboardData();
    }, [shopDetails.id]);

    if (loading) {
        return (
            <Layout title={t('dashboard')}>
                <div className="max-w-7xl mx-auto">
                    <div className="flex items-center justify-center h-[60vh]">
                        <div className="text-center">
                            <div className="w-16 h-16 border-4 border-primary-200 dark:border-primary-900 border-t-primary-600 dark:border-t-primary-400 rounded-full animate-spin mx-auto mb-4"></div>
                            <p className="text-gray-600 dark:text-gray-400 font-medium">Loading dashboard...</p>
                        </div>
                    </div>
                </div>
            </Layout>
        );
    }

    const StatCard = ({ title, value, icon, trend, trendUp, colorClass, delay }: any) => (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay, duration: 0.5 }}
            whileHover={{ y: -4, transition: { duration: 0.2 } }}
            className={`relative overflow-hidden rounded-2xl p-6 bg-gradient-to-br ${colorClass} backdrop-blur-sm border border-white/20 dark:border-gray-700/20 shadow-lg hover:shadow-xl transition-all group`}
        >
            <div className="absolute right-0 top-0 p-6 opacity-10 group-hover:opacity-20 transition-opacity">
                <span className="material-symbols-outlined text-8xl">{icon}</span>
            </div>
            <div className="relative z-10">
                <p className="text-white/90 font-medium text-sm mb-2">{title}</p>
                <h3 className="text-white text-3xl font-bold mb-3 tracking-tight">{value}</h3>
                {trend && (
                    <div className="flex items-center gap-2">
                        <span className={`${trendUp ? 'bg-white/20' : 'bg-white/20'} text-white text-xs font-bold px-2.5 py-1 rounded-full flex items-center gap-1`}>
                            <span className="material-symbols-outlined text-[14px]">
                                {trendUp ? 'trending_up' : 'trending_down'}
                            </span>
                            {trend}
                        </span>
                        <span className="text-white/70 text-xs font-medium">vs yesterday</span>
                    </div>
                )}
            </div>
        </motion.div>
    );

    return (
        <Layout title={t('dashboard')}>
            <div className="max-w-7xl mx-auto space-y-8 pb-10">
                {/* Welcome Section */}
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.5 }}
                    className="flex flex-col sm:flex-row sm:items-center justify-between gap-4"
                >
                    <div>
                        <p className="text-gray-600 dark:text-gray-400 text-sm mb-1">
                            {t('goodMorning')}, <span className="font-semibold text-gray-900 dark:text-white">{user?.name.split(' ')[0]}</span>
                        </p>
                        <h1 className="text-3xl font-bold text-gray-900 dark:text-white tracking-tight">
                            Here's what's happening today
                        </h1>
                    </div>
                    <Link to="/reports">
                        <motion.button
                            whileHover={{ scale: 1.05 }}
                            whileTap={{ scale: 0.95 }}
                            className="flex items-center gap-2 px-5 py-3 bg-white dark:bg-gray-900 border-2 border-gray-200 dark:border-gray-700 hover:border-primary-600 dark:hover:border-primary-500 rounded-xl text-sm font-bold text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 transition-all shadow-sm hover:shadow-md"
                        >
                            <span className="material-symbols-outlined text-[18px]">bar_chart</span>
                            <span>View Full Report</span>
                        </motion.button>
                    </Link>
                </motion.div>

                {/* Stats Grid */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                    <StatCard
                        title={t('todaysSales')}
                        value={`৳ ${stats.total_sales.toLocaleString()}`}
                        icon="payments"
                        trend="12%"
                        trendUp={true}
                        colorClass="from-primary-600 to-primary-500"
                        delay={0.1}
                    />
                    <StatCard
                        title="Orders"
                        value={stats.sales_count}
                        icon="shopping_cart"
                        trend="8%"
                        trendUp={true}
                        colorClass="from-secondary-600 to-secondary-500"
                        delay={0.2}
                    />
                    <StatCard
                        title={t('inventoryValue')}
                        value={`৳ ${stats.inventory_value.toLocaleString()}`}
                        icon="inventory_2"
                        colorClass="from-accent-600 to-accent-500"
                        delay={0.3}
                    />
                    <StatCard
                        title={t('totalCustomers')}
                        value={stats.customer_count}
                        icon="people"
                        trend="5%"
                        trendUp={true}
                        colorClass="from-purple-600 to-purple-500"
                        delay={0.4}
                    />
                </div>

                {/* Charts Section */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Sales Chart */}
                    <motion.div
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.5, duration: 0.5 }}
                        className="bg-white dark:bg-gray-900 rounded-2xl p-6 border border-gray-200 dark:border-gray-800 shadow-soft hover:shadow-hard transition-all"
                    >
                        <div className="flex items-center justify-between mb-6">
                            <div>
                                <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-1">
                                    {t('salesOverview')}
                                </h3>
                                <p className="text-sm text-gray-600 dark:text-gray-400">Last 7 days performance</p>
                            </div>
                            <div className="flex items-center gap-1 px-3 py-1.5 bg-secondary-100 dark:bg-secondary-950/30 rounded-lg">
                                <span className="material-symbols-outlined text-secondary-600 dark:text-secondary-400 text-[16px]">trending_up</span>
                                <span className="text-xs font-bold text-secondary-700 dark:text-secondary-300">+15.3%</span>
                            </div>
                        </div>
                        <ResponsiveContainer width="100%" height={250}>
                            <AreaChart data={chartData}>
                                <defs>
                                    <linearGradient id="colorValue" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#2563eb" stopOpacity={0.3}/>
                                        <stop offset="95%" stopColor="#2563eb" stopOpacity={0}/>
                                    </linearGradient>
                                </defs>
                                <XAxis 
                                    dataKey="name" 
                                    stroke="#94a3b8"
                                    fontSize={12}
                                    tickLine={false}
                                    axisLine={false}
                                />
                                <YAxis 
                                    stroke="#94a3b8"
                                    fontSize={12}
                                    tickLine={false}
                                    axisLine={false}
                                    tickFormatter={(value) => `${value / 1000}k`}
                                />
                                <Tooltip 
                                    contentStyle={{
                                        backgroundColor: 'rgba(255, 255, 255, 0.95)',
                                        border: 'none',
                                        borderRadius: '12px',
                                        boxShadow: '0 10px 40px -10px rgba(0, 0, 0, 0.2)',
                                        padding: '12px'
                                    }}
                                    labelStyle={{ color: '#0f172a', fontWeight: 'bold', marginBottom: '4px' }}
                                />
                                <Area 
                                    type="monotone" 
                                    dataKey="value" 
                                    stroke="#2563eb" 
                                    strokeWidth={3}
                                    fill="url(#colorValue)" 
                                />
                            </AreaChart>
                        </ResponsiveContainer>
                    </motion.div>

                    {/* Orders Chart */}
                    <motion.div
                        initial={{ opacity: 0, x: 20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.6, duration: 0.5 }}
                        className="bg-white dark:bg-gray-900 rounded-2xl p-6 border border-gray-200 dark:border-gray-800 shadow-soft hover:shadow-hard transition-all"
                    >
                        <div className="flex items-center justify-between mb-6">
                            <div>
                                <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-1">
                                    Order Activity
                                </h3>
                                <p className="text-sm text-gray-600 dark:text-gray-400">Daily order volume</p>
                            </div>
                            <div className="flex items-center gap-1 px-3 py-1.5 bg-accent-100 dark:bg-accent-950/30 rounded-lg">
                                <span className="material-symbols-outlined text-accent-600 dark:text-accent-400 text-[16px]">local_fire_department</span>
                                <span className="text-xs font-bold text-accent-700 dark:text-accent-300">Hot</span>
                            </div>
                        </div>
                        <ResponsiveContainer width="100%" height={250}>
                            <BarChart data={chartData}>
                                <XAxis 
                                    dataKey="name" 
                                    stroke="#94a3b8"
                                    fontSize={12}
                                    tickLine={false}
                                    axisLine={false}
                                />
                                <YAxis 
                                    stroke="#94a3b8"
                                    fontSize={12}
                                    tickLine={false}
                                    axisLine={false}
                                />
                                <Tooltip 
                                    contentStyle={{
                                        backgroundColor: 'rgba(255, 255, 255, 0.95)',
                                        border: 'none',
                                        borderRadius: '12px',
                                        boxShadow: '0 10px 40px -10px rgba(0, 0, 0, 0.2)',
                                        padding: '12px'
                                    }}
                                    labelStyle={{ color: '#0f172a', fontWeight: 'bold', marginBottom: '4px' }}
                                />
                                <Bar 
                                    dataKey="orders" 
                                    fill="#10b981" 
                                    radius={[8, 8, 0, 0]}
                                />
                            </BarChart>
                        </ResponsiveContainer>
                    </motion.div>
                </div>

                {/* Recent Transactions & Low Stock */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Recent Transactions */}
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.7, duration: 0.5 }}
                        className="bg-white dark:bg-gray-900 rounded-2xl p-6 border border-gray-200 dark:border-gray-800 shadow-soft"
                    >
                        <div className="flex items-center justify-between mb-6">
                            <h3 className="text-lg font-bold text-gray-900 dark:text-white">
                                {t('recentTransactions')}
                            </h3>
                            <Link to="/transactions" className="text-sm font-semibold text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 transition-colors">
                                View all
                            </Link>
                        </div>
                        <div className="space-y-3">
                            {recentTransactions.length > 0 ? (
                                recentTransactions.map((tx, idx) => (
                                    <motion.div
                                        key={tx.id}
                                        initial={{ opacity: 0, x: -10 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        transition={{ delay: 0.8 + idx * 0.05 }}
                                        className="flex items-center justify-between p-4 rounded-xl bg-gray-50 dark:bg-gray-800 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors group"
                                    >
                                        <div className="flex items-center gap-3">
                                            <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                                                tx.status === 'Completed' 
                                                    ? 'bg-secondary-100 dark:bg-secondary-950/30' 
                                                    : 'bg-accent-100 dark:bg-accent-950/30'
                                            }`}>
                                                <span className={`material-symbols-outlined text-[20px] ${
                                                    tx.status === 'Completed' 
                                                        ? 'text-secondary-600 dark:text-secondary-400' 
                                                        : 'text-accent-600 dark:text-accent-400'
                                                }`}>
                                                    {tx.status === 'Completed' ? 'check_circle' : 'schedule'}
                                                </span>
                                            </div>
                                            <div>
                                                <p className="font-semibold text-gray-900 dark:text-white text-sm">
                                                    {tx.customerName}
                                                </p>
                                                <p className="text-xs text-gray-500 dark:text-gray-400">
                                                    {tx.orderId}
                                                </p>
                                            </div>
                                        </div>
                                        <div className="text-right">
                                            <p className="font-bold text-gray-900 dark:text-white">
                                                ৳ {tx.total.toLocaleString()}
                                            </p>
                                            <span className={`text-xs font-medium px-2 py-0.5 rounded-full ${
                                                tx.status === 'Completed' 
                                                    ? 'bg-secondary-100 dark:bg-secondary-950/30 text-secondary-700 dark:text-secondary-300' 
                                                    : 'bg-accent-100 dark:bg-accent-950/30 text-accent-700 dark:text-accent-300'
                                            }`}>
                                                {tx.status}
                                            </span>
                                        </div>
                                    </motion.div>
                                ))
                            ) : (
                                <div className="text-center py-12">
                                    <span className="material-symbols-outlined text-5xl text-gray-300 dark:text-gray-700 mb-3">receipt_long</span>
                                    <p className="text-gray-500 dark:text-gray-400 text-sm">No transactions yet</p>
                                </div>
                            )}
                        </div>
                    </motion.div>

                    {/* Low Stock Alerts */}
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.8, duration: 0.5 }}
                        className="bg-white dark:bg-gray-900 rounded-2xl p-6 border border-gray-200 dark:border-gray-800 shadow-soft"
                    >
                        <div className="flex items-center justify-between mb-6">
                            <div className="flex items-center gap-2">
                                <h3 className="text-lg font-bold text-gray-900 dark:text-white">
                                    {t('lowStockAlerts')}
                                </h3>
                                {lowStockProducts.length > 0 && (
                                    <span className="bg-danger-100 dark:bg-danger-950/30 text-danger-700 dark:text-danger-300 text-xs font-bold px-2 py-0.5 rounded-full">
                                        {lowStockProducts.length}
                                    </span>
                                )}
                            </div>
                            <Link to="/products?filter=low_stock" className="text-sm font-semibold text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 transition-colors">
                                View all
                            </Link>
                        </div>
                        <div className="space-y-3">
                            {lowStockProducts.length > 0 ? (
                                lowStockProducts.map((product, idx) => (
                                    <motion.div
                                        key={product.id}
                                        initial={{ opacity: 0, x: 10 }}
                                        animate={{ opacity: 1, x: 0 }}
                                        transition={{ delay: 0.9 + idx * 0.05 }}
                                        className="flex items-center justify-between p-4 rounded-xl bg-danger-50 dark:bg-danger-950/20 border border-danger-200 dark:border-danger-900/30 hover:border-danger-300 dark:hover:border-danger-800 transition-colors"
                                    >
                                        <div className="flex items-center gap-3">
                                            <img 
                                                src={product.imageUrl} 
                                                alt={product.name}
                                                className="w-10 h-10 rounded-lg object-cover bg-white dark:bg-gray-800"
                                            />
                                            <div>
                                                <p className="font-semibold text-gray-900 dark:text-white text-sm">
                                                    {product.name}
                                                </p>
                                                <p className="text-xs text-gray-500 dark:text-gray-400">
                                                    SKU: {product.sku}
                                                </p>
                                            </div>
                                        </div>
                                        <div className="text-right">
                                            <p className="font-bold text-danger-600 dark:text-danger-400">
                                                {product.qty} left
                                            </p>
                                            <span className="text-xs text-danger-600 dark:text-danger-400 font-medium">
                                                Reorder now
                                            </span>
                                        </div>
                                    </motion.div>
                                ))
                            ) : (
                                <div className="text-center py-12">
                                    <span className="material-symbols-outlined text-5xl text-gray-300 dark:text-gray-700 mb-3">inventory_2</span>
                                    <p className="text-gray-500 dark:text-gray-400 text-sm">All stock levels are good</p>
                                </div>
                            )}
                        </div>
                    </motion.div>
                </div>
            </div>
        </Layout>
    );
};
