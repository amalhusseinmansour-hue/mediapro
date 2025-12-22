<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>شروط الخدمة - Social Media Manager</title>
    <meta name="description" content="شروط وأحكام استخدام خدمات Social Media Manager">

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

        .terms-section {
            background: rgba(30, 41, 59, 0.5);
            border-radius: 20px;
            padding: 2.5rem;
            margin-bottom: 2rem;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .terms-section h2 {
            font-size: 1.8rem;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .terms-section h2 i {
            font-size: 1.5rem;
        }

        .terms-section h3 {
            font-size: 1.3rem;
            font-weight: 600;
            color: #cbd5e1;
            margin: 1.5rem 0 1rem;
        }

        .terms-section p {
            font-size: 1.05rem;
            color: #cbd5e1;
            margin-bottom: 1rem;
            line-height: 1.9;
        }

        .terms-section ul {
            list-style: none;
            margin: 1rem 0;
        }

        .terms-section ul li {
            padding: 0.5rem 0 0.5rem 2rem;
            color: #cbd5e1;
            position: relative;
        }

        .terms-section ul li::before {
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

        .warning-box {
            background: rgba(239, 68, 68, 0.1);
            border-right: 4px solid #ef4444;
            padding: 1.5rem;
            border-radius: 10px;
            margin: 1.5rem 0;
        }

        .warning-box p {
            margin: 0;
            color: #fecaca;
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

            .terms-section {
                padding: 1.5rem;
            }

            .terms-section h2 {
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
            <h1>شروط الخدمة</h1>
            <p>الشروط والأحكام التي تحكم استخدامك لخدماتنا</p>
        </div>

        <div class="last-updated">
            <i class="far fa-calendar-alt"></i> آخر تحديث: نوفمبر 2024
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-file-contract"></i> قبول الشروط</h2>
            <p>
                مرحباً بك في Social Media Manager. باستخدامك لخدماتنا، فإنك توافق على الالتزام بهذه الشروط والأحكام.
                يرجى قراءتها بعناية قبل استخدام خدماتنا.
            </p>
            <div class="highlight-box">
                <p>
                    <strong>إذا كنت لا توافق على هذه الشروط، يرجى عدم استخدام خدماتنا.</strong>
                </p>
            </div>
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-user-check"></i> الأهلية للاستخدام</h2>
            <p>لاستخدام خدماتنا، يجب أن:</p>
            <ul>
                <li>تكون في سن 13 عاماً أو أكثر</li>
                <li>تملك السلطة القانونية لقبول هذه الشروط</li>
                <li>لا تكون ممنوعاً من استخدام الخدمة بموجب أي قوانين معمول بها</li>
                <li>تقدم معلومات دقيقة وكاملة عند التسجيل</li>
            </ul>
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-user-circle"></i> حسابك ومسؤولياتك</h2>

            <h3>إنشاء الحساب:</h3>
            <ul>
                <li>يجب عليك تقديم معلومات دقيقة وكاملة</li>
                <li>أنت مسؤول عن الحفاظ على سرية كلمة المرور الخاصة بك</li>
                <li>أنت مسؤول عن جميع الأنشطة التي تحدث تحت حسابك</li>
                <li>يجب عليك إخطارنا فوراً بأي استخدام غير مصرح به</li>
            </ul>

            <h3>استخدام الحساب:</h3>
            <ul>
                <li>لا يجوز مشاركة حسابك مع الآخرين</li>
                <li>لا يجوز لك إنشاء أكثر من حساب واحد لنفسك</li>
                <li>لا يجوز استخدام حساب شخص آخر بدون إذن</li>
            </ul>

            <div class="warning-box">
                <p>
                    <i class="fas fa-exclamation-triangle"></i>
                    <strong>تحذير:</strong> نحتفظ بالحق في إلغاء أو تعليق حسابك في أي وقت إذا انتهكت هذه الشروط.
                </p>
            </div>
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-tasks"></i> استخدام الخدمة</h2>

            <h3>الاستخدام المسموح:</h3>
            <ul>
                <li>إدارة حسابات وسائل التواصل الاجتماعي الخاصة بك</li>
                <li>جدولة ونشر المحتوى</li>
                <li>تحليل أداء حساباتك</li>
                <li>استخدام أدوات الذكاء الاصطناعي للمحتوى</li>
            </ul>

            <h3>الاستخدام المحظور:</h3>
            <ul>
                <li>نشر محتوى غير قانوني أو ضار أو مسيء</li>
                <li>انتحال شخصية الآخرين أو تقديم معلومات خاطئة</li>
                <li>إرسال رسائل غير مرغوب فيها أو محتوى ترويجي مسيء</li>
                <li>محاولة اختراق أو تعطيل الخدمة</li>
                <li>استخدام الخدمة لأغراض احتيالية</li>
                <li>جمع معلومات المستخدمين الآخرين بدون إذن</li>
                <li>انتهاك حقوق الملكية الفكرية</li>
            </ul>
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-credit-card"></i> الاشتراكات والمدفوعات</h2>

            <h3>الخطط والأسعار:</h3>
            <p>
                نوفر خطط اشتراك مختلفة. الأسعار الحالية متاحة على صفحة الأسعار.
                نحتفظ بالحق في تغيير الأسعار مع إشعار مسبق.
            </p>

            <h3>الفوترة والدفع:</h3>
            <ul>
                <li>يتم تحصيل الاشتراكات تلقائياً بشكل شهري أو سنوي</li>
                <li>جميع المدفوعات غير قابلة للاسترداد ما لم ينص القانون على خلاف ذلك</li>
                <li>أنت مسؤول عن دفع جميع الضرائب المطبقة</li>
                <li>في حالة فشل الدفع، قد نعلق أو نلغي حسابك</li>
            </ul>

            <h3>الإلغاء والاسترداد:</h3>
            <ul>
                <li>يمكنك إلغاء اشتراكك في أي وقت</li>
                <li>ستحتفظ بالوصول حتى نهاية فترة الفوترة</li>
                <li>لا نقدم استردادات جزئية للأشهر غير المستخدمة</li>
            </ul>
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-copyright"></i> الملكية الفكرية</h2>

            <h3>ملكيتنا:</h3>
            <p>
                جميع حقوق الملكية الفكرية في الخدمة والمحتوى والتصميم والشعارات والبرمجيات
                مملوكة لنا أو لمرخصينا. أنت لا تحصل على أي حقوق ملكية من خلال استخدام الخدمة.
            </p>

            <h3>محتواك:</h3>
            <ul>
                <li>تحتفظ بملكية المحتوى الذي تنشئه أو تنشره</li>
                <li>تمنحنا ترخيصاً لاستخدام محتواك لتوفير الخدمة</li>
                <li>أنت مسؤول عن ضمان أن محتواك لا ينتهك حقوق الآخرين</li>
            </ul>
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-shield-alt"></i> إخلاء المسؤولية والضمانات</h2>

            <div class="warning-box">
                <p>
                    <strong>إخلاء المسؤولية:</strong><br>
                    نقدم الخدمة "كما هي" و"كما هي متاحة" دون أي ضمانات من أي نوع، صريحة أو ضمنية.
                    لا نضمن أن الخدمة ستكون خالية من الأخطاء أو متاحة دون انقطاع.
                </p>
            </div>

            <h3>حدود المسؤولية:</h3>
            <ul>
                <li>لا نتحمل المسؤولية عن أي أضرار غير مباشرة أو عرضية</li>
                <li>مسؤوليتنا الإجمالية محدودة بالمبلغ الذي دفعته في الأشهر الـ 12 الماضية</li>
                <li>لا نتحمل المسؤولية عن المحتوى أو الإجراءات الخاصة بالمستخدمين</li>
            </ul>
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-ban"></i> الإنهاء</h2>

            <h3>إنهاء من قبلك:</h3>
            <p>يمكنك إنهاء حسابك في أي وقت من خلال إعدادات الحساب.</p>

            <h3>إنهاء من قبلنا:</h3>
            <p>نحتفظ بالحق في تعليق أو إنهاء حسابك في أي وقت لأي سبب، بما في ذلك:</p>
            <ul>
                <li>انتهاك هذه الشروط</li>
                <li>عدم الدفع</li>
                <li>نشاط احتيالي أو غير قانوني</li>
                <li>بناءً على طلب من سلطة إنفاذ القانون</li>
            </ul>

            <h3>الآثار المترتبة على الإنهاء:</h3>
            <ul>
                <li>سيتم حذف جميع بياناتك بعد 90 يوماً</li>
                <li>لن تتمكن من الوصول إلى حسابك أو محتواك</li>
                <li>لن نقدم استردادات للفترات غير المستخدمة</li>
            </ul>
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-edit"></i> التغييرات على الشروط</h2>
            <p>
                نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سنخطرك بأي تغييرات جوهرية
                عبر البريد الإلكتروني أو من خلال الخدمة. استمرارك في استخدام الخدمة
                بعد التغييرات يعني قبولك للشروط المعدلة.
            </p>
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-gavel"></i> القانون الحاكم وحل النزاعات</h2>

            <h3>القانون الحاكم:</h3>
            <p>
                تخضع هذه الشروط وتفسر وفقاً للقوانين المعمول بها في موقع تأسيس الشركة،
                دون الإخلال بأحكام تنازع القوانين.
            </p>

            <h3>حل النزاعات:</h3>
            <p>
                في حالة حدوث أي نزاع، نشجعك على الاتصال بنا أولاً لمحاولة حله ودياً.
                إذا لم يتم حل النزاع، فإنه سيتم حله من خلال التحكيم أو المحاكم المختصة.
            </p>
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-link"></i> روابط لمواقع أخرى</h2>
            <p>
                قد تحتوي خدمتنا على روابط لمواقع ويب أو خدمات تابعة لجهات خارجية.
                لسنا مسؤولين عن محتوى أو ممارسات الخصوصية أو أداء هذه المواقع.
            </p>
        </div>

        <div class="terms-section">
            <h2><i class="fas fa-info-circle"></i> أحكام عامة</h2>

            <ul>
                <li><strong>الاتفاقية الكاملة:</strong> تشكل هذه الشروط الاتفاقية الكاملة بيننا وبينك</li>
                <li><strong>القابلية للفصل:</strong> إذا تم اعتبار أي جزء من هذه الشروط غير قابل للتنفيذ، تظل الأحكام المتبقية سارية</li>
                <li><strong>عدم التنازل:</strong> عدم ممارستنا لأي حق لا يعني التنازل عنه</li>
                <li><strong>التنازل:</strong> لا يجوز لك نقل حقوقك بموجب هذه الشروط دون موافقتنا</li>
            </ul>
        </div>

        <div class="contact-box">
            <h3><i class="fas fa-envelope"></i> أسئلة حول الشروط؟</h3>
            <p>إذا كان لديك أي أسئلة حول شروط الخدمة، يرجى التواصل معنا:</p>
            <p>
                <strong>البريد الإلكتروني:</strong> <a href="mailto:legal@mediaprosocial.io">legal@mediaprosocial.io</a><br>
                <strong>أو عبر صفحة الاتصال:</strong> <a href="/contact">تواصل معنا</a>
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
            <a href="/contact">تواصل معنا</a>
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
