<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تواصل معنا - Social Media Manager</title>
    <meta name="description" content="تواصل مع فريق Social Media Manager - نحن هنا للإجابة على أسئلتك ومساعدتك">

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

        .contact-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 3rem;
            margin-top: 3rem;
        }

        .contact-info {
            background: rgba(30, 41, 59, 0.5);
            border-radius: 20px;
            padding: 3rem;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .contact-info h2 {
            font-size: 2rem;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 2rem;
        }

        .info-item {
            display: flex;
            align-items: flex-start;
            gap: 1.5rem;
            margin-bottom: 2rem;
            padding: 1.5rem;
            background: rgba(15, 23, 42, 0.5);
            border-radius: 15px;
            transition: all 0.3s ease;
        }

        .info-item:hover {
            transform: translateX(-5px);
            border-right: 3px solid #667eea;
        }

        .info-item i {
            font-size: 1.8rem;
            color: #667eea;
            margin-top: 0.2rem;
        }

        .info-item-content h3 {
            font-size: 1.2rem;
            font-weight: 600;
            color: #e2e8f0;
            margin-bottom: 0.5rem;
        }

        .info-item-content p {
            color: #cbd5e1;
            line-height: 1.8;
        }

        .info-item-content a {
            color: #667eea;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .info-item-content a:hover {
            color: #764ba2;
        }

        .social-links {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
        }

        .social-link {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 50px;
            height: 50px;
            background: rgba(102, 126, 234, 0.1);
            border-radius: 10px;
            color: #667eea;
            font-size: 1.5rem;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .social-link:hover {
            background: #667eea;
            color: white;
            transform: translateY(-3px);
        }

        /* Contact Form */
        .contact-form {
            background: rgba(30, 41, 59, 0.5);
            border-radius: 20px;
            padding: 3rem;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .contact-form h2 {
            font-size: 2rem;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 2rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            color: #e2e8f0;
            margin-bottom: 0.5rem;
            font-size: 1.05rem;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 1rem;
            background: rgba(15, 23, 42, 0.7);
            border: 2px solid rgba(148, 163, 184, 0.2);
            border-radius: 10px;
            color: #e2e8f0;
            font-family: 'Cairo', sans-serif;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
            background: rgba(15, 23, 42, 0.9);
        }

        .form-group textarea {
            min-height: 150px;
            resize: vertical;
        }

        .submit-button {
            width: 100%;
            padding: 1.2rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            font-family: 'Cairo', sans-serif;
        }

        .submit-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }

        .form-note {
            margin-top: 1rem;
            padding: 1rem;
            background: rgba(102, 126, 234, 0.1);
            border-right: 3px solid #667eea;
            border-radius: 8px;
            color: #cbd5e1;
            font-size: 0.95rem;
        }

        /* FAQ Section */
        .faq-section {
            margin-top: 4rem;
            background: rgba(30, 41, 59, 0.5);
            border-radius: 20px;
            padding: 3rem;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .faq-section h2 {
            font-size: 2rem;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 2rem;
            text-align: center;
        }

        .faq-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
        }

        .faq-item {
            background: rgba(15, 23, 42, 0.5);
            border-radius: 15px;
            padding: 1.5rem;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .faq-item h3 {
            color: #667eea;
            font-size: 1.1rem;
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .faq-item h3 i {
            font-size: 0.9rem;
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

        @media (max-width: 968px) {
            .contact-container {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .nav-links {
                display: none;
            }

            .page-header h1 {
                font-size: 2rem;
            }

            .contact-info,
            .contact-form {
                padding: 2rem;
            }

            .faq-grid {
                grid-template-columns: 1fr;
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
                <li><a href="/contact">تواصل معنا</a></li>
                <li><a href="/webapp" class="cta-button">افتح تطبيق الويب</a></li>
            </ul>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="content">
        <div class="page-header">
            <h1>تواصل معنا</h1>
            <p>نحن هنا لمساعدتك - لا تتردد في التواصل معنا</p>
        </div>

        <div class="contact-container">
            <!-- Contact Information -->
            <div class="contact-info">
                <h2>معلومات التواصل</h2>

                <div class="info-item">
                    <i class="fas fa-envelope"></i>
                    <div class="info-item-content">
                        <h3>البريد الإلكتروني</h3>
                        <p>
                            الدعم العام: <a href="mailto:support@mediaprosocial.io">support@mediaprosocial.io</a><br>
                            المبيعات: <a href="mailto:sales@mediaprosocial.io">sales@mediaprosocial.io</a>
                        </p>
                    </div>
                </div>

                <div class="info-item">
                    <i class="fas fa-clock"></i>
                    <div class="info-item-content">
                        <h3>ساعات العمل</h3>
                        <p>
                            السبت - الخميس: 9:00 صباحاً - 6:00 مساءً<br>
                            الجمعة: مغلق<br>
                            الدعم الطارئ: متاح 24/7
                        </p>
                    </div>
                </div>

                <div class="info-item">
                    <i class="fas fa-headset"></i>
                    <div class="info-item-content">
                        <h3>الدعم الفني</h3>
                        <p>
                            للحصول على دعم فوري، يمكنك استخدام نظام الدعم المباشر في تطبيق الويب.
                            نحن نهدف للرد على جميع الاستفسارات خلال 24 ساعة.
                        </p>
                    </div>
                </div>

                <div class="info-item">
                    <i class="fas fa-map-marker-alt"></i>
                    <div class="info-item-content">
                        <h3>الموقع</h3>
                        <p>
                            نحن شركة رقمية بالكامل، نخدم العملاء حول العالم.<br>
                            يمكنك التواصل معنا عبر القنوات الإلكترونية المتاحة.
                        </p>
                    </div>
                </div>

                <h3 style="color: #667eea; margin: 2rem 0 1rem; font-size: 1.3rem;">تابعنا على وسائل التواصل</h3>
                <div class="social-links">
                    <a href="#" class="social-link" aria-label="Facebook"><i class="fab fa-facebook"></i></a>
                    <a href="#" class="social-link" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
                    <a href="#" class="social-link" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
                    <a href="#" class="social-link" aria-label="LinkedIn"><i class="fab fa-linkedin"></i></a>
                    <a href="#" class="social-link" aria-label="YouTube"><i class="fab fa-youtube"></i></a>
                </div>
            </div>

            <!-- Contact Form -->
            <div class="contact-form">
                <h2>أرسل لنا رسالة</h2>
                <form action="#" method="POST" onsubmit="return handleSubmit(event)">
                    <div class="form-group">
                        <label for="name">الاسم الكامل *</label>
                        <input type="text" id="name" name="name" required placeholder="أدخل اسمك الكامل">
                    </div>

                    <div class="form-group">
                        <label for="email">البريد الإلكتروني *</label>
                        <input type="email" id="email" name="email" required placeholder="example@email.com">
                    </div>

                    <div class="form-group">
                        <label for="subject">الموضوع *</label>
                        <select id="subject" name="subject" required>
                            <option value="">اختر الموضوع</option>
                            <option value="support">دعم فني</option>
                            <option value="sales">استفسار عن المبيعات</option>
                            <option value="billing">الفوترة والاشتراكات</option>
                            <option value="feature">طلب ميزة جديدة</option>
                            <option value="partnership">شراكة أو تعاون</option>
                            <option value="other">أخرى</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="message">الرسالة *</label>
                        <textarea id="message" name="message" required placeholder="اكتب رسالتك هنا..."></textarea>
                    </div>

                    <button type="submit" class="submit-button">
                        <i class="fas fa-paper-plane"></i> إرسال الرسالة
                    </button>

                    <div class="form-note">
                        <i class="fas fa-info-circle"></i>
                        سنقوم بالرد على رسالتك في أقرب وقت ممكن. عادة خلال 24 ساعة في أيام العمل.
                    </div>
                </form>
            </div>
        </div>

        <!-- FAQ Section -->
        <div class="faq-section">
            <h2>الأسئلة الشائعة حول التواصل</h2>
            <div class="faq-grid">
                <div class="faq-item">
                    <h3><i class="fas fa-question-circle"></i> كم يستغرق الرد على استفساري؟</h3>
                    <p>نهدف للرد على جميع الاستفسارات خلال 24 ساعة في أيام العمل. الاستفسارات العاجلة يتم التعامل معها أولاً.</p>
                </div>
                <div class="faq-item">
                    <h3><i class="fas fa-question-circle"></i> هل يوجد دعم مباشر (Live Chat)؟</h3>
                    <p>نعم! يمكنك استخدام نظام الدعم المباشر المتوفر في تطبيق الويب للحصول على مساعدة فورية.</p>
                </div>
                <div class="faq-item">
                    <h3><i class="fas fa-question-circle"></i> ماذا لو كنت أواجه مشكلة طارئة؟</h3>
                    <p>للمشاكل الطارئة التي تؤثر على عملك، يرجى إرسال بريد إلكتروني مع عنوان يبدأ بـ "عاجل" وسنعطيه الأولوية.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        <div class="footer-links">
            <a href="/">الرئيسية</a>
            <a href="/about">من نحن</a>
            <a href="/pricing">الأسعار</a>
            <a href="/contact">تواصل معنا</a>
            <a href="/privacy-policy">سياسة الخصوصية</a>
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

    <script>
        function handleSubmit(event) {
            event.preventDefault();

            // Get form data
            const formData = {
                name: document.getElementById('name').value,
                email: document.getElementById('email').value,
                subject: document.getElementById('subject').value,
                message: document.getElementById('message').value
            };

            // For now, just alert the user
            // In production, this would send to a backend API
            alert('شكراً لتواصلك معنا! سنقوم بالرد عليك في أقرب وقت ممكن.\n\nيرجى ملاحظة: النموذج حالياً في وضع العرض التوضيحي.');

            // Reset form
            event.target.reset();

            return false;
        }

        // Navbar scroll effect
        window.addEventListener('scroll', function() {
            const navbar = document.querySelector('.navbar');
            if (window.scrollY > 50) {
                navbar.style.background = 'rgba(15, 23, 42, 0.98)';
            } else {
                navbar.style.background = 'rgba(15, 23, 42, 0.95)';
            }
        });
    </script>
</body>
</html>
