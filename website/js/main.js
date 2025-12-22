// ===========================
// FAQ Accordion
// ===========================
document.addEventListener('DOMContentLoaded', function() {
    const faqItems = document.querySelectorAll('.faq-item');

    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');

        question.addEventListener('click', () => {
            // Close all other items
            faqItems.forEach(otherItem => {
                if (otherItem !== item) {
                    otherItem.classList.remove('active');
                }
            });

            // Toggle current item
            item.classList.toggle('active');
        });
    });
});

// ===========================
// Smooth Scrolling for Navigation
// ===========================
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

// ===========================
// Header Scroll Effect
// ===========================
let lastScroll = 0;
const header = document.querySelector('.header');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll > 100) {
        header.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.1)';
    } else {
        header.style.boxShadow = '0 1px 2px 0 rgba(0, 0, 0, 0.05)';
    }

    lastScroll = currentScroll;
});

// ===========================
// Mobile Menu Toggle
// ===========================
const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
const navMenu = document.querySelector('.nav-menu');
const navActions = document.querySelector('.nav-actions');

if (mobileMenuToggle) {
    mobileMenuToggle.addEventListener('click', () => {
        navMenu.classList.toggle('active');
        navActions.classList.toggle('active');

        const icon = mobileMenuToggle.querySelector('i');
        if (icon.classList.contains('fa-bars')) {
            icon.classList.remove('fa-bars');
            icon.classList.add('fa-times');
        } else {
            icon.classList.remove('fa-times');
            icon.classList.add('fa-bars');
        }
    });
}

// ===========================
// Animate on Scroll
// ===========================
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe all feature cards
document.querySelectorAll('.feature-card, .pricing-card, .testimonial-card').forEach(card => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';
    card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(card);
});

// ===========================
// Dashboard Mockup Animation
// ===========================
const previewCards = document.querySelectorAll('.preview-card');

previewCards.forEach((card, index) => {
    card.style.opacity = '0';
    card.style.transform = 'scale(0.9)';
    card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';

    setTimeout(() => {
        card.style.opacity = '1';
        card.style.transform = 'scale(1)';
    }, 500 + (index * 150));
});

// ===========================
// Stats Counter Animation
// ===========================
function animateCounter(element, target, duration = 2000) {
    let current = 0;
    const increment = target / (duration / 16);

    const updateCounter = () => {
        current += increment;

        if (current < target) {
            element.textContent = Math.floor(current).toLocaleString('ar-EG');
            requestAnimationFrame(updateCounter);
        } else {
            element.textContent = target.toLocaleString('ar-EG');
        }
    };

    updateCounter();
}

// Observe stats section
const statsSection = document.querySelector('.hero-stats');
if (statsSection) {
    const statsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const stats = [
                    { element: document.querySelectorAll('.stat-number')[0], value: 10000 },
                    { element: document.querySelectorAll('.stat-number')[1], value: 1000000 },
                    { element: document.querySelectorAll('.stat-number')[2], value: 98 }
                ];

                stats.forEach(stat => {
                    if (stat.element) {
                        const originalText = stat.element.textContent;
                        stat.element.textContent = '0';

                        setTimeout(() => {
                            if (originalText.includes('+')) {
                                animateCounter(stat.element, stat.value);
                                stat.element.textContent = stat.element.textContent + '+';
                            } else if (originalText.includes('%')) {
                                animateCounter(stat.element, stat.value);
                                stat.element.textContent = stat.element.textContent + '%';
                            } else {
                                animateCounter(stat.element, stat.value);
                            }
                        }, 300);
                    }
                });

                statsObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    statsObserver.observe(statsSection);
}

// ===========================
// Form Validation (if forms are added)
// ===========================
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

// ===========================
// Scroll to Top Button (Optional)
// ===========================
const scrollToTopBtn = document.createElement('button');
scrollToTopBtn.innerHTML = '<i class="fas fa-arrow-up"></i>';
scrollToTopBtn.className = 'scroll-to-top';
scrollToTopBtn.style.cssText = `
    position: fixed;
    bottom: 30px;
    left: 30px;
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background: linear-gradient(135deg, #3a6ef2 0%, #8b5cf6 100%);
    color: white;
    border: none;
    cursor: pointer;
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s ease;
    z-index: 1000;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
`;

document.body.appendChild(scrollToTopBtn);

window.addEventListener('scroll', () => {
    if (window.pageYOffset > 300) {
        scrollToTopBtn.style.opacity = '1';
        scrollToTopBtn.style.visibility = 'visible';
    } else {
        scrollToTopBtn.style.opacity = '0';
        scrollToTopBtn.style.visibility = 'hidden';
    }
});

scrollToTopBtn.addEventListener('click', () => {
    window.scrollTo({
        top: 0,
        behavior: 'smooth'
    });
});

// ===========================
// Lazy Loading Images (if images are added)
// ===========================
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.remove('lazy');
                imageObserver.unobserve(img);
            }
        });
    });

    document.querySelectorAll('img.lazy').forEach(img => {
        imageObserver.observe(img);
    });
}

// ===========================
// Testimonials Slider (Simple Auto-rotate)
// ===========================
const testimonialsGrid = document.querySelector('.testimonials-grid');
if (testimonialsGrid) {
    let currentTestimonial = 0;
    const testimonials = document.querySelectorAll('.testimonial-card');

    // This is a simple example - can be enhanced with a proper carousel library
    setInterval(() => {
        if (window.innerWidth <= 768) {
            testimonials.forEach((card, index) => {
                card.style.display = index === currentTestimonial ? 'block' : 'none';
            });
            currentTestimonial = (currentTestimonial + 1) % testimonials.length;
        } else {
            testimonials.forEach(card => card.style.display = 'block');
        }
    }, 5000);
}

// ===========================
// Partners Logo Animation
// ===========================
const partnersGrid = document.querySelector('.partners-grid');
if (partnersGrid) {
    const logos = partnersGrid.querySelectorAll('.partner-logo');
    logos.forEach((logo, index) => {
        logo.style.opacity = '0';
        logo.style.transform = 'scale(0.8)';
        logo.style.transition = 'all 0.4s ease';

        setTimeout(() => {
            logo.style.opacity = '1';
            logo.style.transform = 'scale(1)';
        }, 100 * index);
    });
}

// ===========================
// CTA Buttons Click Handlers
// ===========================
document.querySelectorAll('.btn-primary, .btn-white').forEach(btn => {
    btn.addEventListener('click', function() {
        // Add ripple effect
        const ripple = document.createElement('span');
        ripple.style.cssText = `
            position: absolute;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.5);
            transform: scale(0);
            animation: ripple 0.6s ease-out;
        `;

        this.style.position = 'relative';
        this.style.overflow = 'hidden';
        this.appendChild(ripple);

        setTimeout(() => ripple.remove(), 600);
    });
});

// Add ripple animation
const style = document.createElement('style');
style.textContent = `
    @keyframes ripple {
        to {
            transform: scale(20);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// ===========================
// Console Welcome Message
// ===========================
console.log('%c ميديا برو ', 'background: linear-gradient(135deg, #3a6ef2 0%, #8b5cf6 100%); color: white; font-size: 20px; padding: 10px 20px; border-radius: 5px;');
console.log('%c منصة إدارة وسائل التواصل الاجتماعي الذكية ', 'color: #3a6ef2; font-size: 14px;');
console.log('%c https://mediapro.com ', 'color: #6b7280; font-size: 12px;');
