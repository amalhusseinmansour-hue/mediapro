// ========================================
// Authentication JavaScript
// ميديا برو - نفس تصميم Flutter
// ========================================

const API_URL = 'https://mediaprosocial.io/api';

// Toggle Password Visibility
function togglePassword() {
    const passwordInput = document.getElementById('password');
    const toggleIcon = document.getElementById('toggleIcon');

    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        toggleIcon.classList.remove('fa-eye');
        toggleIcon.classList.add('fa-eye-slash');
    } else {
        passwordInput.type = 'password';
        toggleIcon.classList.remove('fa-eye-slash');
        toggleIcon.classList.add('fa-eye');
    }
}

// Show Error Message
function showError(message) {
    const errorAlert = document.getElementById('errorAlert');
    const errorMessage = document.getElementById('errorMessage');

    if (errorAlert && errorMessage) {
        errorMessage.textContent = message;
        errorAlert.style.display = 'flex';

        setTimeout(() => {
            errorAlert.style.display = 'none';
        }, 5000);
    }
}

// Show Success Message
function showSuccess(message) {
    const errorAlert = document.getElementById('errorAlert');
    if (errorAlert) {
        errorAlert.className = 'alert alert-success';
        errorAlert.querySelector('i').className = 'fas fa-check-circle';
        document.getElementById('errorMessage').textContent = message;
        errorAlert.style.display = 'flex';

        setTimeout(() => {
            errorAlert.style.display = 'none';
            errorAlert.className = 'alert alert-error';
            errorAlert.querySelector('i').className = 'fas fa-exclamation-circle';
        }, 3000);
    }
}

// Show Loading
function showLoading(show = true) {
    const loadingOverlay = document.getElementById('loadingOverlay');
    if (loadingOverlay) {
        loadingOverlay.style.display = show ? 'flex' : 'none';
    }
}

// Login Handler
document.addEventListener('DOMContentLoaded', function () {
    const loginForm = document.getElementById('loginForm');

    if (loginForm) {
        loginForm.addEventListener('submit', async function (e) {
            e.preventDefault();

            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            const remember = document.getElementById('remember').checked;

            if (!email || !password) {
                showError('الرجاء إدخال البريد الإلكتروني وكلمة المرور');
                return;
            }

            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                showError('الرجاء إدخال بريد إلكتروني صحيح');
                return;
            }

            showLoading(true);

            try {
                const response = await fetch(`${API_URL}/login`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                    },
                    body: JSON.stringify({
                        email: email,
                        password: password,
                        remember: remember
                    })
                });

                const data = await response.json();

                if (response.ok && data.success) {
                    localStorage.setItem('auth_token', data.token);
                    localStorage.setItem('user_data', JSON.stringify(data.user));

                    if (remember) {
                        localStorage.setItem('remember_me', 'true');
                    }

                    showSuccess('تم تسجيل الدخول بنجاح! جاري التحويل...');

                    setTimeout(() => {
                        window.location.href = 'index.html';
                    }, 1000);
                } else {
                    showError(data.message || 'فشل تسجيل الدخول. الرجاء التحقق من بياناتك');
                }
            } catch (error) {
                console.error('Login error:', error);
                showError('حدث خطأ في الاتصال. الرجاء المحاولة مرة أخرى');
            } finally {
                showLoading(false);
            }
        });
    }
});

// Register Handler
document.addEventListener('DOMContentLoaded', function () {
    const registerForm = document.getElementById('registerForm');

    if (registerForm) {
        registerForm.addEventListener('submit', async function (e) {
            e.preventDefault();

            const name = document.getElementById('name').value;
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const terms = document.getElementById('terms').checked;

            if (!name || !email || !password || !confirmPassword) {
                showError('الرجاء ملء جميع الحقول');
                return;
            }

            if (password !== confirmPassword) {
                showError('كلمتا المرور غير متطابقتين');
                return;
            }

            if (password.length < 8) {
                showError('كلمة المرور يجب أن تكون 8 أحرف على الأقل');
                return;
            }

            if (!terms) {
                showError('يجب الموافقة على الشروط والأحكام');
                return;
            }

            showLoading(true);

            try {
                const response = await fetch(`${API_URL}/register`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                    },
                    body: JSON.stringify({
                        name: name,
                        email: email,
                        password: password,
                        password_confirmation: confirmPassword
                    })
                });

                const data = await response.json();

                if (response.ok && data.success) {
                    localStorage.setItem('auth_token', data.token);
                    localStorage.setItem('user_data', JSON.stringify(data.user));

                    showSuccess('تم إنشاء الحساب بنجاح! جاري التحويل...');

                    setTimeout(() => {
                        window.location.href = 'index.html';
                    }, 1000);
                } else {
                    showError(data.message || 'فشل إنشاء الحساب. الرجاء المحاولة مرة أخرى');
                }
            } catch (error) {
                console.error('Register error:', error);
                showError('حدث خطأ في الاتصال. الرجاء المحاولة مرة أخرى');
            } finally {
                showLoading(false);
            }
        });
    }
});

// Logout
function logout() {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_data');
    localStorage.removeItem('remember_me');
    window.location.href = 'login.html';
}

// Get user data
function getUserData() {
    const userData = localStorage.getItem('user_data');
    return userData ? JSON.parse(userData) : null;
}

// Get auth token
function getAuthToken() {
    return localStorage.getItem('auth_token');
}

// API call with authentication
async function apiCall(endpoint, options = {}) {
    const token = getAuthToken();

    const headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...options.headers
    };

    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    try {
        const response = await fetch(`${API_URL}${endpoint}`, {
            ...options,
            headers
        });

        if (response.status === 401) {
            logout();
            return;
        }

        return await response.json();
    } catch (error) {
        console.error('API call error:', error);
        throw error;
    }
}

// Check authentication
function checkAuth() {
    const token = getAuthToken();
    const currentPage = window.location.pathname;

    if (token && (currentPage.includes('login') || currentPage.includes('register'))) {
        window.location.href = 'index.html';
    } else if (!token && !currentPage.includes('login') && !currentPage.includes('register') && !currentPage.includes('forgot-password')) {
        window.location.href = 'login.html';
    }
}

// Export functions
window.authUtils = {
    logout,
    getUserData,
    getAuthToken,
    apiCall,
    showError,
    showSuccess,
    showLoading,
    checkAuth
};
