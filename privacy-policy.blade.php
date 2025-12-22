<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>سياسة الخصوصية - Social Media Manager</title>
    <meta name="description" content="سياسة الخصوصية وحماية البيانات لمنصة Social Media Manager">

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
            line-height: 1.8;
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
            max-width: 900px;
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
            font-size: 1.1rem;
            color: #94a3b8;
        }

        .last-updated {
            text-align: center;
            color: #64748b;
            font-size: 0.95rem;
            margin-bottom: 3rem;
        }

        .policy-section {
            background: rgba(30, 41, 59, 0.5);
            border-radius: 20px;
            padding: 2.5rem;
            margin-bottom: 2rem;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .policy-section h2 {
            font-size: 1.8rem;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .policy-section h2 i {
            font-size: 1.5rem;
        }

        .policy-section h3 {
            font-size: 1.3rem;
            font-weight: 600;
            color: #cbd5e1;
            margin: 1.5rem 0 1rem;
        }

        .policy-section p {
            font-size: 1.05rem;
            color: #cbd5e1;
            margin-bottom: 1rem;
            line-height: 1.9;
        }

        .policy-section ul {
            list-style: none;
            margin: 1rem 0;
        }

        .policy-section ul li {
            padding: 0.5rem 0 0.5rem 2rem;
            color: #cbd5e1;
            position: relative;
        }

        .policy-section ul li::before {
            content: '\f00c';
            font-family: 'Font Awesome 6 Free';
            font-weight: 900;
            position: absolute;
            right: 0;
            color: #667eea;
        }

        .highlight-box {
            background: rgba(102, 126, 234, 0.1);
            border-right: 4px solid #667eea;
            padding: 1.5rem;
            border-radius: 10px;
            margin: 1.5rem 0;
        }

        .highlight-box p {
            margin: 0;
            color: #e2e8f0;
        }

        .contact-box {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            border-radius: 15px;
            padding: 2rem;
            text-align: center;
            margin-top: 3rem;
        }

        .contact-box h3 {
            color: #667eea;
            font-size: 1.5rem;
            margin-bottom: 1rem;
        }

        .contact-box p {
            color: #cbd5e1;
            margin-bottom: 1.5rem;
        }

        .contact-box a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            transition: color 0.3s ease;
        }

        .contact-box a:hover {
            color: #764ba2;
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

            .policy-section {
                padding: 1.5rem;
            }

            .policy-section h2 {
                font-size: 1.5rem;
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
            <h1>سياسة الخصوصية</h1>
            <p>نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية</p>
        </div>

        <div class="last-updated">
            <i class="far fa-calendar-alt"></i> آخر تحديث: نوفمبر 2024
        </div>

        <div class="policy-section">
            <h2><i class="fas fa-info-circle"></i> مقدمة</h2>
            <p>
                مرحباً بك في Social Media Manager. نحن نقدر ثقتك بنا ونلتزم بحماية خصوصيتك وبياناتك الشخصية.
                توضح سياسة الخصوصية هذه كيفية جمعنا واستخدامنا وحمايتنا ومشاركتنا للمعلومات التي تقدمها عند استخدام خدماتنا.
            </p>
            <div class="highlight-box">
                <p>
                    <strong>باستخدامك لخدماتنا، فإنك توافق على جمع واستخدام المعلومات وفقاً لهذه السياسة.</strong>
                </p>
            </div>
        </div>

        <div class="policy-section">
            <h2><i class="fas fa-database"></i> المعلومات التي نجمعها</h2>

            <h3>1. المعلومات التي تقدمها مباشرة:</h3>
            <ul>
                <li>معلومات الحساب (الاسم، البريد الإلكتروني، كلمة المرور)</li>
                <li>معلومات الملف الشخصي</li>
                <li>المحتوى الذي تنشره أو تنشئه</li>
                <li>معلومات الدفع والفوترة</li>
                <li>الرسائل والمراسلات</li>
            </ul>

            <h3>2. المعلومات التي نجمعها تلقائياً:</h3>
            <ul>
                <li>معلومات الجهاز (نوع الجهاز، نظام التشغيل، المتصفح)</li>
                <li>عنوان IP والموقع الجغرافي التقريبي</li>
                <li>سجلات الاستخدام والنشاط</li>
                <li>ملفات تعريف الارتباط (Cookies)</li>
            </ul>

            <h3>3. معلومات من حسابات السوشال ميديا:</h3>
            <ul>
                <li>بيانات الوصول إلى حساباتك المرتبطة</li>
                <li>المنشورات والتحليلات</li>
                <li>معلومات الجمهور والتفاعل</li>
            </ul>
        </div>

        <div class="policy-section">
            <h2><i class="fas fa-tasks"></i> كيف نستخدم معلوماتك</h2>
            <p>نستخدم المعلومات التي نجمعها للأغراض التالية:</p>
            <ul>
                <li>تقديم وتحسين خدماتنا</li>
                <li>إدارة حسابك ومصادقة هويتك</li>
                <li>نشر وجدولة المحتوى على حساباتك</li>
                <li>توفير التحليلات والإحصائيات</li>
                <li>معالجة المدفوعات والاشتراكات</li>
                <li>التواصل معك بخصوص خدماتنا</li>
                <li>تحسين تجربة المستخدم</li>
                <li>الامتثال للمتطلبات القانونية</li>
            </ul>
        </div>

        <div class="policy-section">
            <h2><i class="fas fa-share-alt"></i> مشاركة المعلومات</h2>
            <p>نحن لا نبيع معلوماتك الشخصية. قد نشارك معلوماتك في الحالات التالية:</p>
            <ul>
                <li><strong>مع موافقتك:</strong> عندما تمنحنا الإذن الصريح</li>
                <li><strong>مقدمو الخدمات:</strong> شركاء موثوقون يساعدوننا في تقديم الخدمة</li>
                <li><strong>منصات السوشال ميديا:</strong> لنشر المحتوى نيابة عنك</li>
                <li><strong>الامتثال القانوني:</strong> عندما يتطلب القانون ذلك</li>
                <li><strong>حماية الحقوق:</strong> لحماية حقوقنا أو سلامة المستخدمين</li>
            </ul>
        </div>

        <div class="policy-section">
            <h2><i class="fas fa-shield-alt"></i> أمن البيانات</h2>
            <p>نتخذ إجراءات أمنية صارمة لحماية معلوماتك:</p>
            <ul>
                <li>تشفير البيانات أثناء النقل والتخزين (SSL/TLS)</li>
                <li>تخزين آمن على خوادم محمية</li>
                <li>مصادقة ثنائية للحسابات</li>
                <li>مراقبة أمنية مستمرة</li>
                <li>تحديثات أمنية منتظمة</li>
                <li>الوصول المحدود للموظفين المصرح لهم فقط</li>
            </ul>
            <div class="highlight-box">
                <p>
                    <i class="fas fa-exclamation-triangle"></i>
                    على الرغم من جهودنا، لا يمكن ضمان أمن 100٪ عبر الإنترنت. يرجى استخدام كلمات مرور قوية وعدم مشاركة معلومات حسابك.
                </p>
            </div>
        </div>

        <div class="policy-section">
            <h2><i class="fas fa-user-shield"></i> حقوقك</h2>
            <p>لديك الحقوق التالية فيما يتعلق ببياناتك الشخصية:</p>
            <ul>
                <li><strong>الوصول:</strong> طلب نسخة من بياناتك الشخصية</li>
                <li><strong>التصحيح:</strong> تحديث أو تصحيح معلوماتك</li>
                <li><strong>الحذف:</strong> طلب حذف بياناتك</li>
                <li><strong>التقييد:</strong> تقييد معالجة بياناتك</li>
                <li><strong>النقل:</strong> الحصول على بياناتك بصيغة قابلة للنقل</li>
                <li><strong>الاعتراض:</strong> الاعتراض على معالجة بياناتك</li>
                <li><strong>إلغاء الموافقة:</strong> سحب موافقتك في أي وقت</li>
            </ul>
            <p>لممارسة أي من هذه الحقوق، يرجى الاتصال بنا من خلال معلومات الاتصال أدناه.</p>
        </div>

        <div class="policy-section">
            <h2><i class="fas fa-cookie-bite"></i> ملفات تعريف الارتباط (Cookies)</h2>
            <p>
                نستخدم ملفات تعريف الارتباط والتقنيات المشابهة لتحسين تجربتك. يمكنك التحكم في ملفات تعريف الارتباط من خلال إعدادات المتصفح الخاص بك.
            </p>
            <h3>أنواع ملفات تعريف الارتباط التي نستخدمها:</h3>
            <ul>
                <li><strong>ضرورية:</strong> مطلوبة لتشغيل الموقع</li>
                <li><strong>وظيفية:</strong> لتذكر تفضيلاتك</li>
                <li><strong>تحليلية:</strong> لفهم كيفية استخدام الخدمة</li>
                <li><strong>تسويقية:</strong> لعرض محتوى ذي صلة</li>
            </ul>
        </div>

        <div class="policy-section">
            <h2><i class="fas fa-clock"></i> الاحتفاظ بالبيانات</h2>
            <p>
                نحتفظ بمعلوماتك الشخصية طالما كان حسابك نشطاً أو حسب الحاجة لتقديم الخدمات.
                بعد حذف حسابك، سنحذف أو نجعل بياناتك مجهولة خلال 90 يوماً، باستثناء البيانات التي يتطلب القانون الاحتفاظ بها.
            </p>
        </div>

        <div class="policy-section">
            <h2><i class="fas fa-child"></i> خصوصية الأطفال</h2>
            <p>
                خدماتنا غير موجهة للأطفال دون سن 13 عاماً. نحن لا نجمع عن قصد معلومات شخصية من الأطفال.
                إذا علمنا أننا جمعنا معلومات من طفل دون سن 13 عاماً، فسنتخذ خطوات لحذف تلك المعلومات.
            </p>
        </div>

        <div class="policy-section">
            <h2><i class="fas fa-globe"></i> النقل الدولي للبيانات</h2>
            <p>
                قد يتم نقل بياناتك ومعالجتها في دول أخرى غير دولتك. نتخذ التدابير المناسبة لضمان حماية بياناتك
                وفقاً لهذه السياسة بغض النظر عن مكان معالجتها.
            </p>
        </div>

        <div class="policy-section">
            <h2><i class="fas fa-edit"></i> التغييرات على هذه السياسة</h2>
            <p>
                قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنخطرك بأي تغييرات جوهرية عبر البريد الإلكتروني
                أو من خلال إشعار بارز على موقعنا. يُنصح بمراجعة هذه الصفحة بشكل دوري للبقاء على اطلاع بأي تغييرات.
            </p>
        </div>

        <div class="contact-box">
            <h3><i class="fas fa-envelope"></i> تواصل معنا</h3>
            <p>إذا كان لديك أي أسئلة حول سياسة الخصوصية هذه أو ترغب في ممارسة حقوقك:</p>
            <p>
                <strong>البريد الإلكتروني:</strong> <a href="mailto:privacy@mediaprosocial.io">privacy@mediaprosocial.io</a><br>
                <strong>أو عبر تطبيق الويب:</strong> <a href="/webapp">افتح تطبيق الويب</a>
            </p>
        </div>
    </div>

    <!-- Footer -->
    <footer>
        <div class="footer-links">
            <a href="/">الرئيسية</a>
            <a href="/about">من نحن</a>
            <a href="/pricing">الأسعار</a>
            <a href="/privacy-policy">سياسة الخصوصية</a>
            <a href="/terms-of-service">شروط الخدمة</a>
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
