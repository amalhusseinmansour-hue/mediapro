<x-filament-panels::page>
    <div class="space-y-6">
        {{-- Introduction --}}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h2 class="text-2xl font-bold mb-4">مقدمة</h2>
            <p class="text-gray-600 dark:text-gray-400 mb-4">
                مرحباً بك في توثيق API الخاص بمنصة إدارة وسائل التواصل الاجتماعي. يمكنك استخدام API للوصول إلى جميع ميزات المنصة برمجياً.
            </p>
            <div class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
                <p class="text-sm"><strong>Base URL:</strong> <code class="bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded">{{ config('app.url') }}/api/v1</code></p>
            </div>
        </div>

        {{-- Authentication Methods --}}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h2 class="text-2xl font-bold mb-4">طرق المصادقة</h2>
            <p class="text-gray-600 dark:text-gray-400 mb-4">
                يدعم API طريقتين للمصادقة:
            </p>

            <div class="space-y-4">
                <div class="border dark:border-gray-700 rounded-lg p-4">
                    <h3 class="font-bold text-lg mb-2">1. Bearer Token (Sanctum)</h3>
                    <p class="text-sm text-gray-600 dark:text-gray-400 mb-2">استخدم هذه الطريقة للتطبيقات التي تحتاج إلى تسجيل دخول المستخدمين</p>
                    <pre class="bg-gray-100 dark:bg-gray-700 p-4 rounded-lg overflow-x-auto"><code>Authorization: Bearer {token}</code></pre>
                </div>

                <div class="border dark:border-gray-700 rounded-lg p-4">
                    <h3 class="font-bold text-lg mb-2">2. API Key</h3>
                    <p class="text-sm text-gray-600 dark:text-gray-400 mb-2">استخدم هذه الطريقة للتطبيقات من الخادم إلى الخادم (Server-to-Server)</p>
                    <pre class="bg-gray-100 dark:bg-gray-700 p-4 rounded-lg overflow-x-auto"><code>X-API-Key: sk_your_api_key_here</code></pre>
                    <p class="text-sm text-gray-600 dark:text-gray-400 mt-2">أو كمعامل في URL:</p>
                    <pre class="bg-gray-100 dark:bg-gray-700 p-4 rounded-lg overflow-x-auto"><code>?api_key=sk_your_api_key_here</code></pre>
                </div>
            </div>
        </div>

        {{-- Quick Start --}}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h2 class="text-2xl font-bold mb-4">البدء السريع</h2>

            <h3 class="font-bold text-lg mb-2">1. إنشاء مفتاح API</h3>
            <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
                انتقل إلى <a href="{{ route('filament.admin.resources.api-keys.index') }}" class="text-blue-600 hover:underline">مفاتيح API</a> وقم بإنشاء مفتاح جديد
            </p>

            <h3 class="font-bold text-lg mb-2">2. اختبار المفتاح</h3>
            <pre class="bg-gray-100 dark:bg-gray-700 p-4 rounded-lg overflow-x-auto mb-4"><code>curl -X GET "{{ config('app.url') }}/api/v1/subscription-plans" \
  -H "X-API-Key: sk_your_api_key_here"</code></pre>

            <h3 class="font-bold text-lg mb-2">3. استجابة ناجحة</h3>
            <pre class="bg-gray-100 dark:bg-gray-700 p-4 rounded-lg overflow-x-auto"><code>{
  "data": [
    {
      "id": 1,
      "name": "خطة أساسية",
      "price": 9.99,
      ...
    }
  ]
}</code></pre>
        </div>

        {{-- Common Endpoints --}}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h2 class="text-2xl font-bold mb-4">نقاط النهاية الشائعة (Common Endpoints)</h2>

            <div class="space-y-4">
                <div class="border dark:border-gray-700 rounded-lg p-4">
                    <h3 class="font-bold mb-2">
                        <span class="bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 px-2 py-1 rounded text-sm">GET</span>
                        <code class="ml-2">/subscription-plans</code>
                    </h3>
                    <p class="text-sm text-gray-600 dark:text-gray-400">احصل على قائمة خطط الاشتراك</p>
                </div>

                <div class="border dark:border-gray-700 rounded-lg p-4">
                    <h3 class="font-bold mb-2">
                        <span class="bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200 px-2 py-1 rounded text-sm">POST</span>
                        <code class="ml-2">/subscriptions</code>
                    </h3>
                    <p class="text-sm text-gray-600 dark:text-gray-400">إنشاء اشتراك جديد</p>
                </div>

                <div class="border dark:border-gray-700 rounded-lg p-4">
                    <h3 class="font-bold mb-2">
                        <span class="bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 px-2 py-1 rounded text-sm">GET</span>
                        <code class="ml-2">/pages</code>
                    </h3>
                    <p class="text-sm text-gray-600 dark:text-gray-400">احصل على قائمة الصفحات المنشورة</p>
                </div>

                <div class="border dark:border-gray-700 rounded-lg p-4">
                    <h3 class="font-bold mb-2">
                        <span class="bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 px-2 py-1 rounded text-sm">GET</span>
                        <code class="ml-2">/notifications</code>
                    </h3>
                    <p class="text-sm text-gray-600 dark:text-gray-400">احصل على قائمة الإشعارات (يتطلب مصادقة)</p>
                </div>

                <div class="border dark:border-gray-700 rounded-lg p-4">
                    <h3 class="font-bold mb-2">
                        <span class="bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 px-2 py-1 rounded text-sm">GET</span>
                        <code class="ml-2">/api-keys</code>
                    </h3>
                    <p class="text-sm text-gray-600 dark:text-gray-400">إدارة مفاتيح API الخاصة بك (يتطلب مصادقة)</p>
                </div>
            </div>
        </div>

        {{-- Rate Limiting --}}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h2 class="text-2xl font-bold mb-4">حدود المعدل (Rate Limiting)</h2>
            <p class="text-gray-600 dark:text-gray-400 mb-4">
                كل مفتاح API له حد معدل محدد (افتراضياً 60 طلب/دقيقة). يمكنك تعديل هذا الحد من إعدادات المفتاح.
            </p>
            <div class="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4">
                <p class="text-sm"><strong>ملاحظة:</strong> عند تجاوز الحد، ستتلقى رمز الحالة <code class="bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded">429 Too Many Requests</code></p>
            </div>
        </div>

        {{-- Error Codes --}}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h2 class="text-2xl font-bold mb-4">رموز الأخطاء</h2>
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead>
                    <tr>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">الرمز</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">الوصف</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm"><code>200</code></td>
                        <td class="px-6 py-4 text-sm">نجح الطلب</td>
                    </tr>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm"><code>201</code></td>
                        <td class="px-6 py-4 text-sm">تم إنشاء المورد بنجاح</td>
                    </tr>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm"><code>400</code></td>
                        <td class="px-6 py-4 text-sm">طلب غير صالح</td>
                    </tr>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm"><code>401</code></td>
                        <td class="px-6 py-4 text-sm">غير مصرح (مفتاح API غير صالح أو منتهي)</td>
                    </tr>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm"><code>403</code></td>
                        <td class="px-6 py-4 text-sm">محظور (عنوان IP غير مسموح أو لا توجد صلاحية)</td>
                    </tr>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm"><code>404</code></td>
                        <td class="px-6 py-4 text-sm">المورد غير موجود</td>
                    </tr>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm"><code>422</code></td>
                        <td class="px-6 py-4 text-sm">خطأ في التحقق من البيانات</td>
                    </tr>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm"><code>429</code></td>
                        <td class="px-6 py-4 text-sm">تجاوز حد المعدل</td>
                    </tr>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm"><code>500</code></td>
                        <td class="px-6 py-4 text-sm">خطأ في الخادم</td>
                    </tr>
                </tbody>
            </table>
        </div>

        {{-- Resources Links --}}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h2 class="text-2xl font-bold mb-4">روابط مفيدة</h2>
            <ul class="space-y-2">
                <li>
                    <a href="{{ route('filament.admin.resources.api-keys.index') }}" class="text-blue-600 hover:underline">
                        إدارة مفاتيح API
                    </a>
                </li>
                <li>
                    <a href="{{ route('filament.admin.resources.api-logs.index') }}" class="text-blue-600 hover:underline">
                        عرض سجلات API
                    </a>
                </li>
            </ul>
        </div>
    </div>
</x-filament-panels::page>
