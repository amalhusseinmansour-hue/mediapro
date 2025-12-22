// Wait for DOM to load
document.addEventListener('DOMContentLoaded', function() {
    // Configuration
    const config = {
        apkUrl: './app-release.apk', // ضع رابط ملف APK هنا
        apkFileName: 'SocialMediaManager_v1.0.apk',
        ipaUrl: './app-release.ipa', // ضع رابط ملف IPA هنا
        ipaFileName: 'SocialMediaManager_v1.0.ipa',
        fallbackSize: '~50 MB'
    };

    // Elements
    const downloadBtnAndroid = document.getElementById('downloadAndroid');
    const downloadBtnIOS = document.getElementById('downloadIOS');
    const apkSizeElement = document.getElementById('apkSize');

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Download button handlers
    if (downloadBtnAndroid) {
        downloadBtnAndroid.addEventListener('click', async function(e) {
            e.preventDefault();
            await handleDownload('android');
        });
    }

    if (downloadBtnIOS) {
        downloadBtnIOS.addEventListener('click', async function(e) {
            e.preventDefault();
            await handleDownload('ios');
        });
    }

    // Get APK file size
    async function getAPKSize() {
        try {
            const response = await fetch(config.apkUrl, { method: 'HEAD' });
            if (response.ok) {
                const size = response.headers.get('content-length');
                if (size) {
                    const sizeMB = (parseInt(size) / (1024 * 1024)).toFixed(2);
                    return `${sizeMB} MB`;
                }
            }
        } catch (error) {
            console.log('Could not fetch APK size:', error);
        }
        return config.fallbackSize;
    }

    // Update APK size on page load
    getAPKSize().then(size => {
        if (apkSizeElement) {
            apkSizeElement.textContent = size;
        }
    });

    // Handle download
    async function handleDownload(platform = 'android') {
        // Show download progress
        showDownloadProgress(platform);

        try {
            // Create download link
            const link = document.createElement('a');

            if (platform === 'ios') {
                link.href = config.ipaUrl;
                link.download = config.ipaFileName;
            } else {
                link.href = config.apkUrl;
                link.download = config.apkFileName;
            }

            // Trigger download
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            // Simulate progress (since we can't track actual download progress in browser)
            simulateProgress(platform);

            // Show success notification
            setTimeout(() => {
                const platformName = platform === 'ios' ? 'iOS' : 'Android';
                showNotification(`تم بدء تحميل نسخة ${platformName}!`, 'success');
            }, 500);

        } catch (error) {
            console.error('Download error:', error);
            showNotification('حدث خطأ في التحميل. الرجاء المحاولة مرة أخرى.', 'error');
            hideDownloadProgress();
        }
    }

    // Show download progress
    function showDownloadProgress(platform = 'android') {
        let progressContainer = document.querySelector('.download-progress');

        const platformName = platform === 'ios' ? 'iOS' : 'Android';
        const icon = platform === 'ios' ? '🍎' : '🤖';

        if (!progressContainer) {
            progressContainer = document.createElement('div');
            progressContainer.className = 'download-progress';
            progressContainer.innerHTML = `
                <div class="progress-header">
                    <div class="progress-icon">${icon}</div>
                    <div class="progress-text">
                        <h4>جاري تحميل نسخة ${platformName}...</h4>
                        <p id="progress-status">جاري التحضير...</p>
                    </div>
                </div>
                <div class="progress-bar-container">
                    <div class="progress-bar" id="progress-bar"></div>
                </div>
            `;
            document.body.appendChild(progressContainer);
        } else {
            // Update existing progress
            const iconEl = progressContainer.querySelector('.progress-icon');
            const titleEl = progressContainer.querySelector('h4');
            if (iconEl) iconEl.textContent = icon;
            if (titleEl) titleEl.textContent = `جاري تحميل نسخة ${platformName}...`;
        }

        // Show with animation
        setTimeout(() => {
            progressContainer.classList.add('active');
        }, 100);
    }

    // Simulate progress
    function simulateProgress(platform = 'android') {
        const progressBar = document.getElementById('progress-bar');
        const progressStatus = document.getElementById('progress-status');

        if (!progressBar || !progressStatus) return;

        let progress = 0;
        const interval = setInterval(() => {
            progress += Math.random() * 15;
            if (progress > 100) progress = 100;

            progressBar.style.width = progress + '%';

            if (progress < 30) {
                progressStatus.textContent = 'جاري الاتصال بالخادم...';
            } else if (progress < 60) {
                progressStatus.textContent = 'جاري التحميل...';
            } else if (progress < 90) {
                progressStatus.textContent = 'اكتمل التحميل تقريباً...';
            } else {
                progressStatus.textContent = 'تم التحميل بنجاح!';
                clearInterval(interval);

                // Hide progress after completion
                setTimeout(() => {
                    hideDownloadProgress();
                }, 2000);
            }
        }, 300);
    }

    // Hide download progress
    function hideDownloadProgress() {
        const progressContainer = document.querySelector('.download-progress');
        if (progressContainer) {
            progressContainer.classList.remove('active');
            setTimeout(() => {
                progressContainer.remove();
            }, 300);
        }
    }

    // Show notification
    function showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'success' ? '#34C759' : type === 'error' ? '#FF3B30' : '#667eea'};
            color: white;
            padding: 20px 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            z-index: 10000;
            animation: slideIn 0.3s ease;
            max-width: 400px;
            font-size: 1rem;
            font-weight: 600;
        `;
        notification.textContent = message;

        // Add animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideIn {
                from {
                    transform: translateX(100%);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }
            @keyframes slideOut {
                from {
                    transform: translateX(0);
                    opacity: 1;
                }
                to {
                    transform: translateX(100%);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);

        document.body.appendChild(notification);

        // Auto remove after 3 seconds
        setTimeout(() => {
            notification.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => {
                notification.remove();
            }, 300);
        }, 3000);
    }

    // FAQ Accordion functionality
    const faqItems = document.querySelectorAll('.faq-item');
    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        const answer = item.querySelector('.faq-answer');

        // Initially hide all answers except first
        if (item !== faqItems[0]) {
            answer.style.display = 'none';
        }

        question.addEventListener('click', () => {
            const isOpen = answer.style.display !== 'none';

            // Close all other items
            faqItems.forEach(otherItem => {
                const otherAnswer = otherItem.querySelector('.faq-answer');
                otherAnswer.style.display = 'none';
            });

            // Toggle current item
            answer.style.display = isOpen ? 'none' : 'block';
        });
    });

    // Scroll animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe all sections
    const sections = document.querySelectorAll('.feature-card, .platform-card, .step, .faq-item');
    sections.forEach(section => {
        section.style.opacity = '0';
        section.style.transform = 'translateY(30px)';
        section.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(section);
    });

    // Add floating particles effect
    function createParticles() {
        const particlesContainer = document.createElement('div');
        particlesContainer.className = 'particles-container';
        particlesContainer.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: -1;
            overflow: hidden;
        `;

        for (let i = 0; i < 20; i++) {
            const particle = document.createElement('div');
            particle.className = 'particle';
            particle.style.cssText = `
                position: absolute;
                width: ${Math.random() * 5 + 2}px;
                height: ${Math.random() * 5 + 2}px;
                background: rgba(255, 255, 255, 0.5);
                border-radius: 50%;
                top: ${Math.random() * 100}%;
                left: ${Math.random() * 100}%;
                animation: float ${Math.random() * 10 + 10}s linear infinite;
                animation-delay: ${Math.random() * 5}s;
            `;
            particlesContainer.appendChild(particle);
        }

        // Add float animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes float {
                0% {
                    transform: translateY(0) translateX(0);
                    opacity: 0;
                }
                10% {
                    opacity: 1;
                }
                90% {
                    opacity: 1;
                }
                100% {
                    transform: translateY(-100vh) translateX(${Math.random() * 200 - 100}px);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);
        document.body.appendChild(particlesContainer);
    }

    createParticles();

    // Track page analytics (optional)
    function trackEvent(eventName, eventData = {}) {
        // يمكنك إضافة Google Analytics أو أي أداة تحليل هنا
        console.log('Event:', eventName, eventData);
    }

    // Track download attempts
    if (downloadBtnAndroid) {
        downloadBtnAndroid.addEventListener('click', () => {
            trackEvent('download_click', {
                platform: 'Android',
                version: '1.0.0'
            });
        });
    }

    if (downloadBtnIOS) {
        downloadBtnIOS.addEventListener('click', () => {
            trackEvent('download_click', {
                platform: 'iOS',
                version: '1.0.0'
            });
        });
    }

    // Track page views
    trackEvent('page_view', {
        page: 'download_page',
        timestamp: new Date().toISOString()
    });
});
