<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>الأسعار - Social Media Manager</title>

    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;600;700;900&display=swap" rel="stylesheet">
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
            border-bottom: 1px solid rgba(148, 163, 184, 0.1);
        }

        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo img {
            height: 40px;
            border-radius: 8px;
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
        }

        /* Hero Section */
        .hero {
            text-align: center;
            padding: 4rem 2rem 3rem;
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        }

        .hero h1 {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 1rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .hero p {
            font-size: 1.3rem;
            color: #94a3b8;
            max-width: 700px;
            margin: 0 auto;
        }

        /* Pricing Cards */
        .pricing-container {
            max-width: 1200px;
            margin: 4rem auto;
            padding: 0 2rem;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
        }

        .pricing-card {
            background: #1e293b;
            border-radius: 20px;
            padding: 2.5rem;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
            border: 2px solid rgba(148, 163, 184, 0.1);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .pricing-card:hover {
            transform: translateY(-10px);
            border-color: rgba(102, 126, 234, 0.5);
            box-shadow: 0 20px 60px rgba(102, 126, 234, 0.2);
        }

        .pricing-card.featured {
            border-color: #667eea;
            background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
        }

        .featured-badge {
            position: absolute;
            top: 20px;
            left: -30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 0.3rem 2.5rem;
            transform: rotate(-45deg);
            font-size: 0.8rem;
            font-weight: 600;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
        }

        .plan-name {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
            color: #e2e8f0;
        }

        .plan-price {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .plan-price span {
            font-size: 1.2rem;
            color: #94a3b8;
        }

        .plan-description {
            color: #94a3b8;
            margin-bottom: 2rem;
            font-size: 1rem;
        }

        .plan-features {
            list-style: none;
            margin-bottom: 2rem;
        }

        .plan-features li {
            padding: 0.7rem 0;
            color: #cbd5e1;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .plan-features i {
            color: #10b981;
            font-size: 1.1rem;
        }

        .btn-subscribe {
            width: 100%;
            padding: 1rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            font-family: 'Cairo', sans-serif;
        }

        .btn-subscribe:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }

        .btn-subscribe:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            z-index: 2000;
            align-items: center;
            justify-content: center;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: #1e293b;
            border-radius: 20px;
            padding: 2.5rem;
            max-width: 500px;
            width: 90%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
            border: 1px solid rgba(148, 163, 184, 0.1);
            animation: slideUp 0.3s ease;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .modal-header h2 {
            font-size: 1.8rem;
            color: #e2e8f0;
        }

        .close-modal {
            background: none;
            border: none;
            color: #94a3b8;
            font-size: 1.5rem;
            cursor: pointer;
            transition: color 0.3s;
        }

        .close-modal:hover {
            color: #ef4444;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: #cbd5e1;
            font-weight: 500;
        }

        .form-group input {
            width: 100%;
            padding: 0.8rem;
            background: #0f172a;
            border: 1px solid rgba(148, 163, 184, 0.2);
            border-radius: 8px;
            color: #e2e8f0;
            font-family: 'Cairo', sans-serif;
            font-size: 1rem;
        }

        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }

        .btn-pay {
            width: 100%;
            padding: 1rem;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            font-family: 'Cairo', sans-serif;
        }

        .btn-pay:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(16, 185, 129, 0.4);
        }

        .btn-pay:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        .loading {
            display: none;
            text-align: center;
            margin-top: 1rem;
            color: #667eea;
        }

        .loading.active {
            display: block;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .nav-links {
                display: none;
            }

            .hero h1 {
                font-size: 2rem;
            }

            .pricing-container {
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
                <img src="{{ asset('assets/logo.jpeg') }}" alt="Social Media Manager">
            </a>
            <ul class="nav-links">
                <li><a href="/">الرئيسية</a></li>
                <li><a href="/pricing">الأسعار</a></li>
                <li><a href="/contact">تواصل معنا</a></li>
            </ul>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero">
        <h1>اختر الخطة المناسبة لك</h1>
        <p>احصل على أفضل الأدوات لإدارة حساباتك على وسائل التواصل الاجتماعي بأسعار تنافسية</p>
    </section>

    <!-- Pricing Cards -->
    <div class="pricing-container">
        @forelse($plans as $index => $plan)
        <div class="pricing-card {{ $plan->is_popular ? 'featured' : '' }}">
            @if($plan->is_popular)
            <div class="featured-badge">الأكثر شعبية</div>
            @endif

            <h3 class="plan-name">{{ $plan->name }}</h3>
            <div class="plan-price">
                {{ number_format($plan->price, 0) }}
                <span>{{ $plan->currency ?? 'AED' }}/شهر</span>
            </div>
            <p class="plan-description">{{ $plan->description ?? 'خطة مميزة لإدارة حساباتك' }}</p>

            <ul class="plan-features">
                <li><i class="fas fa-check-circle"></i> {{ $plan->max_accounts ?? 'غير محدود' }} حساب</li>
                <li><i class="fas fa-check-circle"></i> {{ $plan->max_posts ?? 'غير محدود' }} منشور/شهر</li>
                @if($plan->ai_features)
                <li><i class="fas fa-check-circle"></i> ميزات الذكاء الاصطناعي</li>
                @endif
                @if($plan->analytics)
                <li><i class="fas fa-check-circle"></i> تحليلات متقدمة</li>
                @endif
                @if($plan->scheduling)
                <li><i class="fas fa-check-circle"></i> جدولة المنشورات</li>
                @endif
                <li><i class="fas fa-check-circle"></i> دعم فني 24/7</li>
                @forelse($plan->features as $feature)
                <li><i class="fas fa-check-circle"></i> {{ $feature }}</li>
                @empty
                @endforelse
            </ul>

            <button class="btn-subscribe" onclick="openPaymentModal({{ $plan->id }}, '{{ $plan->name }}', {{ $plan->price }}, '{{ $plan->currency ?? 'AED' }}')">
                اشترك الآن
            </button>
        </div>
        @empty
        <div style="grid-column: 1/-1; text-align: center; padding: 3rem; color: #94a3b8;">
            <i class="fas fa-info-circle" style="font-size: 3rem; margin-bottom: 1rem;"></i>
            <p>لا توجد خطط اشتراك متاحة حالياً</p>
        </div>
        @endforelse
    </div>

    <!-- Payment Modal -->
    <div class="modal" id="paymentModal">
        <div class="modal-content">
            <div class="modal-header">
                <h2>إتمام الاشتراك</h2>
                <button class="close-modal" onclick="closePaymentModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <form id="paymentForm" onsubmit="handlePayment(event)">
                <input type="hidden" id="plan_id" name="plan_id">

                <div class="form-group">
                    <label>الخطة المختارة</label>
                    <input type="text" id="plan_name" readonly>
                </div>

                <div class="form-group">
                    <label>السعر</label>
                    <input type="text" id="plan_price" readonly>
                </div>

                <div class="form-group">
                    <label>الاسم الكامل <span style="color: #ef4444;">*</span></label>
                    <input type="text" name="name" required placeholder="أدخل اسمك الكامل">
                </div>

                <div class="form-group">
                    <label>البريد الإلكتروني <span style="color: #ef4444;">*</span></label>
                    <input type="email" name="email" required placeholder="example@email.com">
                </div>

                <div class="form-group">
                    <label>رقم الهاتف <span style="color: #ef4444;">*</span></label>
                    <input type="tel" name="phone" required placeholder="05xxxxxxxx">
                </div>

                <button type="submit" class="btn-pay" id="payButton">
                    <i class="fas fa-lock"></i> الدفع الآمن
                </button>

                <div class="loading" id="loading">
                    <i class="fas fa-spinner fa-spin"></i> جاري تحويلك لصفحة الدفع...
                </div>
            </form>
        </div>
    </div>

    <script>
        let currentPlan = null;

        function openPaymentModal(planId, planName, price, currency) {
            currentPlan = planId;
            document.getElementById('plan_id').value = planId;
            document.getElementById('plan_name').value = planName;
            document.getElementById('plan_price').value = price + ' ' + currency;
            document.getElementById('paymentModal').classList.add('active');
        }

        function closePaymentModal() {
            document.getElementById('paymentModal').classList.remove('active');
            document.getElementById('paymentForm').reset();
            document.getElementById('loading').classList.remove('active');
            document.getElementById('payButton').disabled = false;
        }

        async function handlePayment(event) {
            event.preventDefault();

            const form = event.target;
            const formData = new FormData(form);
            const data = Object.fromEntries(formData);

            // Show loading
            document.getElementById('loading').classList.add('active');
            document.getElementById('payButton').disabled = true;

            try {
                const response = await fetch('/payment/initiate', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}'
                    },
                    body: JSON.stringify(data)
                });

                const result = await response.json();

                if (result.success) {
                    // Redirect to payment page
                    window.location.href = result.payment_url;
                } else {
                    alert('حدث خطأ: ' + (result.message || 'يرجى المحاولة مرة أخرى'));
                    document.getElementById('loading').classList.remove('active');
                    document.getElementById('payButton').disabled = false;
                }
            } catch (error) {
                console.error('Payment Error:', error);
                alert('حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى');
                document.getElementById('loading').classList.remove('active');
                document.getElementById('payButton').disabled = false;
            }
        }

        // Close modal on outside click
        document.getElementById('paymentModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closePaymentModal();
            }
        });
    </script>
</body>
</html>
