<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $success ? 'تم الربط بنجاح' : 'فشل الربط' }}</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen flex items-center justify-center">
    <div class="max-w-md w-full bg-white rounded-2xl shadow-2xl p-8 text-center">
        @if($success)
            <div class="mb-6">
                <div class="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg class="w-10 h-10 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                    </svg>
                </div>
                <h1 class="text-2xl font-bold text-gray-800 mb-2">تم الربط بنجاح!</h1>
                <p class="text-gray-600">تم ربط حساب {{ ucfirst($platform) }} بنجاح</p>
            </div>
        @else
            <div class="mb-6">
                <div class="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg class="w-10 h-10 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </div>
                <h1 class="text-2xl font-bold text-gray-800 mb-2">فشل الربط</h1>
                <p class="text-gray-600">{{ $message }}</p>
            </div>
        @endif

        <div class="mt-6">
            <p class="text-sm text-gray-500 mb-4">جاري العودة إلى التطبيق...</p>
            <div class="flex justify-center">
                <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>
        </div>

        <div class="mt-8">
            <a href="{{ $deepLink }}" class="text-blue-600 hover:text-blue-700 font-semibold">
                العودة يدوياً إلى التطبيق
            </a>
        </div>
    </div>

    <script>
        // Auto redirect to deep link
        setTimeout(function() {
            window.location.href = '{{ $deepLink }}';

            // Fallback: close window after redirect attempt
            setTimeout(function() {
                window.close();
            }, 1000);
        }, 1500);
    </script>
</body>
</html>
