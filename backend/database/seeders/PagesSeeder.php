<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Page;

class PagesSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // حذف الصفحات الموجودة
        Page::truncate();

        $pages = [
            [
                'title' => 'الصفحة الرئيسية',
                'slug' => 'home',
                'content' => '<div class="hero-section" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 80px 20px; color: white; text-align: center; border-radius: 15px; margin-bottom: 40px;">
    <h1 style="font-size: 3rem; font-weight: 700; margin-bottom: 20px;">📱 مرحباً بك في Social Media Manager</h1>
    <p style="font-size: 1.5rem; margin-bottom: 30px; opacity: 0.95;">الحل الشامل لإدارة حساباتك على وسائل التواصل الاجتماعي بكفاءة واحترافية</p>
    <div style="display: flex; gap: 15px; justify-content: center; flex-wrap: wrap;">
        <a href="/register" style="background: white; color: #667eea; padding: 15px 40px; border-radius: 50px; text-decoration: none; font-weight: 600; transition: all 0.3s;">ابدأ الآن مجاناً</a>
        <a href="/about" style="background: rgba(255,255,255,0.2); color: white; padding: 15px 40px; border-radius: 50px; text-decoration: none; font-weight: 600; border: 2px solid white; transition: all 0.3s;">تعرف على المزيد</a>
    </div>
</div>

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin-top: 50px;">
    <div style="background: #f8f9fa; padding: 30px; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.1);">
        <div style="font-size: 3rem; margin-bottom: 15px;">🤖</div>
        <h3 style="font-size: 1.5rem; margin-bottom: 15px; color: #667eea;">ذكاء اصطناعي متقدم</h3>
        <p style="color: #6c757d; line-height: 1.8;">استخدم AI لتوليد محتوى إبداعي، صور، فيديوهات، ونصوص تلقائياً</p>
    </div>

    <div style="background: #f8f9fa; padding: 30px; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.1);">
        <div style="font-size: 3rem; margin-bottom: 15px;">📊</div>
        <h3 style="font-size: 1.5rem; margin-bottom: 15px; color: #667eea;">تحليلات شاملة</h3>
        <p style="color: #6c757d; line-height: 1.8;">تتبع أداء منشوراتك ومعرفة إحصائيات دقيقة عن جمهورك</p>
    </div>

    <div style="background: #f8f9fa; padding: 30px; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.1);">
        <div style="font-size: 3rem; margin-bottom: 15px;">⏰</div>
        <h3 style="font-size: 1.5rem; margin-bottom: 15px; color: #667eea;">جدولة ذكية</h3>
        <p style="color: #6c757d; line-height: 1.8;">جدول منشوراتك مسبقاً على جميع المنصات في أفضل الأوقات</p>
    </div>
</div>',
                'excerpt' => 'الحل الشامل لإدارة حساباتك على وسائل التواصل الاجتماعي',
                'meta_description' => 'أداة شاملة لإدارة وسائل التواصل الاجتماعي مع ذكاء اصطناعي متقدم',
                'meta_keywords' => 'سوشال ميديا، إدارة، ذكاء اصطناعي، تسويق',
                'is_published' => true,
                'show_in_menu' => true,
                'menu_order' => 1,
            ],
            [
                'title' => 'من نحن',
                'slug' => 'about',
                'content' => '<div style="max-width: 800px; margin: 0 auto; padding: 40px 20px;">
    <h1 style="font-size: 2.5rem; color: #667eea; margin-bottom: 30px; text-align: center;">من نحن</h1>

    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; border-radius: 15px; color: white; margin-bottom: 40px; text-align: center;">
        <h2 style="font-size: 2rem; margin-bottom: 20px;">🚀 نساعدك على النجاح في عالم السوشال ميديا</h2>
        <p style="font-size: 1.2rem; line-height: 1.8; opacity: 0.95;">نحن فريق من المتخصصين في التسويق الرقمي والذكاء الاصطناعي، نعمل على تطوير أدوات تساعد الشركات والأفراد على إدارة حساباتهم بكفاءة</p>
    </div>

    <div style="background: #f8f9fa; padding: 30px; border-radius: 15px; margin-bottom: 30px;">
        <h3 style="color: #667eea; margin-bottom: 15px; font-size: 1.8rem;">📖 قصتنا</h3>
        <p style="color: #6c757d; line-height: 1.8; font-size: 1.1rem;">بدأت رحلتنا في عام 2024 عندما أدركنا التحديات التي يواجهها مديرو وسائل التواصل الاجتماعي. قررنا إنشاء منصة تجمع بين سهولة الاستخدام وقوة الذكاء الاصطناعي لتوفير حل شامل ومتكامل.</p>
    </div>

    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-top: 40px;">
        <div style="text-align: center; padding: 20px;">
            <div style="font-size: 3rem; margin-bottom: 10px;">🎯</div>
            <h4 style="color: #667eea; margin-bottom: 10px;">رؤيتنا</h4>
            <p style="color: #6c757d;">أن نكون المنصة الأولى عالمياً في إدارة السوشال ميديا</p>
        </div>
        <div style="text-align: center; padding: 20px;">
            <div style="font-size: 3rem; margin-bottom: 10px;">💡</div>
            <h4 style="color: #667eea; margin-bottom: 10px;">مهمتنا</h4>
            <p style="color: #6c757d;">تسهيل إدارة السوشال ميديا على الجميع</p>
        </div>
        <div style="text-align: center; padding: 20px;">
            <div style="font-size: 3rem; margin-bottom: 10px;">⚡</div>
            <h4 style="color: #667eea; margin-bottom: 10px;">قيمنا</h4>
            <p style="color: #6c757d;">الابتكار، الجودة، والتركيز على العميل</p>
        </div>
    </div>
</div>',
                'excerpt' => 'تعرف على قصتنا ورؤيتنا في تطوير أفضل أداة لإدارة السوشال ميديا',
                'meta_description' => 'من نحن - Social Media Manager - أداة شاملة لإدارة وسائل التواصل الاجتماعي',
                'meta_keywords' => 'من نحن، عن الشركة، فريق العمل',
                'is_published' => true,
                'show_in_menu' => true,
                'menu_order' => 2,
            ],
            [
                'title' => 'سياسة الخصوصية',
                'slug' => 'privacy-policy',
                'content' => '<div style="max-width: 800px; margin: 0 auto; padding: 40px 20px;">
    <h1 style="font-size: 2.5rem; color: #667eea; margin-bottom: 30px;">🔒 سياسة الخصوصية</h1>

    <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 20px; border-radius: 10px; margin-bottom: 30px;">
        <p style="color: #856404; margin: 0; font-weight: 600;">آخر تحديث: يناير 2025</p>
    </div>

    <section style="margin-bottom: 40px;">
        <h2 style="color: #667eea; margin-bottom: 20px; font-size: 1.8rem;">📝 المعلومات التي نجمعها</h2>
        <div style="background: #f8f9fa; padding: 25px; border-radius: 10px; line-height: 1.8;">
            <p style="color: #495057; margin-bottom: 15px;">نحن نجمع المعلومات التالية لتحسين خدماتنا:</p>
            <ul style="color: #6c757d; padding-right: 20px;">
                <li style="margin-bottom: 10px;">معلومات الحساب (الاسم، البريد الإلكتروني)</li>
                <li style="margin-bottom: 10px;">بيانات الاستخدام والتحليلات</li>
                <li style="margin-bottom: 10px;">معلومات الدفع (بشكل آمن ومشفر)</li>
                <li style="margin-bottom: 10px;">محتوى منشوراتك على وسائل التواصل</li>
            </ul>
        </div>
    </section>

    <section style="margin-bottom: 40px;">
        <h2 style="color: #667eea; margin-bottom: 20px; font-size: 1.8rem;">🛡️ كيف نحمي معلوماتك</h2>
        <div style="background: #f8f9fa; padding: 25px; border-radius: 10px; line-height: 1.8;">
            <p style="color: #495057; margin-bottom: 15px;">نستخدم أحدث تقنيات الأمان:</p>
            <ul style="color: #6c757d; padding-right: 20px;">
                <li style="margin-bottom: 10px;">تشفير SSL/TLS لجميع البيانات المنقولة</li>
                <li style="margin-bottom: 10px;">تخزين آمن ومشفر في قواعد البيانات</li>
                <li style="margin-bottom: 10px;">مراقبة أمنية على مدار الساعة</li>
                <li style="margin-bottom: 10px;">نسخ احتياطية منتظمة</li>
            </ul>
        </div>
    </section>

    <section style="margin-bottom: 40px;">
        <h2 style="color: #667eea; margin-bottom: 20px; font-size: 1.8rem;">📊 استخدام المعلومات</h2>
        <div style="background: #f8f9fa; padding: 25px; border-radius: 10px; line-height: 1.8;">
            <p style="color: #495057;">نستخدم معلوماتك فقط لـ:</p>
            <ul style="color: #6c757d; padding-right: 20px;">
                <li style="margin-bottom: 10px;">تقديم خدماتنا وتحسينها</li>
                <li style="margin-bottom: 10px;">التواصل معك بخصوص حسابك</li>
                <li style="margin-bottom: 10px;">معالجة المدفوعات</li>
                <li style="margin-bottom: 10px;">تحليل الاستخدام لتحسين التجربة</li>
            </ul>
        </div>
    </section>

    <section style="margin-bottom: 40px;">
        <h2 style="color: #667eea; margin-bottom: 20px; font-size: 1.8rem;">✅ حقوقك</h2>
        <div style="background: #d1ecf1; padding: 25px; border-radius: 10px; border-left: 4px solid #0dcaf0;">
            <p style="color: #055160; line-height: 1.8;">لديك الحق في:</p>
            <ul style="color: #055160; padding-right: 20px;">
                <li style="margin-bottom: 10px;">الوصول إلى معلوماتك الشخصية</li>
                <li style="margin-bottom: 10px;">تصحيح أو تحديث معلوماتك</li>
                <li style="margin-bottom: 10px;">حذف حسابك ومعلوماتك</li>
                <li style="margin-bottom: 10px;">الاعتراض على معالجة بياناتك</li>
            </ul>
        </div>
    </section>

    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 15px; color: white; text-align: center; margin-top: 40px;">
        <h3 style="margin-bottom: 15px; font-size: 1.5rem;">📧 اتصل بنا</h3>
        <p style="opacity: 0.95; margin-bottom: 10px;">لأي استفسارات حول سياسة الخصوصية:</p>
        <a href="mailto:privacy@socialmediamanager.com" style="color: white; text-decoration: underline; font-weight: 600;">privacy@socialmediamanager.com</a>
    </div>
</div>',
                'excerpt' => 'سياسة الخصوصية وحماية البيانات في Social Media Manager',
                'meta_description' => 'سياسة الخصوصية - تعرف على كيفية حماية بياناتك ومعلوماتك الشخصية',
                'meta_keywords' => 'خصوصية، حماية البيانات، أمان',
                'is_published' => true,
                'show_in_menu' => true,
                'menu_order' => 3,
            ],
            [
                'title' => 'شروط الاستخدام',
                'slug' => 'terms-of-service',
                'content' => '<div style="max-width: 800px; margin: 0 auto; padding: 40px 20px;">
    <h1 style="font-size: 2.5rem; color: #667eea; margin-bottom: 30px;">📋 شروط الاستخدام</h1>

    <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 20px; border-radius: 10px; margin-bottom: 30px;">
        <p style="color: #856404; margin: 0; font-weight: 600;">آخر تحديث: يناير 2025</p>
    </div>

    <section style="margin-bottom: 40px;">
        <h2 style="color: #667eea; margin-bottom: 20px; font-size: 1.8rem;">1. قبول الشروط</h2>
        <div style="background: #f8f9fa; padding: 25px; border-radius: 10px; line-height: 1.8; color: #495057;">
            <p>باستخدام Social Media Manager، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء من هذه الشروط، يُرجى عدم استخدام خدماتنا.</p>
        </div>
    </section>

    <section style="margin-bottom: 40px;">
        <h2 style="color: #667eea; margin-bottom: 20px; font-size: 1.8rem;">2. استخدام الخدمة</h2>
        <div style="background: #f8f9fa; padding: 25px; border-radius: 10px; line-height: 1.8;">
            <p style="color: #495057; margin-bottom: 15px;">يجب عليك:</p>
            <ul style="color: #6c757d; padding-right: 20px;">
                <li style="margin-bottom: 10px;">أن تكون أكبر من 18 عاماً</li>
                <li style="margin-bottom: 10px;">تقديم معلومات صحيحة ودقيقة</li>
                <li style="margin-bottom: 10px;">الحفاظ على سرية حسابك</li>
                <li style="margin-bottom: 10px;">عدم استخدام الخدمة لأغراض غير قانونية</li>
                <li style="margin-bottom: 10px;">احترام حقوق الملكية الفكرية</li>
            </ul>
        </div>
    </section>

    <section style="margin-bottom: 40px;">
        <h2 style="color: #667eea; margin-bottom: 20px; font-size: 1.8rem;">3. الاشتراكات والمدفوعات</h2>
        <div style="background: #f8f9fa; padding: 25px; border-radius: 10px; line-height: 1.8; color: #495057;">
            <ul style="padding-right: 20px;">
                <li style="margin-bottom: 15px;"><strong>الفوترة:</strong> يتم تحصيل الرسوم شهرياً أو سنوياً حسب الخطة</li>
                <li style="margin-bottom: 15px;"><strong>الإلغاء:</strong> يمكنك إلغاء اشتراكك في أي وقت</li>
                <li style="margin-bottom: 15px;"><strong>الاسترداد:</strong> نقدم ضمان استرداد خلال 14 يوماً</li>
                <li style="margin-bottom: 15px;"><strong>التجديد التلقائي:</strong> يتم تجديد الاشتراك تلقائياً</li>
            </ul>
        </div>
    </section>

    <section style="margin-bottom: 40px;">
        <h2 style="color: #667eea; margin-bottom: 20px; font-size: 1.8rem;">4. المحتوى والملكية الفكرية</h2>
        <div style="background: #f8f9fa; padding: 25px; border-radius: 10px; line-height: 1.8; color: #495057;">
            <p style="margin-bottom: 15px;">المحتوى الذي تنشئه يبقى ملكك، لكن:</p>
            <ul style="padding-right: 20px;">
                <li style="margin-bottom: 10px;">تمنحنا ترخيصاً لاستخدامه لتقديم الخدمة</li>
                <li style="margin-bottom: 10px;">يجب أن يكون محتواك قانونياً ولا ينتهك حقوق الآخرين</li>
                <li style="margin-bottom: 10px;">نحتفظ بحق حذف المحتوى المخالف</li>
            </ul>
        </div>
    </section>

    <section style="margin-bottom: 40px;">
        <h2 style="color: #667eea; margin-bottom: 20px; font-size: 1.8rem;">5. إخلاء المسؤولية</h2>
        <div style="background: #f8d7da; padding: 25px; border-radius: 10px; border-left: 4px solid #dc3545; line-height: 1.8; color: #721c24;">
            <p style="margin-bottom: 15px;">الخدمة مقدمة "كما هي" دون أي ضمانات:</p>
            <ul style="padding-right: 20px;">
                <li style="margin-bottom: 10px;">لا نضمن عدم انقطاع الخدمة</li>
                <li style="margin-bottom: 10px;">لا نتحمل مسؤولية فقدان البيانات</li>
                <li style="margin-bottom: 10px;">لا نضمن نتائج استخدام الذكاء الاصطناعي</li>
            </ul>
        </div>
    </section>

    <section style="margin-bottom: 40px;">
        <h2 style="color: #667eea; margin-bottom: 20px; font-size: 1.8rem;">6. التعديلات</h2>
        <div style="background: #f8f9fa; padding: 25px; border-radius: 10px; line-height: 1.8; color: #495057;">
            <p>نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سنقوم بإخطارك بأي تغييرات جوهرية عبر البريد الإلكتروني.</p>
        </div>
    </section>

    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 15px; color: white; text-align: center; margin-top: 40px;">
        <h3 style="margin-bottom: 15px; font-size: 1.5rem;">📧 اتصل بنا</h3>
        <p style="opacity: 0.95; margin-bottom: 10px;">لأي استفسارات حول الشروط:</p>
        <a href="mailto:legal@socialmediamanager.com" style="color: white; text-decoration: underline; font-weight: 600;">legal@socialmediamanager.com</a>
    </div>
</div>',
                'excerpt' => 'شروط وأحكام استخدام منصة Social Media Manager',
                'meta_description' => 'شروط الاستخدام - تعرف على حقوقك والتزاماتك عند استخدام خدماتنا',
                'meta_keywords' => 'شروط الاستخدام، الأحكام، القوانين',
                'is_published' => true,
                'show_in_menu' => true,
                'menu_order' => 4,
            ],
            [
                'title' => 'اتصل بنا',
                'slug' => 'contact',
                'content' => '<div style="max-width: 800px; margin: 0 auto; padding: 40px 20px;">
    <h1 style="font-size: 2.5rem; color: #667eea; margin-bottom: 30px; text-align: center;">📞 اتصل بنا</h1>

    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; border-radius: 15px; color: white; margin-bottom: 40px; text-align: center;">
        <h2 style="font-size: 2rem; margin-bottom: 20px;">نحن هنا لمساعدتك! 💬</h2>
        <p style="font-size: 1.2rem; line-height: 1.8; opacity: 0.95;">سواء كان لديك سؤال، اقتراح، أو تحتاج إلى دعم فني، فريقنا جاهز للرد عليك</p>
    </div>

    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 25px; margin-bottom: 40px;">
        <div style="background: #f8f9fa; padding: 30px; border-radius: 15px; text-align: center; box-shadow: 0 5px 15px rgba(0,0,0,0.1);">
            <div style="font-size: 3rem; margin-bottom: 15px;">📧</div>
            <h3 style="color: #667eea; margin-bottom: 10px;">البريد الإلكتروني</h3>
            <a href="mailto:support@socialmediamanager.com" style="color: #6c757d; text-decoration: none;">support@socialmediamanager.com</a>
            <p style="color: #adb5bd; font-size: 0.9rem; margin-top: 10px;">نرد خلال 24 ساعة</p>
        </div>

        <div style="background: #f8f9fa; padding: 30px; border-radius: 15px; text-align: center; box-shadow: 0 5px 15px rgba(0,0,0,0.1);">
            <div style="font-size: 3rem; margin-bottom: 15px;">💬</div>
            <h3 style="color: #667eea; margin-bottom: 10px;">الدردشة المباشرة</h3>
            <p style="color: #6c757d;">متاح من 9 صباحاً - 6 مساءً</p>
            <button style="background: #667eea; color: white; padding: 10px 25px; border: none; border-radius: 25px; margin-top: 10px; cursor: pointer;">ابدأ المحادثة</button>
        </div>

        <div style="background: #f8f9fa; padding: 30px; border-radius: 15px; text-align: center; box-shadow: 0 5px 15px rgba(0,0,0,0.1);">
            <div style="font-size: 3rem; margin-bottom: 15px;">📱</div>
            <h3 style="color: #667eea; margin-bottom: 10px;">الهاتف</h3>
            <a href="tel:+966123456789" style="color: #6c757d; text-decoration: none; font-weight: 600;">+966 12 345 6789</a>
            <p style="color: #adb5bd; font-size: 0.9rem; margin-top: 10px;">من السبت إلى الخميس</p>
        </div>
    </div>

    <div style="background: #f8f9fa; padding: 40px; border-radius: 15px; margin-bottom: 40px;">
        <h2 style="color: #667eea; margin-bottom: 25px; text-align: center;">📍 مواقعنا</h2>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 25px;">
            <div style="padding: 20px;">
                <h4 style="color: #667eea; margin-bottom: 10px;">🇸🇦 الرياض</h4>
                <p style="color: #6c757d; line-height: 1.6;">
                    طريق الملك فهد<br>
                    حي العليا<br>
                    الرياض 12211، المملكة العربية السعودية
                </p>
            </div>
            <div style="padding: 20px;">
                <h4 style="color: #667eea; margin-bottom: 10px;">🇦🇪 دبي</h4>
                <p style="color: #6c757d; line-height: 1.6;">
                    برج خليفة<br>
                    وسط مدينة دبي<br>
                    دبي، الإمارات العربية المتحدة
                </p>
            </div>
            <div style="padding: 20px;">
                <h4 style="color: #667eea; margin-bottom: 10px;">🇪🇬 القاهرة</h4>
                <p style="color: #6c757d; line-height: 1.6;">
                    مدينة نصر<br>
                    التجمع الأول<br>
                    القاهرة، مصر
                </p>
            </div>
        </div>
    </div>

    <div style="background: #d1ecf1; padding: 30px; border-radius: 15px; border-left: 4px solid #0dcaf0; margin-bottom: 40px;">
        <h3 style="color: #055160; margin-bottom: 15px;">❓ الأسئلة الشائعة</h3>
        <p style="color: #055160; line-height: 1.8;">قبل التواصل معنا، ننصحك بزيارة صفحة <a href="/faq" style="color: #0dcaf0; font-weight: 600;">الأسئلة الشائعة</a> قد تجد إجابتك هناك!</p>
    </div>

    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; border-radius: 15px; color: white; text-align: center;">
        <h3 style="font-size: 1.8rem; margin-bottom: 20px;">تابعنا على وسائل التواصل 🌟</h3>
        <div style="display: flex; gap: 20px; justify-content: center; flex-wrap: wrap; margin-top: 20px;">
            <a href="#" style="background: rgba(255,255,255,0.2); padding: 15px 30px; border-radius: 10px; color: white; text-decoration: none; font-weight: 600;">Facebook</a>
            <a href="#" style="background: rgba(255,255,255,0.2); padding: 15px 30px; border-radius: 10px; color: white; text-decoration: none; font-weight: 600;">Twitter</a>
            <a href="#" style="background: rgba(255,255,255,0.2); padding: 15px 30px; border-radius: 10px; color: white; text-decoration: none; font-weight: 600;">Instagram</a>
            <a href="#" style="background: rgba(255,255,255,0.2); padding: 15px 30px; border-radius: 10px; color: white; text-decoration: none; font-weight: 600;">LinkedIn</a>
        </div>
    </div>
</div>',
                'excerpt' => 'تواصل معنا - نحن هنا لمساعدتك في أي وقت',
                'meta_description' => 'اتصل بنا - فريق الدعم جاهز للإجابة على استفساراتك ومساعدتك',
                'meta_keywords' => 'اتصل بنا، دعم، خدمة العملاء',
                'is_published' => true,
                'show_in_menu' => true,
                'menu_order' => 5,
            ],
            [
                'title' => 'الأسعار والخطط',
                'slug' => 'pricing',
                'content' => '<div style="max-width: 1200px; margin: 0 auto; padding: 40px 20px;">
    <h1 style="font-size: 2.5rem; color: #667eea; margin-bottom: 20px; text-align: center;">💎 الأسعار والخطط</h1>
    <p style="text-align: center; color: #6c757d; font-size: 1.2rem; margin-bottom: 50px;">اختر الخطة المناسبة لك وابدأ في تطوير عملك</p>

    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin-bottom: 50px;">
        <!-- Free Plan -->
        <div style="background: #f8f9fa; padding: 35px; border-radius: 20px; box-shadow: 0 5px 20px rgba(0,0,0,0.1); border: 2px solid transparent; transition: all 0.3s;">
            <div style="text-align: center; margin-bottom: 25px;">
                <h3 style="color: #667eea; font-size: 1.8rem; margin-bottom: 10px;">🆓 المجانية</h3>
                <div style="font-size: 3rem; font-weight: 700; color: #667eea; margin: 20px 0;">$0</div>
                <p style="color: #6c757d;">مجاناً للأبد</p>
            </div>
            <ul style="list-style: none; padding: 0; margin-bottom: 25px;">
                <li style="padding: 12px 0; color: #495057; border-bottom: 1px solid #dee2e6;">✅ 5 منشورات شهرياً</li>
                <li style="padding: 12px 0; color: #495057; border-bottom: 1px solid #dee2e6;">✅ حساب واحد</li>
                <li style="padding: 12px 0; color: #495057; border-bottom: 1px solid #dee2e6;">✅ تحليلات أساسية</li>
                <li style="padding: 12px 0; color: #adb5bd; border-bottom: 1px solid #dee2e6;">❌ AI محدود</li>
                <li style="padding: 12px 0; color: #adb5bd;">❌ جدولة متقدمة</li>
            </ul>
            <button style="width: 100%; background: #667eea; color: white; padding: 15px; border: none; border-radius: 10px; font-size: 1.1rem; font-weight: 600; cursor: pointer;">ابدأ مجاناً</button>
        </div>

        <!-- Pro Plan -->
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 35px; border-radius: 20px; box-shadow: 0 10px 30px rgba(102,126,234,0.4); transform: scale(1.05); position: relative;">
            <div style="position: absolute; top: -15px; right: 20px; background: #ffc107; color: #000; padding: 8px 20px; border-radius: 20px; font-weight: 700; font-size: 0.9rem;">الأكثر شعبية 🔥</div>
            <div style="text-align: center; margin-bottom: 25px; color: white;">
                <h3 style="font-size: 1.8rem; margin-bottom: 10px;">⭐ المحترف</h3>
                <div style="font-size: 3rem; font-weight: 700; margin: 20px 0;">$29</div>
                <p style="opacity: 0.9;">شهرياً</p>
            </div>
            <ul style="list-style: none; padding: 0; margin-bottom: 25px; color: white;">
                <li style="padding: 12px 0; border-bottom: 1px solid rgba(255,255,255,0.2);">✅ منشورات غير محدودة</li>
                <li style="padding: 12px 0; border-bottom: 1px solid rgba(255,255,255,0.2);">✅ 10 حسابات</li>
                <li style="padding: 12px 0; border-bottom: 1px solid rgba(255,255,255,0.2);">✅ تحليلات متقدمة</li>
                <li style="padding: 12px 0; border-bottom: 1px solid rgba(255,255,255,0.2);">✅ AI كامل</li>
                <li style="padding: 12px 0;">✅ جدولة ذكية</li>
            </ul>
            <button style="width: 100%; background: white; color: #667eea; padding: 15px; border: none; border-radius: 10px; font-size: 1.1rem; font-weight: 600; cursor: pointer;">ابدأ تجربة 14 يوم</button>
        </div>

        <!-- Enterprise Plan -->
        <div style="background: #f8f9fa; padding: 35px; border-radius: 20px; box-shadow: 0 5px 20px rgba(0,0,0,0.1); border: 2px solid #667eea;">
            <div style="text-align: center; margin-bottom: 25px;">
                <h3 style="color: #667eea; font-size: 1.8rem; margin-bottom: 10px;">🏢 الشركات</h3>
                <div style="font-size: 3rem; font-weight: 700; color: #667eea; margin: 20px 0;">$99</div>
                <p style="color: #6c757d;">شهرياً</p>
            </div>
            <ul style="list-style: none; padding: 0; margin-bottom: 25px;">
                <li style="padding: 12px 0; color: #495057; border-bottom: 1px solid #dee2e6;">✅ كل ميزات Pro</li>
                <li style="padding: 12px 0; color: #495057; border-bottom: 1px solid #dee2e6;">✅ حسابات غير محدودة</li>
                <li style="padding: 12px 0; color: #495057; border-bottom: 1px solid #dee2e6;">✅ فريق عمل (5-20 مستخدم)</li>
                <li style="padding: 12px 0; color: #495057; border-bottom: 1px solid #dee2e6;">✅ دعم مخصص</li>
                <li style="padding: 12px 0; color: #495057;">✅ API مخصص</li>
            </ul>
            <button style="width: 100%; background: #667eea; color: white; padding: 15px; border: none; border-radius: 10px; font-size: 1.1rem; font-weight: 600; cursor: pointer;">اتصل بنا</button>
        </div>
    </div>

    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; border-radius: 20px; color: white; text-align: center; margin-top: 50px;">
        <h2 style="font-size: 2rem; margin-bottom: 20px;">💡 جميع الخطط تشمل:</h2>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 30px;">
            <div>
                <div style="font-size: 2rem; margin-bottom: 10px;">🔒</div>
                <p>أمان وحماية بيانات</p>
            </div>
            <div>
                <div style="font-size: 2rem; margin-bottom: 10px;">🚀</div>
                <p>تحديثات مجانية</p>
            </div>
            <div>
                <div style="font-size: 2rem; margin-bottom: 10px;">📧</div>
                <p>دعم عبر البريد</p>
            </div>
            <div>
                <div style="font-size: 2rem; margin-bottom: 10px;">💰</div>
                <p>ضمان الاسترداد</p>
            </div>
        </div>
    </div>
</div>',
                'excerpt' => 'اختر الخطة المناسبة لاحتياجاتك من بين خططنا المتنوعة',
                'meta_description' => 'الأسعار والخطط - خطط مرنة تناسب جميع الاحتياجات',
                'meta_keywords' => 'أسعار، خطط، اشتراكات',
                'is_published' => true,
                'show_in_menu' => true,
                'menu_order' => 6,
            ],
        ];

        foreach ($pages as $page) {
            Page::create($page);
        }

        $this->command->info('✅ تم إنشاء ' . count($pages) . ' صفحة بنجاح!');
    }
}
