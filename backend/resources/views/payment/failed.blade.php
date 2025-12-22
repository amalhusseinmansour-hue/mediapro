<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>فشل الدفع - Social Media Manager</title>
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

        .error-icon {
            width: 100px;
            height: 100px;
            margin: 0 auto 2rem;
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
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

        .error-icon i {
            font-size: 3rem;
            color: white;
        }

        h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
            background: linear-gradient(135deg, #ef4444 0%, #f87171 100%);
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
            color: #ef4444;
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

        .reasons {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid rgba(148, 163, 184, 0.1);
        }

        .reasons h3 {
            font-size: 1.3rem;
            margin-bottom: 1rem;
            color: #e2e8f0;
        }

        .reasons ul {
            list-style: none;
            text-align: right;
        }

        .reasons li {
            padding: 0.5rem 0;
            color: #cbd5e1;
            font-size: 1rem;
        }

        .reasons li i {
            color: #f59e0b;
            margin-left: 0.5rem;
        }

        .support-box {
            background: rgba(102, 126, 234, 0.1);
            padding: 1.5rem;
            border-radius: 12px;
            margin-top: 2rem;
            border: 1px solid rgba(102, 126, 234, 0.2);
        }

        .support-box h4 {
            color: #667eea;
            margin-bottom: 0.5rem;
        }

        .support-box p {
            color: #cbd5e1;
            font-size: 0.95rem;
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
        <div class="error-icon">
            <i class="fas fa-times"></i>
        </div>

        <h1>فشل الدفع</h1>

        <p class="message">
            عذراً، لم تتم عملية الدفع بنجاح.<br>
            يرجى المحاولة مرة أخرى أو التواصل مع الدعم الفني.
        </p>

        @if($order_id)
        <div class="order-info">
            <p>رقم العملية:</p>
            <p class="order-id">#{{ $order_id }}</p>
        </div>
        @endif

        <div class="reasons">
            <h3>الأسباب المحتملة</h3>
            <ul>
                <li><i class="fas fa-exclamation-circle"></i> رصيد غير كافٍ في البطاقة</li>
                <li><i class="fas fa-exclamation-circle"></i> معلومات البطاقة غير صحيحة</li>
                <li><i class="fas fa-exclamation-circle"></i> انتهاء صلاحية البطاقة</li>
                <li><i class="fas fa-exclamation-circle"></i> رفض البنك للعملية</li>
                <li><i class="fas fa-exclamation-circle"></i> مشكلة في الاتصال بالإنترنت</li>
            </ul>
        </div>

        <div style="margin-top: 2rem;">
            <a href="/pricing" class="btn">المحاولة مرة أخرى</a>
            <a href="/" class="btn btn-secondary">العودة للرئيسية</a>
        </div>

        <div class="support-box">
            <h4><i class="fas fa-headset"></i> تحتاج مساعدة؟</h4>
            <p>فريق الدعم الفني متاح على مدار الساعة لمساعدتك</p>
            <p style="margin-top: 0.5rem;">
                <i class="fas fa-envelope"></i> support@socialmanager.com<br>
                <i class="fas fa-phone"></i> +966 50 123 4567
            </p>
        </div>
    </div>
</body>
</html>
