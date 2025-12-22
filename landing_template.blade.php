<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Social Media Manager - إدارة احترافية لحساباتك على السوشال ميديا</title>
    <meta name="description" content="أداة شاملة لإدارة جميع حساباتك على وسائل التواصل الاجتماعي مع ذكاء اصطناعي متقدم">

    <!-- Favicons -->
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="48x48" href="/favicon-48x48.png">
    <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="192x192" href="/android-chrome-192x192.png">
    <link rel="icon" type="image/png" sizes="512x512" href="/android-chrome-512x512.png">

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;600;700;900&display=swap" rel="stylesheet">

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Cairo', sans-serif;
            line-height: 1.6;
            background: #0f172a;
            color: #e2e8f0;
            overflow-x: hidden;
        }

        /* Navbar */
        .navbar {
            background: rgba(15, 23, 42, 0.95);
            backdrop-filter: blur(10px);
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.3);
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
            transition: all 0.3s ease;
            border-bottom: 1px solid rgba(148, 163, 184, 0.1);
        }

        .navbar.scrolled {
            background: rgba(15, 23, 42, 0.98);
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.5);
        }

        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            font-size: 1.5rem;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-decoration: none;
        }

        .nav-links {
            display: flex;
            gap: 2rem;
            list-style: none;
            align-items: center;
        }

        .nav-links a {
            text-decoration: none;
            color: #cbd5e1;
            font-weight: 600;
            transition: all 0.3s ease;
            position: relative;
        }

        .nav-links a:hover {
            color: #667eea;
        }

        .nav-links a::after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            bottom: -5px;
            right: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            transition: width 0.3s ease;
        }

        .nav-links a:hover::after {
            width: 100%;
        }

        /* Hero Section */
        .hero {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            padding: 150px 2rem 100px;
            position: relative;
            overflow: hidden;
        }

        .hero::before {
            content: '';
            position: absolute;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(102, 126, 234, 0.1) 0%, transparent 70%);
            border-radius: 50%;
            top: -200px;
            left: -100px;
            animation: float 6s ease-in-out infinite;
        }

        .hero::after {
            content: '';
            position: absolute;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(118, 75, 162, 0.1) 0%, transparent 70%);
            border-radius: 50%;
            bottom: -150px;
            right: -100px;
            animation: float 8s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }

        .hero-container {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4rem;
            align-items: center;
            position: relative;
            z-index: 1;
        }

        .hero-content h1 {
            font-size: 3.5rem;
            font-weight: 900;
            background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 1.5rem;
            line-height: 1.2;
        }

        .hero-content p {
            font-size: 1.3rem;
            color: #94a3b8;
            margin-bottom: 2.5rem;
            line-height: 1.8;
        }

        .hero-buttons {
            display: flex;
            gap: 1.5rem;
            flex-wrap: wrap;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1rem 2.5rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 700;
            font-size: 1.1rem;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            transition: all 0.3s ease;
            display: inline-block;
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
        }

        .btn-secondary {
            background: rgba(100, 116, 139, 0.2);
            color: #e2e8f0;
            padding: 1rem 2.5rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 700;
            font-size: 1.1rem;
            border: 2px solid #475569;
            transition: all 0.3s ease;
            display: inline-block;
            backdrop-filter: blur(10px);
        }

        .btn-secondary:hover {
            background: rgba(100, 116, 139, 0.3);
            border-color: #667eea;
            transform: translateY(-3px);
        }

        .hero-image {
            position: relative;
            animation: slideIn 1s ease-out;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateX(-50px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .mockup {
            width: 100%;
            max-width: 600px;
            background: #1e293b;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
            padding: 2rem;
            position: relative;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .mockup-header {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
        }

        .mockup-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }

        .mockup-dot:nth-child(1) { background: #ff5f56; }
        .mockup-dot:nth-child(2) { background: #ffbd2e; }
        .mockup-dot:nth-child(3) { background: #27c93f; }

        .mockup-content {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            border-radius: 15px;
            padding: 2rem;
            min-height: 400px;
            display: flex;
            flex-direction: column;
            gap: 1rem;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .mockup-card {
            background: #334155;
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
            animation: fadeInUp 0.8s ease-out forwards;
            opacity: 0;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .mockup-card:nth-child(1) { animation-delay: 0.2s; }
        .mockup-card:nth-child(2) { animation-delay: 0.4s; }
        .mockup-card:nth-child(3) { animation-delay: 0.6s; }

        @keyframes fadeInUp {
            to {
                opacity: 1;
                transform: translateY(0);
            }
            from {
                opacity: 0;
                transform: translateY(20px);
            }
        }

        /* Features Section */
        .features {
            padding: 100px 2rem;
            background: #0f172a;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .section-header {
            text-align: center;
            margin-bottom: 4rem;
        }

        .section-title {
            font-size: 2.5rem;
            font-weight: 900;
            background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 1rem;
        }

        .section-subtitle {
            font-size: 1.2rem;
            color: #94a3b8;
            max-width: 600px;
            margin: 0 auto;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2.5rem;
        }

        .feature-card {
            background: #1e293b;
            padding: 2.5rem;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            transition: all 0.3s ease;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .feature-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.3);
            border-color: #667eea;
        }

        .feature-icon {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.5rem;
            font-size: 2rem;
            color: white;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }

        .feature-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #e2e8f0;
            margin-bottom: 1rem;
        }

        .feature-description {
            color: #94a3b8;
            line-height: 1.8;
        }

        /* Stats Section */
        .stats {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 80px 2rem;
            color: white;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 3rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .stat-item {
            text-align: center;
        }

        .stat-number {
            font-size: 3.5rem;
            font-weight: 900;
            margin-bottom: 0.5rem;
        }

        .stat-label {
            font-size: 1.2rem;
            opacity: 0.95;
        }

        /* CTA Section */
        .cta {
            padding: 100px 2rem;
            background: #1e293b;
            text-align: center;
        }

        .cta h2 {
            font-size: 3rem;
            font-weight: 900;
            background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 1.5rem;
        }

        .cta p {
            font-size: 1.3rem;
            color: #94a3b8;
            margin-bottom: 2.5rem;
            max-width: 700px;
            margin-left: auto;
            margin-right: auto;
        }

        /* Footer */
        .footer {
            background: #0f172a;
            color: #cbd5e1;
            padding: 60px 2rem 30px;
            border-top: 1px solid rgba(148, 163, 184, 0.1);
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 3rem;
            margin-bottom: 3rem;
        }

        .footer-section h3 {
            font-size: 1.3rem;
            margin-bottom: 1.5rem;
            color: #e2e8f0;
        }

        .footer-links {
            list-style: none;
        }

        .footer-links li {
            margin-bottom: 0.8rem;
        }

        .footer-links a {
            color: #94a3b8;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .footer-links a:hover {
            color: #667eea;
        }

        .footer-bottom {
            border-top: 1px solid rgba(148, 163, 184, 0.1);
            padding-top: 2rem;
            text-align: center;
            color: #64748b;
        }

        /* Mobile Menu */
        .mobile-menu-btn {
            display: none;
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #cbd5e1;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .hero-container {
                grid-template-columns: 1fr;
                text-align: center;
            }

            .hero-content h1 {
                font-size: 2.5rem;
            }

            .hero-image {
                order: -1;
            }

            .nav-links {
                display: none;
            }

            .mobile-menu-btn {
                display: block;
            }

            .features-grid {
                grid-template-columns: 1fr;
            }

            .hero-buttons {
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar" id="navbar">
        <div class="nav-container">
            <a href="/" class="logo">
                <img src="/logo.png" alt="Social Media Manager" style="height: 50px; width: 50px; border-radius: 50%; object-fit: cover; border: 2px solid rgba(102, 126, 234, 0.3);">
            </a>

            <ul class="nav-links">
                <li><a href="#features">الميزات</a></li>
                <li><a href="#pricing">الأسعار</a></li>
                <li><a href="/about">من نحن</a></li>
                <li><a href="/contact">اتصل بنا</a></li>
            </ul>

            <button class="mobile-menu-btn">
                <i class="fas fa-bars"></i>
            </button>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-container">
            <div class="hero-content">
                <h1>أدِر جميع حساباتك على السوشال ميديا من مكان واحد 🚀</h1>
                <p>وفّر الوقت والجهد مع أداة شاملة تجمع التخطيط، النشر، التحليل، والذكاء الاصطناعي في منصة واحدة سهلة الاستخدام</p>

                <div class="hero-buttons">
                    <a href="#features" class="btn-primary">
                        <i class="fas fa-rocket"></i> اكتشف المزيد
                    </a>
                    <a href="#pricing" class="btn-secondary">
                        <i class="fas fa-play-circle"></i> شاهد العرض التوضيحي
                    </a>
                </div>
            </div>

            <div class="hero-image">
                <div class="mockup">
                    <div class="mockup-header">
                        <div class="mockup-dot"></div>
                        <div class="mockup-dot"></div>
                        <div class="mockup-dot"></div>
                    </div>

                    <div class="mockup-content">
                        <div class="mockup-card">
                            <h4 style="color: #667eea; margin-bottom: 0.5rem;">
                                <i class="fas fa-calendar-check"></i> منشور مجدول
                            </h4>
                            <p style="color: #94a3b8; font-size: 0.9rem;">سيتم النشر على Facebook, Instagram, Twitter</p>
                        </div>

                        <div class="mockup-card">
                            <h4 style="color: #667eea; margin-bottom: 0.5rem;">
                                <i class="fas fa-robot"></i> محتوى AI
                            </h4>
                            <p style="color: #94a3b8; font-size: 0.9rem;">تم إنشاء 15 منشور تلقائياً باستخدام AI</p>
                        </div>

                        <div class="mockup-card">
                            <h4 style="color: #667eea; margin-bottom: 0.5rem;">
                                <i class="fas fa-chart-line"></i> تحليلات
                            </h4>
                            <p style="color: #94a3b8; font-size: 0.9rem;">زيادة 45% في التفاعل هذا الشهر</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features" id="features">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">كل ما تحتاجه في أداة واحدة 💎</h2>
                <p class="section-subtitle">ميزات متقدمة تساعدك على إدارة حساباتك باحترافية وكفاءة</p>
            </div>

            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-brain"></i>
                    </div>
                    <h3 class="feature-title">ذكاء اصطناعي متقدم</h3>
                    <p class="feature-description">استخدم AI لإنشاء محتوى إبداعي، تصميم صور، كتابة نصوص، وتحليل أداء منشوراتك تلقائياً</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-calendar-alt"></i>
                    </div>
                    <h3 class="feature-title">جدولة ذكية</h3>
                    <p class="feature-description">جدول منشوراتك مسبقاً على جميع المنصات واختر أفضل الأوقات للنشر بناءً على تفاعل جمهورك</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-chart-pie"></i>
                    </div>
                    <h3 class="feature-title">تحليلات شاملة</h3>
                    <p class="feature-description">احصل على تقارير مفصلة عن أداء حساباتك مع رؤى عميقة لتحسين استراتيجيتك</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-share-nodes"></i>
                    </div>
                    <h3 class="feature-title">نشر متعدد المنصات</h3>
                    <p class="feature-description">انشر على Facebook, Instagram, Twitter, LinkedIn, TikTok من مكان واحد بضغطة زر</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-palette"></i>
                    </div>
                    <h3 class="feature-title">Brand Kit</h3>
                    <p class="feature-description">احفظ ألوان علامتك التجارية، خطوطها، ونبرة صوتها لاستخدامها في جميع منشوراتك</p>
                </div>

                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3 class="feature-title">إدارة الفريق</h3>
                    <p class="feature-description">تعاون مع فريقك، حدد الصلاحيات، وراجع المحتوى قبل النشر</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Section -->
    <section class="stats">
        <div class="stats-grid">
            <div class="stat-item">
                <div class="stat-number">50K+</div>
                <div class="stat-label">مستخدم نشط</div>
            </div>

            <div class="stat-item">
                <div class="stat-number">2M+</div>
                <div class="stat-label">منشور تم جدولته</div>
            </div>

            <div class="stat-item">
                <div class="stat-number">15+</div>
                <div class="stat-label">منصة متكاملة</div>
            </div>

            <div class="stat-item">
                <div class="stat-number">99.9%</div>
                <div class="stat-label">نسبة التشغيل</div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta" id="pricing">
        <div class="container">
            <h2>ابدأ رحلتك نحو النجاح اليوم 🎯</h2>
            <p>انضم لآلاف المستخدمين الذين يديرون حساباتهم باحترافية</p>

            <div class="hero-buttons" style="justify-content: center;">
                <a href="/pricing" class="btn-primary" style="font-size: 1.2rem; padding: 1.2rem 3rem;">
                    <i class="fas fa-tag"></i> شاهد الأسعار
                </a>
                <a href="/contact" class="btn-secondary" style="font-size: 1.2rem; padding: 1.2rem 3rem;">
                    <i class="fas fa-envelope"></i> تواصل معنا
                </a>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="footer-content">
            <div class="footer-section">
                <img src="/logo.png" alt="Social Media Manager" style="height: 60px; width: 60px; border-radius: 50%; object-fit: cover; margin-bottom: 1rem; border: 2px solid rgba(102, 126, 234, 0.3);">
                <p style="color: #94a3b8; line-height: 1.8;">
                    أداة شاملة لإدارة جميع حساباتك على وسائل التواصل الاجتماعي بكفاءة واحترافية
                </p>
            </div>

            <div class="footer-section">
                <h3>الروابط السريعة</h3>
                <ul class="footer-links">
                    <li><a href="/about">من نحن</a></li>
                    <li><a href="/pricing">الأسعار</a></li>
                    <li><a href="/contact">اتصل بنا</a></li>
                </ul>
            </div>

            <div class="footer-section">
                <h3>الدعم</h3>
                <ul class="footer-links">
                    <li><a href="/privacy-policy">سياسة الخصوصية</a></li>
                    <li><a href="/terms-of-service">شروط الاستخدام</a></li>
                    <li><a href="/contact">المساعدة والدعم</a></li>
                </ul>
            </div>

            <div class="footer-section">
                <h3>تابعنا</h3>
                <div style="display: flex; gap: 1rem; font-size: 1.5rem; margin-bottom: 1.5rem;">
                    <a href="#" style="color: #94a3b8; transition: color 0.3s;" onmouseover="this.style.color='#667eea'" onmouseout="this.style.color='#94a3b8'">
                        <i class="fab fa-facebook"></i>
                    </a>
                    <a href="#" style="color: #94a3b8; transition: color 0.3s;" onmouseover="this.style.color='#667eea'" onmouseout="this.style.color='#94a3b8'">
                        <i class="fab fa-twitter"></i>
                    </a>
                    <a href="#" style="color: #94a3b8; transition: color 0.3s;" onmouseover="this.style.color='#667eea'" onmouseout="this.style.color='#94a3b8'">
                        <i class="fab fa-instagram"></i>
                    </a>
                    <a href="#" style="color: #94a3b8; transition: color 0.3s;" onmouseover="this.style.color='#667eea'" onmouseout="this.style.color='#94a3b8'">
                        <i class="fab fa-linkedin"></i>
                    </a>
                </div>
                <a href="https://mediaprosocial.io/webapp/" target="_blank" style="display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.75rem 1.5rem; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 8px; text-decoration: none; font-weight: 600; transition: all 0.3s; box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 6px 20px rgba(102, 126, 234, 0.6)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 15px rgba(102, 126, 234, 0.4)'">
                    <i class="fas fa-rocket"></i>
                    افتح تطبيق الويب
                </a>
            </div>
        </div>

        <div class="footer-bottom">
            <p>&copy; 2025 Social Media Manager. جميع الحقوق محفوظة.</p>
        </div>
    </footer>

    <script>
        // Navbar scroll effect
        window.addEventListener('scroll', function() {
            const navbar = document.getElementById('navbar');
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });

        // Smooth scrolling
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
    </script>
</body>
</html>
