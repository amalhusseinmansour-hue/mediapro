<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>عن Social Media Manager - من نحن</title>
    <meta name="description" content="تعرف على Social Media Manager - منصة إدارة حسابات السوشال ميديا الاحترافية">

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
            max-width: 1200px;
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

        .about-section {
            background: rgba(30, 41, 59, 0.5);
            border-radius: 20px;
            padding: 3rem;
            margin-bottom: 2rem;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .about-section h2 {
            font-size: 2rem;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 1.5rem;
        }

        .about-section p {
            font-size: 1.1rem;
            line-height: 1.8;
            color: #cbd5e1;
            margin-bottom: 1rem;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }

        .feature-card {
            background: rgba(30, 41, 59, 0.5);
            border-radius: 15px;
            padding: 2rem;
            text-align: center;
            border: 1px solid rgba(148, 163, 184, 0.1);
            transition: all 0.3s ease;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            border-color: #667eea;
        }

        .feature-card i {
            font-size: 3rem;
            color: #667eea;
            margin-bottom: 1rem;
        }

        .feature-card h3 {
            font-size: 1.3rem;
            font-weight: 700;
            color: #e2e8f0;
            margin-bottom: 0.5rem;
        }

        .feature-card p {
            font-size: 1rem;
            color: #94a3b8;
        }

        /* Footer */
        footer {
            background: rgba(15, 23, 42, 0.95);
            padding: 3rem 2rem 1rem;
            text-align: center;
            border-top: 1px solid rgba(148, 163, 184, 0.1);
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

            .about-section {
                padding: 2rem;
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
            <h1>من نحن</h1>
            <p>تعرف على منصة Social Media Manager</p>
        </div>

        <div class="about-section">
            <h2>رؤيتنا</h2>
            <p>
                نحن في Social Media Manager نؤمن بأن إدارة حسابات وسائل التواصل الاجتماعي يجب أن تكون سهلة وفعالة ومتاحة للجميع.
                نسعى لتوفير أدوات احترافية تساعد الأفراد والشركات على تحسين تواجدهم الرقمي وتحقيق أهدافهم التسويقية.
            </p>
        </div>

        <div class="about-section">
            <h2>ما نقدمه</h2>
            <p>
                منصتنا توفر حلاً شاملاً لإدارة جميع حساباتك على وسائل التواصل الاجتماعي من مكان واحد.
                مع تقنيات الذكاء الاصطناعي المتقدمة، نساعدك على إنشاء محتوى جذاب، وجدولة المنشورات،
                وتحليل الأداء، والتفاعل مع جمهورك بكفاءة أكبر.
            </p>

            <div class="features-grid">
                <div class="feature-card">
                    <i class="fas fa-robot"></i>
                    <h3>ذكاء اصطناعي متقدم</h3>
                    <p>استخدم AI لإنشاء محتوى احترافي وجذاب</p>
                </div>
                <div class="feature-card">
                    <i class="fas fa-network-wired"></i>
                    <h3>إدارة متعددة المنصات</h3>
                    <p>إدارة جميع حساباتك من مكان واحد</p>
                </div>
                <div class="feature-card">
                    <i class="fas fa-chart-line"></i>
                    <h3>تحليلات شاملة</h3>
                    <p>قس نجاحك بتقارير وإحصائيات دقيقة</p>
                </div>
                <div class="feature-card">
                    <i class="fas fa-clock"></i>
                    <h3>جدولة ذكية</h3>
                    <p>انشر محتواك في الوقت المثالي</p>
                </div>
            </div>
        </div>

        <div class="about-section">
            <h2>لماذا نحن؟</h2>
            <p>
                نتميز بواجهة مستخدم سهلة وبديهية، دعم فني متواصل، وأسعار تنافسية تناسب جميع الاحتياجات.
                فريقنا يعمل باستمرار على تطوير المنصة وإضافة ميزات جديدة لضمان حصولك على أفضل تجربة ممكنة.
            </p>
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
