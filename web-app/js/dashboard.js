// ========================================
// Dashboard JavaScript
// ميديا برو - نفس تصميم Flutter
// ========================================

document.addEventListener('DOMContentLoaded', function () {
    loadUserData();
    initCharts();
    initEventListeners();
});

// Load user data
function loadUserData() {
    const userData = window.authUtils.getUserData();

    if (userData) {
        const userNameElements = document.querySelectorAll('#userName, #userNameMain');
        userNameElements.forEach(element => {
            if (element) {
                const firstName = userData.name.split(' ')[0];
                element.textContent = firstName;
            }
        });
    }
}

// Initialize Charts with Neon Colors
function initCharts() {
    // Performance Chart
    const performanceCtx = document.getElementById('performanceChart');
    if (performanceCtx) {
        new Chart(performanceCtx, {
            type: 'line',
            data: {
                labels: ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'],
                datasets: [
                    {
                        label: 'الوصول',
                        data: [12000, 19000, 15000, 25000, 22000, 30000, 28000],
                        borderColor: '#00E5FF',
                        backgroundColor: 'rgba(0, 229, 255, 0.1)',
                        tension: 0.4,
                        fill: true,
                        borderWidth: 3
                    },
                    {
                        label: 'التفاعل',
                        data: [8000, 12000, 10000, 18000, 15000, 22000, 20000],
                        borderColor: '#7C4DFF',
                        backgroundColor: 'rgba(124, 77, 255, 0.1)',
                        tension: 0.4,
                        fill: true,
                        borderWidth: 3
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top',
                        align: 'end',
                        labels: {
                            usePointStyle: true,
                            padding: 15,
                            color: '#FFFFFF',
                            font: {
                                family: 'Noto Kufi Arabic',
                                size: 12,
                                weight: 600
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: '#333333',
                            borderDash: [5, 5]
                        },
                        ticks: {
                            color: '#B0B0B0',
                            font: {
                                family: 'Noto Kufi Arabic'
                            }
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        },
                        ticks: {
                            color: '#B0B0B0',
                            font: {
                                family: 'Noto Kufi Arabic'
                            }
                        }
                    }
                }
            }
        });
    }

    // Platform Distribution Chart
    const platformCtx = document.getElementById('platformChart');
    if (platformCtx) {
        new Chart(platformCtx, {
            type: 'doughnut',
            data: {
                labels: ['Facebook', 'Instagram', 'Twitter', 'LinkedIn', 'TikTok'],
                datasets: [{
                    data: [30, 25, 20, 15, 10],
                    backgroundColor: [
                        '#1877f2',
                        '#E4405F',
                        '#1DA1F2',
                        '#0A66C2',
                        '#000000'
                    ],
                    borderWidth: 0,
                    hoverOffset: 10
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            usePointStyle: true,
                            padding: 15,
                            color: '#FFFFFF',
                            font: {
                                family: 'Noto Kufi Arabic',
                                size: 12,
                                weight: 600
                            }
                        }
                    }
                }
            }
        });
    }
}

// Initialize Event Listeners
function initEventListeners() {
    // Mobile menu toggle
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    const sidebar = document.getElementById('sidebar');
    const sidebarClose = document.getElementById('sidebarClose');

    if (mobileMenuBtn && sidebar) {
        mobileMenuBtn.addEventListener('click', function () {
            sidebar.classList.toggle('active');
        });
    }

    if (sidebarClose && sidebar) {
        sidebarClose.addEventListener('click', function () {
            sidebar.classList.remove('active');
        });
    }

    // User menu dropdown
    const userMenuBtn = document.getElementById('userMenuBtn');
    const userDropdown = document.getElementById('userDropdown');

    if (userMenuBtn && userDropdown) {
        userMenuBtn.addEventListener('click', function (e) {
            e.stopPropagation();
            userDropdown.classList.toggle('active');
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', function (e) {
            if (!userMenuBtn.contains(e.target) && !userDropdown.contains(e.target)) {
                userDropdown.classList.remove('active');
            }
        });
    }

    // Close sidebar when clicking outside on mobile
    document.addEventListener('click', function (e) {
        if (sidebar &&
            !sidebar.contains(e.target) &&
            mobileMenuBtn &&
            !mobileMenuBtn.contains(e.target)) {
            sidebar.classList.remove('active');
        }
    });
}

// API Functions
async function loadDashboardStats() {
    try {
        const data = await window.authUtils.apiCall('/dashboard/stats');

        if (data && data.success) {
            updateStats(data.stats);
        }
    } catch (error) {
        console.error('Failed to load dashboard stats:', error);
    }
}

function updateStats(stats) {
    // Update stat cards with real data
    console.log('Stats loaded:', stats);
}

// Utility Functions
function formatNumber(num) {
    if (num >= 1000000) {
        return (num / 1000000).toFixed(1) + 'M';
    } else if (num >= 1000) {
        return (num / 1000).toFixed(1) + 'K';
    }
    return num.toString();
}

// Export functions
window.dashboardUtils = {
    loadDashboardStats,
    formatNumber
};
