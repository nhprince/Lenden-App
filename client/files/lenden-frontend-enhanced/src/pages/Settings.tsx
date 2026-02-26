import React, { useState, useRef } from 'react';
import { Layout } from '../components/Layout';
import { useStore } from '../context/Store';
import api from '../utils/api';
import toast from 'react-hot-toast';

export const SettingsScreen: React.FC = () => {
    const {
        shopDetails, updateShopDetails,
        invoiceSettings, updateInvoiceSettings,
        user, updateUserProfile,
        t
    } = useStore();

    // Local state for forms to handle inputs before saving
    const [shopForm, setShopForm] = useState(shopDetails);
    const [invoiceForm, setInvoiceForm] = useState(invoiceSettings);
    const [userForm, setUserForm] = useState({ name: user?.name || '', email: user?.email || '' });

    const [activeTab, setActiveTab] = useState<'shop' | 'invoice' | 'user'>('shop');
    const fileInputRef = useRef<HTMLInputElement>(null);

    const handleSaveShop = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await api.put(`/shops/${shopDetails.id}`, shopForm);
            updateShopDetails(shopForm);
            toast.success(t('savedSuccessfully'));
        } catch (error) {
            console.error("Failed to save shop settings", error);
            toast.error("Failed to save settings");
        }
    };

    const handleSaveInvoice = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            // Invoice settings are currently part of shop details in the backend update
            await api.put(`/shops/${shopDetails.id}`, {
                ...shopForm,
                header_title: invoiceForm.headerTitle,
                footer_note: invoiceForm.footerNote,
                terms: invoiceForm.terms,
                show_logo: invoiceForm.showLogo
            });
            updateInvoiceSettings(invoiceForm);
            toast.success(t('savedSuccessfully'));
        } catch (error) {
            console.error("Failed to save invoice settings", error);
            toast.error("Failed to save settings");
        }
    };

    const handleSaveUser = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await api.put('/auth/profile', userForm);
            updateUserProfile(userForm);
            toast.success(t('savedSuccessfully'));
        } catch (error) {
            console.error("Failed to save user profile", error);
            toast.error("Failed to save settings");
        }
    };

    const handleLogoChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files[0]) {
            const file = e.target.files[0];
            const reader = new FileReader();
            reader.onloadend = () => {
                setShopForm({ ...shopForm, logoUrl: reader.result as string });
            };
            reader.readAsDataURL(file);
        }
    };

    return (
        <Layout title={t('settings')}>
            <div className="max-w-4xl mx-auto pb-10">

                <div className="flex flex-col md:flex-row gap-8">
                    {/* Sidebar Tabs */}
                    <div className="w-full md:w-64 flex-shrink-0 space-y-2">
                        <button
                            onClick={() => setActiveTab('shop')}
                            className={`w-full text-left px-4 py-3 rounded-xl flex items-center gap-3 transition-colors ${activeTab === 'shop' ? 'bg-primary text-white shadow-lg shadow-primary/30' : 'bg-white dark:bg-surface-dark text-text-muted hover:bg-gray-50 dark:hover:bg-gray-800'}`}
                        >
                            <span className="material-symbols-outlined">storefront</span>
                            <span className="font-medium">{t('shopProfile')}</span>
                        </button>
                        <button
                            onClick={() => setActiveTab('invoice')}
                            className={`w-full text-left px-4 py-3 rounded-xl flex items-center gap-3 transition-colors ${activeTab === 'invoice' ? 'bg-primary text-white shadow-lg shadow-primary/30' : 'bg-white dark:bg-surface-dark text-text-muted hover:bg-gray-50 dark:hover:bg-gray-800'}`}
                        >
                            <span className="material-symbols-outlined">receipt_long</span>
                            <span className="font-medium">{t('invoiceSettings')}</span>
                        </button>
                        <button
                            onClick={() => setActiveTab('user')}
                            className={`w-full text-left px-4 py-3 rounded-xl flex items-center gap-3 transition-colors ${activeTab === 'user' ? 'bg-primary text-white shadow-lg shadow-primary/30' : 'bg-white dark:bg-surface-dark text-text-muted hover:bg-gray-50 dark:hover:bg-gray-800'}`}
                        >
                            <span className="material-symbols-outlined">person</span>
                            <span className="font-medium">{t('userProfile')}</span>
                        </button>
                    </div>

                    {/* Content Area */}
                    <div className="flex-1">
                        {/* Shop Profile Tab */}
                        {activeTab === 'shop' && (
                            <form onSubmit={handleSaveShop} className="bg-white dark:bg-surface-dark rounded-xl shadow-sm border border-gray-200 dark:border-gray-800 p-6 sm:p-8 animate-in fade-in duration-300">
                                <h3 className="text-xl font-bold mb-6 text-text-main dark:text-white flex items-center gap-2">
                                    <span className="material-symbols-outlined text-primary">storefront</span>
                                    {t('shopProfile')}
                                </h3>

                                <div className="space-y-6">
                                    <div className="flex items-center gap-6">
                                        <div
                                            onClick={() => fileInputRef.current?.click()}
                                            className="w-24 h-24 rounded-full bg-gray-100 dark:bg-gray-800 border-2 border-dashed border-gray-300 dark:border-gray-600 flex items-center justify-center cursor-pointer overflow-hidden hover:border-primary transition-colors relative group"
                                        >
                                            {shopForm.logoUrl ? (
                                                <img src={shopForm.logoUrl} alt="Shop Logo" className="w-full h-full object-cover" />
                                            ) : (
                                                <span className="material-symbols-outlined text-gray-400 text-3xl">add_photo_alternate</span>
                                            )}
                                            <div className="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                                                <span className="material-symbols-outlined text-white">edit</span>
                                            </div>
                                        </div>
                                        <div className="flex-1">
                                            <h4 className="font-medium text-text-main dark:text-white">Shop Logo</h4>
                                            <p className="text-sm text-text-muted mb-2">Recommended size 200x200px</p>
                                            <button type="button" onClick={() => fileInputRef.current?.click()} className="text-sm text-primary font-medium hover:underline">Upload new image</button>
                                            <input type="file" ref={fileInputRef} onChange={handleLogoChange} className="hidden" accept="image/*" />
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-1 gap-6">
                                        <div>
                                            <label className="block text-sm font-medium text-text-muted mb-1">{t('name')}</label>
                                            <input
                                                className="form-input w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                                value={shopForm.name}
                                                onChange={e => setShopForm({ ...shopForm, name: e.target.value })}
                                            />
                                        </div>
                                        <div>
                                            <label className="block text-sm font-medium text-text-muted mb-1">{t('address')}</label>
                                            <textarea
                                                rows={3}
                                                className="form-input w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                                value={shopForm.address}
                                                onChange={e => setShopForm({ ...shopForm, address: e.target.value })}
                                            />
                                        </div>
                                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                                            <div>
                                                <label className="block text-sm font-medium text-text-muted mb-1">{t('phone')}</label>
                                                <input
                                                    className="form-input w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                                    value={shopForm.phone}
                                                    onChange={e => setShopForm({ ...shopForm, phone: e.target.value })}
                                                />
                                            </div>
                                            <div>
                                                <label className="block text-sm font-medium text-text-muted mb-1">{t('email')}</label>
                                                <input
                                                    type="email"
                                                    className="form-input w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                                    value={shopForm.email}
                                                    onChange={e => setShopForm({ ...shopForm, email: e.target.value })}
                                                />
                                            </div>
                                        </div>
                                        <div>
                                            <label className="block text-sm font-medium text-text-muted mb-1">{t('website')}</label>
                                            <input
                                                className="form-input w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                                value={shopForm.website}
                                                onChange={e => setShopForm({ ...shopForm, website: e.target.value })}
                                            />
                                        </div>
                                    </div>

                                    <div className="pt-4 border-t border-gray-100 dark:border-gray-800 flex justify-end">
                                        <button type="submit" className="bg-primary text-white px-6 py-2.5 rounded-lg font-bold shadow-lg shadow-primary/20 hover:bg-primary/90 transition-colors">
                                            {t('saveChanges')}
                                        </button>
                                    </div>
                                </div>
                            </form>
                        )}

                        {/* Invoice Settings Tab */}
                        {activeTab === 'invoice' && (
                            <form onSubmit={handleSaveInvoice} className="bg-white dark:bg-surface-dark rounded-xl shadow-sm border border-gray-200 dark:border-gray-800 p-6 sm:p-8 animate-in fade-in duration-300">
                                <h3 className="text-xl font-bold mb-6 text-text-main dark:text-white flex items-center gap-2">
                                    <span className="material-symbols-outlined text-primary">receipt_long</span>
                                    {t('invoiceSettings')}
                                </h3>

                                <div className="space-y-6">
                                    <div className="grid grid-cols-1 gap-6">
                                        <div>
                                            <label className="block text-sm font-medium text-text-muted mb-1">{t('invoiceTitle')}</label>
                                            <input
                                                className="form-input w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                                placeholder="e.g. INVOICE, MEMO, BILL"
                                                value={invoiceForm.headerTitle}
                                                onChange={e => setInvoiceForm({ ...invoiceForm, headerTitle: e.target.value })}
                                            />
                                        </div>
                                        <div>
                                            <label className="block text-sm font-medium text-text-muted mb-1">{t('footerNote')}</label>
                                            <input
                                                className="form-input w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                                placeholder="e.g. Thank you for your business!"
                                                value={invoiceForm.footerNote}
                                                onChange={e => setInvoiceForm({ ...invoiceForm, footerNote: e.target.value })}
                                            />
                                        </div>
                                        <div>
                                            <label className="block text-sm font-medium text-text-muted mb-1">{t('termsConditions')}</label>
                                            <textarea
                                                rows={4}
                                                className="form-input w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                                placeholder="Enter terms and conditions..."
                                                value={invoiceForm.terms}
                                                onChange={e => setInvoiceForm({ ...invoiceForm, terms: e.target.value })}
                                            />
                                        </div>
                                        <div className="flex items-center gap-3">
                                            <input
                                                type="checkbox"
                                                id="showLogo"
                                                checked={invoiceForm.showLogo}
                                                onChange={e => setInvoiceForm({ ...invoiceForm, showLogo: e.target.checked })}
                                                className="w-5 h-5 rounded border-gray-300 text-primary focus:ring-primary"
                                            />
                                            <label htmlFor="showLogo" className="text-sm font-medium text-text-main dark:text-white">Show Shop Logo on Invoice</label>
                                        </div>
                                    </div>

                                    <div className="pt-4 border-t border-gray-100 dark:border-gray-800 flex justify-end">
                                        <button type="submit" className="bg-primary text-white px-6 py-2.5 rounded-lg font-bold shadow-lg shadow-primary/20 hover:bg-primary/90 transition-colors">
                                            {t('saveChanges')}
                                        </button>
                                    </div>
                                </div>
                            </form>
                        )}

                        {/* User Profile Tab */}
                        {activeTab === 'user' && (
                            <form onSubmit={handleSaveUser} className="bg-white dark:bg-surface-dark rounded-xl shadow-sm border border-gray-200 dark:border-gray-800 p-6 sm:p-8 animate-in fade-in duration-300">
                                <h3 className="text-xl font-bold mb-6 text-text-main dark:text-white flex items-center gap-2">
                                    <span className="material-symbols-outlined text-primary">person</span>
                                    {t('userProfile')}
                                </h3>

                                <div className="space-y-6">
                                    <div className="flex items-center gap-6">
                                        <div
                                            className="w-24 h-24 rounded-full bg-gray-100 dark:bg-gray-800 bg-cover bg-center border-2 border-gray-200 dark:border-gray-700"
                                            style={{ backgroundImage: `url('${user?.avatarUrl}')` }}
                                        ></div>
                                        <div>
                                            <h4 className="font-bold text-lg text-text-main dark:text-white">{user?.name}</h4>
                                            <p className="text-sm text-text-muted">{user?.role}</p>
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-1 gap-6">
                                        <div>
                                            <label className="block text-sm font-medium text-text-muted mb-1">{t('name')}</label>
                                            <input
                                                className="form-input w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                                value={userForm.name}
                                                onChange={e => setUserForm({ ...userForm, name: e.target.value })}
                                            />
                                        </div>
                                        <div>
                                            <label className="block text-sm font-medium text-text-muted mb-1">{t('email')}</label>
                                            <input
                                                type="email"
                                                className="form-input w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                                value={userForm.email}
                                                onChange={e => setUserForm({ ...userForm, email: e.target.value })}
                                            />
                                        </div>
                                    </div>

                                    <div className="pt-4 border-t border-gray-100 dark:border-gray-800 flex justify-end">
                                        <button type="submit" className="bg-primary text-white px-6 py-2.5 rounded-lg font-bold shadow-lg shadow-primary/20 hover:bg-primary/90 transition-colors">
                                            {t('saveChanges')}
                                        </button>
                                    </div>
                                </div>
                            </form>
                        )}
                    </div>
                </div>
            </div>
        </Layout>
    );
};