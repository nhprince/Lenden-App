import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useStore } from '../context/Store';

export const ForgotPasswordScreen: React.FC = () => {
    const { forgotPassword } = useStore();
    const [email, setEmail] = useState('');
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        await forgotPassword(email);
        setLoading(false);
    };

    return (
        <div className="bg-background-light dark:bg-background-dark text-[#0e121b] dark:text-white font-display min-h-screen flex flex-col items-center justify-center p-4">
            <div className="w-full max-w-md bg-white dark:bg-[#1e2736] rounded-xl shadow-lg border border-[#e5e7eb] dark:border-[#2d3748] overflow-hidden transition-all duration-300">
                <div className="relative w-full h-32 bg-primary/10 dark:bg-primary/5 flex items-center justify-center overflow-hidden">
                    <div className="absolute inset-0 bg-gradient-to-br from-primary/20 to-transparent"></div>
                    <div className="relative z-10 p-4 bg-white dark:bg-[#1e2736] rounded-full shadow-sm">
                        <span className="material-symbols-outlined text-primary text-4xl">lock_reset</span>
                    </div>
                </div>
                <div className="p-8">
                    <div className="flex flex-col gap-3 mb-8 text-center">
                        <h1 className="text-[#0e121b] dark:text-white tracking-tight text-2xl font-bold leading-tight">Reset your password</h1>
                        <p className="text-[#4e6797] dark:text-[#94a3b8] text-sm font-normal leading-relaxed">Enter the email associated with your Lenden account and we will send you a reset link.</p>
                    </div>
                    <form className="flex flex-col gap-6" onSubmit={handleSubmit}>
                        <div className="flex flex-col gap-2">
                            <label className="text-[#0e121b] dark:text-[#e2e8f0] text-sm font-medium leading-normal" htmlFor="email">Email address</label>
                            <div className="relative">
                                <input required value={email} onChange={e => setEmail(e.target.value)} className="form-input flex w-full min-w-0 resize-none overflow-hidden rounded-lg text-[#0e121b] dark:text-white focus:outline-0 focus:ring-2 focus:ring-primary/20 border border-[#d0d7e7] dark:border-[#4b5563] bg-white dark:bg-[#111621] focus:border-primary h-12 placeholder:text-[#9ca3af] px-4 text-base font-normal leading-normal transition-colors duration-200" id="email" placeholder="name@example.com" type="email" />
                                <div className="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none text-[#9ca3af]">
                                    <span className="material-symbols-outlined text-[20px]">mail</span>
                                </div>
                            </div>
                        </div>
                        <button disabled={loading} className="flex w-full cursor-pointer items-center justify-center overflow-hidden rounded-lg h-12 px-5 bg-primary hover:bg-primary/90 transition-colors text-white text-base font-bold leading-normal tracking-[0.015em] shadow-sm disabled:opacity-50">
                            <span className="truncate">{loading ? 'Sending...' : 'Send reset link'}</span>
                        </button>
                    </form>
                    <div className="mt-6 pt-6 border-t border-[#f0f2f5] dark:border-[#2d3748] flex justify-center">
                        <Link to="/" className="group flex items-center justify-center gap-2 cursor-pointer bg-transparent text-[#4e6797] dark:text-[#94a3b8] hover:text-[#0e121b] dark:hover:text-white transition-colors text-sm font-semibold leading-normal">
                            <span className="material-symbols-outlined text-[18px] transition-transform group-hover:-translate-x-1">arrow_back</span>
                            <span className="truncate">Back to Login</span>
                        </Link>
                    </div>
                </div>
            </div>
            <div className="mt-8 text-center">
                <p className="text-[#94a3b8] text-xs">© 2024 Lenden Inc. Need help? <a className="text-primary hover:underline" href="#">Contact Support</a></p>
            </div>
        </div>
    );
};