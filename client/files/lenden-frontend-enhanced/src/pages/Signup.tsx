import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useStore } from '../context/Store';

export const SignupScreen: React.FC = () => {
    const { register } = useStore();
    const navigate = useNavigate();
    const [shopName, setShopName] = useState('');
    const [ownerName, setOwnerName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        const success = await register(ownerName, email, password);
        setLoading(false);
        if (success) {
            navigate('/');
        }
    };

    return (
        <div className="bg-background-light dark:bg-background-dark font-display text-text-main dark:text-white antialiased min-h-screen flex flex-col">
            <header className="w-full border-b border-[#d0d7e7] dark:border-[#2a3447] bg-surface-light dark:bg-surface-dark px-6 py-4 lg:px-10">
                <div className="mx-auto flex max-w-7xl items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary">
                            <span className="material-symbols-outlined">storefront</span>
                        </div>
                        <h2 className="text-xl font-bold tracking-tight text-text-main dark:text-white">Lenden</h2>
                    </div>
                    <div className="hidden sm:flex items-center gap-4">
                        <span className="text-sm font-medium text-[#4e6797] dark:text-gray-400">Already have an account?</span>
                        <Link to="/" className="flex items-center justify-center rounded-lg bg-primary px-5 py-2 text-sm font-bold text-white transition hover:bg-blue-700">Log In</Link>
                    </div>
                </div>
            </header>
            <main className="flex flex-1 flex-col items-center justify-center px-4 py-12 sm:px-6 lg:px-8 bg-background-light dark:bg-background-dark relative overflow-hidden">
                <div className="absolute -top-[20%] -left-[10%] w-[50%] h-[50%] rounded-full bg-primary/5 blur-3xl pointer-events-none"></div>
                <div className="absolute bottom-[10%] -right-[5%] w-[30%] h-[30%] rounded-full bg-blue-400/5 blur-3xl pointer-events-none"></div>

                <div className="w-full max-w-[520px] relative z-10">
                    <div className="mb-8 text-center">
                        <h1 className="text-3xl font-bold tracking-tight text-text-main dark:text-white sm:text-4xl">Start managing your shop today</h1>
                        <p className="mt-3 text-base text-[#4e6797] dark:text-gray-400">Join thousands of shop owners in Bangladesh managing sales, inventory, and staff with ease.</p>
                    </div>
                    <div className="rounded-xl border border-[#d0d7e7] dark:border-[#2a3447] bg-surface-light dark:bg-surface-dark shadow-sm p-6 sm:p-10">
                        <form className="space-y-6" onSubmit={handleSubmit}>
                            <div>
                                <label className="mb-2 block text-sm font-medium text-text-main dark:text-white">Shop Name</label>
                                <div className="relative">
                                    <input required value={shopName} onChange={e => setShopName(e.target.value)} className="block w-full rounded-lg border border-[#d0d7e7] bg-background-light px-4 py-3 text-base text-text-main placeholder:text-[#4e6797] focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary dark:border-[#2a3447] dark:bg-background-dark dark:text-white dark:focus:border-primary" placeholder="e.g. Bhai Bhai Store" type="text" />
                                    <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-[#4e6797] dark:text-gray-500"><span className="material-symbols-outlined text-[20px]">storefront</span></div>
                                </div>
                            </div>
                            <div>
                                <label className="mb-2 block text-sm font-medium text-text-main dark:text-white">Owner Name</label>
                                <div className="relative">
                                    <input required value={ownerName} onChange={e => setOwnerName(e.target.value)} className="block w-full rounded-lg border border-[#d0d7e7] bg-background-light px-4 py-3 text-base text-text-main placeholder:text-[#4e6797] focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary dark:border-[#2a3447] dark:bg-background-dark dark:text-white dark:focus:border-primary" placeholder="e.g. Rahim Uddin" type="text" />
                                    <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-[#4e6797] dark:text-gray-500"><span className="material-symbols-outlined text-[20px]">person</span></div>
                                </div>
                            </div>
                            <div>
                                <label className="mb-2 block text-sm font-medium text-text-main dark:text-white">Email Address</label>
                                <div className="relative">
                                    <input required value={email} onChange={e => setEmail(e.target.value)} className="block w-full rounded-lg border border-[#d0d7e7] bg-background-light px-4 py-3 text-base text-text-main placeholder:text-[#4e6797] focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary dark:border-[#2a3447] dark:bg-background-dark dark:text-white dark:focus:border-primary" placeholder="name@example.com" type="email" />
                                    <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-[#4e6797] dark:text-gray-500"><span className="material-symbols-outlined text-[20px]">mail</span></div>
                                </div>
                            </div>
                            <div>
                                <label className="mb-2 block text-sm font-medium text-text-main dark:text-white">Password</label>
                                <div className="relative">
                                    <input required value={password} onChange={e => setPassword(e.target.value)} className="block w-full rounded-lg border border-[#d0d7e7] bg-background-light px-4 py-3 text-base text-text-main placeholder:text-[#4e6797] focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary dark:border-[#2a3447] dark:bg-background-dark dark:text-white dark:focus:border-primary" placeholder="Min. 8 characters" type={showPassword ? "text" : "password"} />
                                    <button className="absolute inset-y-0 right-0 flex items-center pr-4 text-[#4e6797] transition hover:text-primary dark:text-gray-500 dark:hover:text-primary" type="button" onClick={() => setShowPassword(!showPassword)}><span className="material-symbols-outlined text-[20px]">{showPassword ? 'visibility_off' : 'visibility'}</span></button>
                                </div>
                            </div>
                            <button disabled={loading} className="flex w-full items-center justify-center rounded-lg bg-primary px-6 py-3.5 text-base font-bold text-white shadow-sm transition hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 dark:focus:ring-offset-gray-900 disabled:opacity-50" type="submit">
                                {loading ? 'Creating Account...' : 'Create Account'}
                            </button>

                            <div className="relative flex items-center py-2">
                                <div className="flex-grow border-t border-[#d0d7e7] dark:border-[#2a3447]"></div>
                                <span className="mx-4 flex-shrink-0 text-xs font-medium uppercase text-[#4e6797] dark:text-gray-500">Or continue with</span>
                                <div className="flex-grow border-t border-[#d0d7e7] dark:border-[#2a3447]"></div>
                            </div>

                            <button className="flex w-full items-center justify-center gap-3 rounded-lg border border-[#d0d7e7] bg-white px-6 py-3 text-sm font-medium text-text-main shadow-sm transition hover:bg-gray-50 dark:border-[#2a3447] dark:bg-surface-dark dark:text-white dark:hover:bg-gray-800" type="button">
                                <svg aria-hidden="true" className="h-5 w-5" viewBox="0 0 24 24">
                                    <path className="text-text-main dark:text-white opacity-20" d="M12.0003 20.45c4.6667 0 8.6052-3.187 9.8778-7.5684H12.0003V9.308h12.551c.123.633.194 1.288.194 1.967 0 7.027-4.939 12.175-12.745 12.175C5.3993 23.45.0003 18.051.0003 11.45S5.3993-.55 12.0003-.55c3.239 0 6.173 1.185 8.448 3.125l-3.366 3.25c-1.278-1.077-2.984-1.725-5.082-1.725-4.148 0-7.653 2.92-8.913 6.86H3.0853V6.992c2.19-4.323 6.697-7.542 12.015-7.542z" fill="currentColor"></path>
                                    <path d="M23.488 11.275c.123.633.194 1.288.194 1.967 0 7.027-4.939 12.175-12.745 12.175-1.936 0-3.766-.46-5.385-1.28l8.917-7.394 9.019-5.468z" fill="#34A853"></path>
                                    <path d="M6.085 17.859c-1.378-2.673-1.635-5.698-.363-8.473l-4.721-3.964C-1.503 9.475-.921 15.033 2.623 19.55l3.462-1.691z" fill="#FBBC05"></path>
                                    <path d="M12.0003 4.75c2.102 0 3.808.648 5.082 1.725l3.366-3.25C18.173 1.385 15.239.2 12.0003.2 6.682.2 2.175 3.419-.015 7.742l4.721 3.964c1.26-3.94 4.765-6.86 8.913-6.86z" fill="#EA4335"></path>
                                    <path d="M12.0003 20.45c4.6667 0 8.6052-3.187 9.8778-7.5684H12.0003v-3.574h12.551c.07.362.115.733.136 1.11L14.718 17.59l-2.718 2.86z" fill="#4285F4"></path>
                                </svg>
                                <span className="text-text-main dark:text-white">Sign up with Google</span>
                            </button>
                        </form>
                    </div>
                    <p className="mt-8 text-center text-sm text-[#4e6797] dark:text-gray-400 sm:hidden">Already have an account? <Link to="/" className="font-bold text-primary hover:underline">Log in</Link></p>
                    <p className="mt-6 text-center text-xs text-[#4e6797]/70 dark:text-gray-500">By clicking "Create Account", you agree to our <a className="underline hover:text-text-main dark:hover:text-white" href="#">Terms of Service</a> and <a className="underline hover:text-text-main dark:hover:text-white" href="#">Privacy Policy</a>.</p>
                </div>
            </main>
        </div>
    );
};