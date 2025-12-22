<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تم الدفع بنجاح - Social Media Manager</title>
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
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            color: #e2e8f0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .container {
            max-width: 600px;
            width: 100%;
            background: #1e293b;
            border-radius: 20px;
            padding: 3rem;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
            border: 1px solid rgba(148, 163, 184, 0.1);
            text-align: center;
            animation: slideUp 0.6s ease;
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

        .success-icon {
            width: 100px;
            height: 100px;
            margin: 0 auto 2rem;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: scaleIn 0.5s ease 0.2s both;
        }

        @keyframes scaleIn {
            from {
                transform: scale(0);
            }
            to {
                transform: scale(1);
            }
        }

        .success-icon i {
            font-size: 3rem;
            color: white;
        }

        h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
            background: linear-gradient(135deg, #10b981 0%, #34d399 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .message {
            font-size: 1.2rem;
            color: #cbd5e1;
            margin-bottom: 2rem;
            line-height: 1.8;
        }

        .order-info {
            background: #0f172a;
            padding: 1.5rem;
            border-radius: 12px;
            margin-bottom: 2rem;
            border: 1px solid rgba(148, 163, 184, 0.1);
        }

        .order-info p {
            font-size: 1rem;
            color: #94a3b8;
            margin-bottom: 0.5rem;
        }

        .order-id {
            font-size: 1.1rem;
            color: #10b981;
            font-weight: 600;
            margin-top: 0.5rem;
        }

        .btn {
            display: inline-block;
            padding: 1rem 2.5rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 12px;
            font-weight: 600;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            margin: 0.5rem;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }

        .btn-secondary {
            background: rgba(148, 163, 184, 0.2);
        }

        .btn-secondary:hover {
            background: rgba(148, 163, 184, 0.3);
            box-shadow: 0 10px 30px rgba(148, 163, 184, 0.2);
        }

        .features {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid rgba(148, 163, 184, 0.1);
        }

        .features h3 {
            font-size: 1.3rem;
            margin-bottom: 1rem;
            color: #e2e8f0;
        }

        .features ul {
            list-style: none;
            text-align: right;
        }

        .features li {
            padding: 0.5rem 0;
            color: #cbd5e1;
            font-size: 1rem;
        }

        .features li i {
            color: #10b981;
            margin-left: 0.5rem;
        }

        @media (max-width: 768px) {
            .container {
                padding: 2rem;
            }

            h1 {
                font-size: 2rem;
            }

            .message {
                font-size: 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="success-icon">
            <i class="fas fa-check"></i>
        </div>

        <h1>تم الدفع بنجاح!</h1>

        <p class="message">
            شكراً لك على الاشتراك في Social Media Manager.<br>
            تم تفعيل اشتراكك بنجاح ويمكنك الآن الاستمتاع بجميع المزايا.
        </p>

        @if($order_id)
        <div class="order-info">
            <p>رقم العملية:</p>
            <p class="order-id">#{{ $order_id }}</p>
        </div>
        @endif

        <div class="features">
            <h3>ما التالي؟</h3>
            <ul>
                <li><i class="fas fa-check-circle"></i> تم تفعيل حسابك بنجاح</li>
                <li><i class="fas fa-check-circle"></i> يمكنك الآن الوصول لجميع المزايا</li>
                <li><i class="fas fa-check-circle"></i> ابدأ بإدارة حساباتك على وسائل التواصل</li>
                <li><i class="fas fa-check-circle"></i> سيتم إرسال فاتورة على بريدك الإلكتروني</li>
            </ul>
        </div>

        <div style="margin-top: 2rem;">
            <a href="/admin" class="btn">الذهاب للوحة التحكم</a>
            <a href="/" class="btn btn-secondary">العودة للرئيسية</a>
        </div>
    </div>
</body>
</html>
