// ========================================
// Authentication JavaScript
// ========================================

// Configuration
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

        // Hide after 5 seconds
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

            // Validation
            if (!email || !password) {
                showError('الرجاء إدخال البريد الإلكتروني وكلمة المرور');
                return;
            }

            // Email validation
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                showError('الرجاء إدخال بريد إلكتروني صحيح');
                return;
            }

            showLoading(true);

            try {
                // Call API
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
                    // Store authentication data
                    localStorage.setItem('auth_token', data.token);
                    localStorage.setItem('user_data', JSON.stringify(data.user));

                    if (remember) {
                        localStorage.setItem('remember_me', 'true');
                    }

                    showSuccess('تم تسجيل الدخول بنجاح! جاري التحويل...');

                    // Redirect to dashboard
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

            // Validation
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
                    // Store authentication data
                    localStorage.setItem('auth_token', data.token);
                    localStorage.setItem('user_data', JSON.stringify(data.user));

                    showSuccess('تم إنشاء الحساب بنجاح! جاري التحويل...');

                    // Redirect to dashboard
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

// Forgot Password Handler
document.addEventListener('DOMContentLoaded', function () {
    const forgotForm = document.getElementById('forgotForm');

    if (forgotForm) {
        forgotForm.addEventListener('submit', async function (e) {
            e.preventDefault();

            const email = document.getElementById('email').value;

            if (!email) {
                showError('الرجاء إدخال البريد الإلكتروني');
                return;
            }

            showLoading(true);

            try {
                const response = await fetch(`${API_URL}/forgot-password`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                    },
                    body: JSON.stringify({ email: email })
                });

                const data = await response.json();

                if (response.ok) {
                    showSuccess('تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني');

                    setTimeout(() => {
                        window.location.href = 'login.html';
                    }, 3000);
                } else {
                    showError(data.message || 'فشل إرسال البريد. الرجاء المحاولة مرة أخرى');
                }
            } catch (error) {
                console.error('Forgot password error:', error);
                showError('حدث خطأ في الاتصال. الرجاء المحاولة مرة أخرى');
            } finally {
                showLoading(false);
            }
        });
    }
});

// Social Login Handlers
document.addEventListener('DOMContentLoaded', function () {
    // Google Login
    const googleBtn = document.querySelector('.google-btn');
    if (googleBtn) {
        googleBtn.addEventListener('click', function () {
            window.location.href = `${API_URL}/auth/google`;
        });
    }

    // Facebook Login
    const facebookBtn = document.querySelector('.facebook-btn');
    if (facebookBtn) {
        facebookBtn.addEventListener('click', function () {
            window.location.href = `${API_URL}/auth/facebook`;
        });
    }
});

// Check if user is already logged in
function checkAuth() {
    const token = localStorage.getItem('auth_token');
    const currentPage = window.location.pathname;

    if (token && (currentPage.includes('login') || currentPage.includes('register'))) {
        // User is logged in but on auth page, redirect to dashboard
        window.location.href = 'index.html';
    } else if (!token && !currentPage.includes('login') && !currentPage.includes('register') && !currentPage.includes('forgot-password')) {
        // User is not logged in but trying to access protected page
        window.location.href = 'login.html';
    }
}

// Check auth on page load (except for auth pages)
if (!window.location.pathname.includes('login') &&
    !window.location.pathname.includes('register') &&
    !window.location.pathname.includes('forgot-password')) {
    window.addEventListener('DOMContentLoaded', checkAuth);
}

// Logout function
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

        // Check if unauthorized
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

// Export functions for use in other files
window.authUtils = {
    logout,
    getUserData,
    getAuthToken,
    apiCall,
    showError,
    showSuccess,
    showLoading
};
