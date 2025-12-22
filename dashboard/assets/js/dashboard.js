// ========================================
// Dashboard JavaScript
// ========================================

// Load user data
document.addEventListener('DOMContentLoaded', function () {
    loadUserData();
    initCharts();
    initEventListeners();
});

// Load and display user data
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

// Initialize Charts
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
                        borderColor: '#0277d4',
                        backgroundColor: 'rgba(2, 119, 212, 0.1)',
                        tension: 0.4,
                        fill: true
                    },
                    {
                        label: 'التفاعل',
                        data: [8000, 12000, 10000, 18000, 15000, 22000, 20000],
                        borderColor: '#6c63ff',
                        backgroundColor: 'rgba(108, 99, 255, 0.1)',
                        tension: 0.4,
                        fill: true
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
                            font: {
                                family: 'IBM Plex Sans Arabic',
                                size: 12
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            borderDash: [5, 5]
                        },
                        ticks: {
                            font: {
                                family: 'IBM Plex Sans Arabic'
                            }
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        },
                        ticks: {
                            font: {
                                family: 'IBM Plex Sans Arabic'
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
                        '#e4405f',
                        '#1da1f2',
                        '#0077b5',
                        '#000000'
                    ],
                    borderWidth: 0
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
                            font: {
                                family: 'IBM Plex Sans Arabic',
                                size: 12
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
    // Mobile toggle
    const mobileToggle = document.getElementById('mobileToggle');
    const sidebar = document.getElementById('sidebar');
    const sidebarToggle = document.getElementById('sidebarToggle');

    if (mobileToggle && sidebar) {
        mobileToggle.addEventListener('click', function () {
            sidebar.classList.toggle('active');
        });
    }

    if (sidebarToggle && sidebar) {
        sidebarToggle.addEventListener('click', function () {
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
        if (sidebar && !sidebar.contains(e.target) && !mobileToggle.contains(e.target)) {
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
    // This is a placeholder - implement based on your API response structure
    console.log('Stats loaded:', stats);
}

async function loadScheduledPosts() {
    try {
        const data = await window.authUtils.apiCall('/posts/scheduled');

        if (data && data.success) {
            renderScheduledPosts(data.posts);
        }
    } catch (error) {
        console.error('Failed to load scheduled posts:', error);
    }
}

function renderScheduledPosts(posts) {
    // Render posts list
    // This is a placeholder - implement based on your needs
    console.log('Posts loaded:', posts);
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

function formatDate(date) {
    const options = {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    };
    return new Date(date).toLocaleDateString('ar', options);
}

// Export functions for use in other files
window.dashboardUtils = {
    loadDashboardStats,
    loadScheduledPosts,
    formatNumber,
    formatDate
};
