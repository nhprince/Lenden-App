import axios from 'axios';

// Create an instance of axios
const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL || 'https://api.lenden.cyberslayersagency.com',
    headers: {
        'Content-Type': 'application/json',
    },
});

// Add a request interceptor
api.interceptors.request.use(
    (config) => {
        // Force /api prefix for relative URLs if not already present
        if (config.url && !config.url.startsWith('http') && !config.url.startsWith('/api')) {
            config.url = `/api${config.url.startsWith('/') ? '' : '/'}${config.url}`;
        }

        const token = localStorage.getItem('token');
        const shop = localStorage.getItem('currentShop');

        if (token) {
            config.headers['Authorization'] = `Bearer ${token}`;
        }

        if (shop) {
            try {
                const shopData = JSON.parse(shop);
                if (shopData && shopData.id) {
                    config.headers['Shop-Id'] = shopData.id;
                }
            } catch (e) {
                console.error("Error parsing shop data", e);
            }
        }

        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Add a response interceptor
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response && error.response.status === 401) {
            localStorage.removeItem('token');
            localStorage.removeItem('user');
            localStorage.removeItem('currentShop');
            // Check if it's already on the login page to avoid infinite loop
            if (window.location.hash !== '#/' && window.location.pathname !== '/') {
                window.location.href = '/';
            }
        }
        return Promise.reject(error);
    }
);

export default api;
