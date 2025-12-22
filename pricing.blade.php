<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>الأسعار - Social Media Manager</title>
    <meta name="description" content="اختر الخطة المناسبة لك - أسعار تنافسية وخطط مرنة لإدارة حساباتك على السوشال ميديا">

    <!-- Favicons -->
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
    <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">

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
            border-bottom: 1px solid rgba(148, 163, 184, 0.1);
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
            text-decoration: none;
            display: flex;
            align-items: center;
        }

        .logo img {
            height: 50px;
            width: 50px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid rgba(102, 126, 234, 0.3);
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
        }

        .nav-links a:hover {
            color: #667eea;
        }

        .cta-button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            border: none;
        }

        .cta-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }

        /* Main Content */
        .content {
            max-width: 1400px;
            margin: 120px auto 60px;
            padding: 2rem;
        }

        .page-header {
            text-align: center;
            margin-bottom: 60px;
        }

        .page-header h1 {
            font-size: 3rem;
            font-weight: 900;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 1rem;
        }

        .page-header p {
            font-size: 1.2rem;
            color: #94a3b8;
        }

        /* Pricing Cards */
        .pricing-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 3rem;
        }

        .pricing-card {
            background: rgba(30, 41, 59, 0.5);
            border-radius: 20px;
            padding: 3rem 2rem;
            border: 2px solid rgba(148, 163, 184, 0.1);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .pricing-card:hover {
            transform: translateY(-10px);
            border-color: #667eea;
            box-shadow: 0 20px 60px rgba(102, 126, 234, 0.3);
        }

        .pricing-card.featured {
            border-color: #667eea;
            background: rgba(102, 126, 234, 0.1);
        }

        .pricing-card.featured::before {
            content: 'الأكثر شعبية';
            position: absolute;
            top: 20px;
            right: -30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 0.5rem 3rem;
            transform: rotate(-45deg);
            font-size: 0.8rem;
            font-weight: 700;
        }

        .plan-name {
            font-size: 1.8rem;
            font-weight: 700;
            color: #e2e8f0;
            margin-bottom: 0.5rem;
        }

        .plan-name-en {
            font-size: 1rem;
            color: #94a3b8;
            margin-bottom: 1.5rem;
        }

        .plan-price {
            font-size: 3rem;
            font-weight: 900;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 0.5rem;
        }

        .plan-price span {
            font-size: 1.2rem;
            color: #94a3b8;
        }

        .plan-duration {
            color: #94a3b8;
            margin-bottom: 2rem;
            font-size: 1rem;
        }

        .plan-features {
            list-style: none;
            margin-bottom: 2rem;
        }

        .plan-features li {
            padding: 0.75rem 0;
            border-bottom: 1px solid rgba(148, 163, 184, 0.1);
            color: #cbd5e1;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .plan-features li:last-child {
            border-bottom: none;
        }

        .plan-features li i {
            color: #667eea;
            font-size: 1.2rem;
        }

        .plan-button {
            width: 100%;
            padding: 1rem;
            border: none;
            border-radius: 10px;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            font-family: 'Cairo', sans-serif;
        }

        .plan-button.primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .plan-button.primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }

        .plan-button.secondary {
            background: transparent;
            border: 2px solid #667eea;
            color: #667eea;
        }

        .plan-button.secondary:hover {
            background: rgba(102, 126, 234, 0.1);
        }

        /* FAQ Section */
        .faq-section {
            max-width: 800px;
            margin: 4rem auto 0;
        }

        .faq-section h2 {
            text-align: center;
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 2rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .faq-item {
            background: rgba(30, 41, 59, 0.5);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .faq-item h3 {
            color: #667eea;
            font-size: 1.2rem;
            margin-bottom: 0.5rem;
        }

        .faq-item p {
            color: #cbd5e1;
            line-height: 1.8;
        }

        /* Footer */
        footer {
            background: rgba(15, 23, 42, 0.95);
            padding: 3rem 2rem 1rem;
            text-align: center;
            border-top: 1px solid rgba(148, 163, 184, 0.1);
            margin-top: 4rem;
        }

        .footer-links {
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
        }

        .footer-links a {
            color: #cbd5e1;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .footer-links a:hover {
            color: #667eea;
        }

        .social-icons {
            display: flex;
            justify-content: center;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .social-icons a {
            color: #cbd5e1;
            font-size: 1.5rem;
            transition: all 0.3s ease;
        }

        .social-icons a:hover {
            color: #667eea;
            transform: translateY(-3px);
        }

        .copyright {
            color: #64748b;
            font-size: 0.9rem;
        }

        @media (max-width: 768px) {
            .nav-links {
                display: none;
            }

            .page-header h1 {
                font-size: 2rem;
            }

            .pricing-grid {
                grid-template-columns: 1fr;
            }

            .pricing-card {
                padding: 2rem 1.5rem;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar">
        <div class="nav-container">
            <a href="/" class="logo">
                <img src="/logo.png" alt="Social Media Manager">
            </a>
            <ul class="nav-links">
                <li><a href="/">الرئيسية</a></li>
                <li><a href="/about">من نحن</a></li>
                <li><a href="/pricing">الأسعار</a></li>
                <li><a href="/webapp" class="cta-button">افتح تطبيق الويب</a></li>
            </ul>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="content">
        <div class="page-header">
            <h1>الأسعار</h1>
            <p>اختر الخطة المناسبة لاحتياجاتك</p>
        </div>

        <!-- Pricing Cards -->
        <div class="pricing-grid">
            <!-- Free Plan -->
            <div class="pricing-card">
                <h2 class="plan-name">مجاني</h2>
                <p class="plan-name-en">Free</p>
                <div class="plan-price">$0<span>/شهرياً</span></div>
                <p class="plan-duration">للأفراد والمبتدئين</p>
                <ul class="plan-features">
                    <li><i class="fas fa-check-circle"></i> 5 حسابات سوشيال ميديا</li>
                    <li><i class="fas fa-check-circle"></i> 10 منشورات شهرياً</li>
                    <li><i class="fas fa-check-circle"></i> دعم أساسي</li>
                    <li><i class="fas fa-check-circle"></i> تحليلات بسيطة</li>
                </ul>
                <button class="plan-button secondary" onclick="window.location.href='/webapp'">ابدأ مجاناً</button>
            </div>

            <!-- Pro Plan (Featured) -->
            <div class="pricing-card featured">
                <h2 class="plan-name">احترافي</h2>
                <p class="plan-name-en">Pro</p>
                <div class="plan-price">$15<span>/شهرياً</span></div>
                <p class="plan-duration">للمحترفين والشركات الصغيرة</p>
                <ul class="plan-features">
                    <li><i class="fas fa-check-circle"></i> حسابات غير محدودة</li>
                    <li><i class="fas fa-check-circle"></i> منشورات غير محدودة</li>
                    <li><i class="fas fa-check-circle"></i> AI Tools متقدمة</li>
                    <li><i class="fas fa-check-circle"></i> 60 فيديو AI شهرياً</li>
                    <li><i class="fas fa-check-circle"></i> 500 صورة AI شهرياً</li>
                    <li><i class="fas fa-check-circle"></i> دعم أولوية</li>
                    <li><i class="fas fa-check-circle"></i> تحليلات متقدمة</li>
                </ul>
                <button class="plan-button primary" onclick="window.location.href='/webapp'">اشترك الآن</button>
            </div>

            <!-- Enterprise Plan -->
            <div class="pricing-card">
                <h2 class="plan-name">للشركات</h2>
                <p class="plan-name-en">Enterprise</p>
                <div class="plan-price">$49<span>/شهرياً</span></div>
                <p class="plan-duration">للشركات الكبيرة والمؤسسات</p>
                <ul class="plan-features">
                    <li><i class="fas fa-check-circle"></i> كل مميزات Pro</li>
                    <li><i class="fas fa-check-circle"></i> فرق عمل متعددة</li>
                    <li><i class="fas fa-check-circle"></i> تقارير مخصصة</li>
                    <li><i class="fas fa-check-circle"></i> دعم مخصص 24/7</li>
                    <li><i class="fas fa-check-circle"></i> API Access</li>
                    <li><i class="fas fa-check-circle"></i> مدير حساب مخصص</li>
                    <li><i class="fas fa-check-circle"></i> تدريب وإعداد مخصص</li>
                </ul>
                <button class="plan-button secondary" onclick="window.location.href='/webapp'">اتصل بنا</button>
            </div>
        </div>

        <!-- FAQ Section -->
        <div class="faq-section">
            <h2>الأسئلة الشائعة</h2>

            <div class="faq-item">
                <h3>هل يمكنني تغيير خطتي لاحقاً؟</h3>
                <p>نعم، يمكنك الترقية أو تخفيض خطتك في أي وقت. سيتم حساب الفرق بشكل تلقائي.</p>
            </div>

            <div class="faq-item">
                <h3>هل الأسعار شاملة الضرائب؟</h3>
                <p>الأسعار المعروضة لا تشمل الضرائب. قد تُطبق ضرائب إضافية حسب موقعك الجغرافي.</p>
            </div>

            <div class="faq-item">
                <h3>ما هي طرق الدفع المتاحة؟</h3>
                <p>نقبل جميع البطاقات الائتمانية الرئيسية، PayPal، والتحويلات البنكية للخطط السنوية.</p>
            </div>

            <div class="faq-item">
                <h3>هل هناك فترة تجريبية مجانية؟</h3>
                <p>نعم، جميع الخطط المدفوعة تأتي مع فترة تجريبية مجانية لمدة 14 يوماً بدون الحاجة لبطاقة ائتمانية.</p>
            </div>

            <div class="faq-item">
                <h3>هل يمكنني إلغاء اشتراكي في أي وقت؟</h3>
                <p>نعم، يمكنك إلغاء اشتراكك في أي وقت دون أي رسوم إضافية. ستحتفظ بالوصول حتى نهاية فترة الفوترة.</p>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        <div class="footer-links">
            <a href="/">الرئيسية</a>
            <a href="/about">من نحن</a>
            <a href="/pricing">الأسعار</a>
            <a href="/webapp">تطبيق الويب</a>
        </div>

        <div class="social-icons">
            <a href="#" aria-label="Facebook"><i class="fab fa-facebook"></i></a>
            <a href="#" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
            <a href="#" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
            <a href="#" aria-label="LinkedIn"><i class="fab fa-linkedin"></i></a>
        </div>

        <div class="copyright">
            <p>&copy; 2024 Social Media Manager. جميع الحقوق محفوظة.</p>
        </div>
    </footer>
</body>
</html>
