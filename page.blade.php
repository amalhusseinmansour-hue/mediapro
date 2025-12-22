<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $page->title }} - Social Media Manager</title>
    <meta name="description" content="{{ $page->meta_description ?? $page->excerpt }}">

    <!-- Google Fonts -->
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
            background: #0f172a;
            color: #e2e8f0;
            line-height: 1.8;
        }

        /* Navbar */
        .navbar {
            background: rgba(15, 23, 42, 0.95);
            backdrop-filter: blur(10px);
            padding: 1.5rem 2rem;
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.3);
            position: sticky;
            top: 0;
            z-index: 1000;
            transition: all 0.3s ease;
            border-bottom: 1px solid rgba(148, 163, 184, 0.1);
        }

        .navbar.scrolled {
            padding: 1rem 2rem;
            box-shadow: 0 5px 30px rgba(0, 0, 0, 0.5);
        }

        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            font-size: 1.8rem;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .nav-links {
            display: flex;
            gap: 2rem;
            list-style: none;
        }

        .nav-links a {
            color: #cbd5e1;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            padding: 0.5rem 1rem;
            border-radius: 8px;
        }

        .nav-links a:hover {
            background: rgba(102, 126, 234, 0.1);
            color: #667eea;
            transform: translateY(-2px);
        }

        /* Page Content */
        .page-container {
            max-width: 1200px;
            margin: 4rem auto;
            padding: 0 2rem;
        }

        .page-header {
            text-align: center;
            margin-bottom: 3rem;
            padding: 3rem 0;
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .page-title {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 1rem;
            animation: fadeInUp 0.6s ease;
            background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .page-excerpt {
            font-size: 1.3rem;
            color: #94a3b8;
            animation: fadeInUp 0.8s ease;
        }

        .page-content {
            background: #1e293b;
            padding: 3rem;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
            animation: fadeIn 1s ease;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .page-content h1,
        .page-content h2,
        .page-content h3 {
            margin-top: 2rem;
            margin-bottom: 1rem;
            color: #667eea;
        }

        .page-content p {
            margin-bottom: 1.5rem;
            font-size: 1.1rem;
            line-height: 2;
            color: #cbd5e1;
        }

        .page-content ul,
        .page-content ol {
            margin-right: 2rem;
            margin-bottom: 1.5rem;
        }

        .page-content li {
            margin-bottom: 0.8rem;
            font-size: 1.1rem;
            color: #cbd5e1;
        }

        .page-content a {
            color: #667eea;
            text-decoration: none;
            border-bottom: 2px solid #667eea;
            transition: all 0.3s ease;
        }

        .page-content a:hover {
            color: #764ba2;
            border-bottom-color: #764ba2;
        }

        /* Footer */
        .footer {
            background: #0f172a;
            color: #cbd5e1;
            padding: 3rem 2rem 2rem;
            margin-top: 6rem;
            border-top: 1px solid rgba(148, 163, 184, 0.1);
        }

        .footer-container {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 3rem;
            margin-bottom: 2rem;
        }

        .footer-section h3 {
            font-size: 1.3rem;
            margin-bottom: 1rem;
            color: #e2e8f0;
        }

        .footer-section ul {
            list-style: none;
        }

        .footer-section ul li {
            margin-bottom: 0.8rem;
        }

        .footer-section a {
            color: #94a3b8;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .footer-section a:hover {
            color: #667eea;
            padding-right: 5px;
        }

        .footer-bottom {
            text-align: center;
            padding-top: 2rem;
            border-top: 1px solid rgba(148, 163, 184, 0.1);
            color: #64748b;
        }

        /* Animations */
        @keyframes fadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive */
        @media (max-width: 768px) {
            .nav-links {
                display: none;
            }

            .page-title {
                font-size: 2rem;
            }

            .page-excerpt {
                font-size: 1.1rem;
            }

            .page-content {
                padding: 2rem;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar" id="navbar">
        <div class="nav-container">
            <a href="/" class="logo">
                <img src="{{ asset('assets/logo.jpeg') }}" alt="Social Media Manager" style="height: 40px; border-radius: 8px;">
            </a>
            <ul class="nav-links">
                <li><a href="/">الرئيسية</a></li>
                <li><a href="/about">من نحن</a></li>
                <li><a href="/pricing">الأسعار</a></li>
                <li><a href="/contact">تواصل معنا</a></li>
            </ul>
        </div>
    </nav>

    <!-- Page Content -->
    <div class="page-container">
        <div class="page-header">
            <h1 class="page-title">{{ $page->title }}</h1>
            @if($page->excerpt)
            <p class="page-excerpt">{{ $page->excerpt }}</p>
            @endif
        </div>

        <div class="page-content">
            {!! $page->content !!}
        </div>
    </div>

    <!-- Footer -->
    <footer class="footer">
        <div class="footer-container">
            <div class="footer-section">
                <img src="{{ asset('assets/logo.jpeg') }}" alt="Social Media Manager" style="height: 50px; border-radius: 10px; margin-bottom: 1rem;">
                <p style="color: #94a3b8; line-height: 1.8;">
                    الحل الشامل لإدارة حساباتك على وسائل التواصل الاجتماعي بكفاءة واحترافية
                </p>
            </div>

            <div class="footer-section">
                <h3>روابط سريعة</h3>
                <ul>
                    <li><a href="/">الرئيسية</a></li>
                    <li><a href="/about">من نحن</a></li>
                    <li><a href="/pricing">الأسعار</a></li>
                    <li><a href="/contact">تواصل معنا</a></li>
                </ul>
            </div>

            <div class="footer-section">
                <h3>قانوني</h3>
                <ul>
                    <li><a href="/privacy-policy">سياسة الخصوصية</a></li>
                    <li><a href="/terms-of-service">شروط الخدمة</a></li>
                </ul>
            </div>

            <div class="footer-section">
                <h3>تواصل معنا</h3>
                <ul>
                    <li style="color: #94a3b8;"><i class="fas fa-envelope"></i> info@socialmanager.com</li>
                    <li style="color: #94a3b8;"><i class="fas fa-phone"></i> +966 50 123 4567</li>
                </ul>
            </div>
        </div>

        <div class="footer-bottom">
            <p>&copy; {{ date('Y') }} Social Media Manager. جميع الحقوق محفوظة.</p>
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
    </script>
</body>
</html>
