// Service Worker للمسح الكامل للـ Cache وإجبار التحديث
'use strict';

const CACHE_VERSION = 'v2-' + Date.now(); // إصدار جديد في كل مرة
const CACHE_NAME = 'social-media-manager-' + CACHE_VERSION;

console.log('🔄 Service Worker: Installing new version', CACHE_VERSION);

// عند التثبيت: امسح جميع الـ caches القديمة
self.addEventListener('install', (event) => {
  console.log('✅ Service Worker: Installing...');

  // تخطي مرحلة الانتظار وتفعيل مباشرة
  self.skipWaiting();

  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          console.log('🗑️ Deleting old cache:', cacheName);
          return caches.delete(cacheName);
        })
      );
    })
  );
});

// عند التفعيل: تحكم في جميع الـ clients
self.addEventListener('activate', (event) => {
  console.log('✅ Service Worker: Activating...');

  event.waitUntil(
    Promise.all([
      // امسح جميع الـ caches القديمة
      caches.keys().then((cacheNames) => {
        return Promise.all(
          cacheNames
            .filter((cacheName) => cacheName !== CACHE_NAME)
            .map((cacheName) => {
              console.log('🗑️ Deleting cache:', cacheName);
              return caches.delete(cacheName);
            })
        );
      }),
      // تحكم في جميع الصفحات المفتوحة
      self.clients.claim()
    ])
  );
});

// عند جلب البيانات: Network First (لا cache)
self.addEventListener('fetch', (event) => {
  // استخدم الشبكة دائماً للحصول على آخر إصدار
  event.respondWith(
    fetch(event.request)
      .catch(() => {
        // في حالة فشل الشبكة، حاول من الـ cache
        return caches.match(event.request);
      })
  );
});

console.log('✅ Service Worker: Loaded successfully');
