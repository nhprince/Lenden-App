import React, { useState, useEffect } from 'react';
import { Layout } from '../components/Layout';
import { useStore } from '../context/Store';
import api from '../utils/api';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import toast from 'react-hot-toast';

export const ReportsScreen: React.FC = () => {
    const { t, shopDetails } = useStore();
    const [summary, setSummary] = useState<any>(null);
    const [trendData, setTrendData] = useState<any[]>([]);
    const [distributionData, setDistributionData] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    const fetchData = async () => {
        if (!shopDetails.id) return;
        try {
            setLoading(true);
            const [summaryRes, trendRes, distRes] = await Promise.all([
                api.get('/reports/summary'),
                api.get('/reports/trend'),
                api.get('/reports/distribution')
            ]);
            setSummary(summaryRes.data);

            // Format trend data for display
            const formattedTrend = trendRes.data.map((item: any) => ({
                date: new Date(item.date).toLocaleDateString('en-US', { weekday: 'short' }),
                sales: parseFloat(item.sales)
            }));
            setTrendData(formattedTrend);
            setDistributionData(distRes.data);
        } catch (error) {
            console.error("Failed to fetch report data", error);
            toast.error("Failed to load reports");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, [shopDetails.id]);

    const COLORS = ['#1754cf', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];

    if (loading && !summary) {
        return (
            <Layout title={t('businessReports')}>
                <div className="flex items-center justify-center h-full">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
                </div>
            </Layout>
        );
    }

    return (
        <Layout title={t('businessReports')}>
            <div className="max-w-7xl mx-auto flex flex-col gap-6 pb-8">
                <div className="flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4">
                    <div>
                        <h2 className="text-2xl font-bold text-text-main dark:text-white">{t('performanceAnalytics')}</h2>
                        <p className="text-text-muted">Overview of your shop's financial health</p>
                    </div>
                </div>

                {/* KPI Cards */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                    <div className="bg-white dark:bg-surface-dark p-6 rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm">
                        <p className="text-text-muted text-sm font-medium mb-2">{t('totalRevenue')}</p>
                        <h3 className="text-3xl font-bold text-text-main dark:text-white">৳{(summary?.total_sales || 0).toLocaleString()}</h3>
                        <div className="mt-2 text-green-500 text-sm font-medium flex items-center gap-1">
                            <span className="material-symbols-outlined text-sm">trending_up</span> +12.5%
                        </div>
                    </div>
                    <div className="bg-white dark:bg-surface-dark p-6 rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm">
                        <p className="text-text-muted text-sm font-medium mb-2">{t('transactions')}</p>
                        <h3 className="text-3xl font-bold text-text-main dark:text-white">{summary?.sales_count || 0}</h3>
                        <div className="mt-2 text-text-muted text-sm">Total orders processed</div>
                    </div>
                    <div className="bg-white dark:bg-surface-dark p-6 rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm">
                        <p className="text-text-muted text-sm font-medium mb-2">{t('avgOrderValue')}</p>
                        <h3 className="text-3xl font-bold text-text-main dark:text-white">
                            ৳{summary?.sales_count > 0 ? (summary.total_sales / summary.sales_count).toFixed(0) : 0}
                        </h3>
                        <div className="mt-2 text-text-muted text-sm">Per transaction</div>
                    </div>
                    <div className="bg-white dark:bg-surface-dark p-6 rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm">
                        <p className="text-text-muted text-sm font-medium mb-2">{t('pendingPayments')}</p>
                        <h3 className="text-3xl font-bold text-amber-500">৳{(summary?.total_due || 0).toLocaleString()}</h3>
                        <div className="mt-2 text-amber-600/70 text-sm font-medium">Needs attention</div>
                    </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Sales Chart */}
                    <div className="bg-white dark:bg-surface-dark p-6 rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm h-[400px] flex flex-col">
                        <h3 className="text-lg font-bold text-text-main dark:text-white mb-6">Sales Trend (Last 7 Days)</h3>
                        <div className="flex-1 w-full min-h-0">
                            {trendData.length > 0 ? (
                                <ResponsiveContainer width="100%" height="100%">
                                    <BarChart data={trendData}>
                                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb33" />
                                        <XAxis dataKey="date" axisLine={false} tickLine={false} tick={{ fill: '#9ca3af' }} dy={10} />
                                        <YAxis axisLine={false} tickLine={false} tick={{ fill: '#9ca3af' }} />
                                        <Tooltip
                                            contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)', backgroundColor: '#fff' }}
                                            cursor={{ fill: '#f3f4f6' }}
                                        />
                                        <Bar dataKey="sales" fill="#1754cf" radius={[6, 6, 0, 0]} barSize={40} />
                                    </BarChart>
                                </ResponsiveContainer>
                            ) : (
                                <div className="h-full flex items-center justify-center text-text-muted">No sales data available</div>
                            )}
                        </div>
                    </div>

                    {/* Category Distribution */}
                    <div className="bg-white dark:bg-surface-dark p-6 rounded-xl border border-gray-200 dark:border-gray-800 shadow-sm h-[400px] flex flex-col">
                        <h3 className="text-lg font-bold text-text-main dark:text-white mb-6">Inventory Distribution</h3>
                        <div className="flex-1 w-full min-h-0">
                            {distributionData.length > 0 ? (
                                <ResponsiveContainer width="100%" height="100%">
                                    <PieChart>
                                        <Pie
                                            data={distributionData}
                                            cx="50%"
                                            cy="50%"
                                            innerRadius={60}
                                            outerRadius={100}
                                            paddingAngle={5}
                                            dataKey="value"
                                        >
                                            {distributionData.map((_entry, index) => (
                                                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                            ))}
                                        </Pie>
                                        <Tooltip contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }} />
                                    </PieChart>
                                </ResponsiveContainer>
                            ) : (
                                <div className="h-full flex items-center justify-center text-text-muted">No inventory data available</div>
                            )}
                        </div>
                        <div className="flex justify-center flex-wrap gap-4 mt-[-20px] pb-2">
                            {distributionData.map((entry, index) => (
                                <div key={entry.name} className="flex items-center gap-2">
                                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: COLORS[index % COLORS.length] }}></div>
                                    <span className="text-sm text-text-muted">{entry.name}</span>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
        </Layout>
    );
};