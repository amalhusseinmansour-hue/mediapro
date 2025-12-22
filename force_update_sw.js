// Service Worker - Force Update Version
'use strict';

// تغيير رقم الإصدار في كل مرة لإجبار التحديث
const CACHE_VERSION = 'v-2025-11-20-14-00';
const CACHE_NAME = 'media-pro-' + CACHE_VERSION;

console.log('🔄 Service Worker Installing:', CACHE_VERSION);

// عند التثبيت: مسح جميع الـ caches القديمة وتفعيل فوري
self.addEventListener('install', (event) => {
  console.log('✅ SW: Installing new version', CACHE_VERSION);

  // تخطي مرحلة الانتظار - تفعيل مباشرة
  self.skipWaiting();

  event.waitUntil(
    caches.keys().then((cacheNames) => {
      console.log('🗑️ Deleting all old caches');
      return Promise.all(
        cacheNames.map((cacheName) => {
          console.log('Deleting cache:', cacheName);
          return caches.delete(cacheName);
        })
      );
    })
  );
});

// عند التفعيل: السيطرة على جميع الصفحات المفتوحة
self.addEventListener('activate', (event) => {
  console.log('✅ SW: Activating', CACHE_VERSION);

  event.waitUntil(
    Promise.all([
      // مسح جميع الـ caches ما عدا الحالي
      caches.keys().then((cacheNames) => {
        return Promise.all(
          cacheNames
            .filter((name) => name !== CACHE_NAME)
            .map((name) => {
              console.log('🗑️ Removing old cache:', name);
              return caches.delete(name);
            })
        );
      }),
      // السيطرة على جميع الصفحات المفتوحة
      self.clients.claim().then(() => {
        console.log('✅ SW: Now controlling all pages');
        // إعادة تحميل جميع الصفحات المفتوحة
        return self.clients.matchAll().then((clients) => {
          clients.forEach((client) => {
            console.log('🔄 Reloading client:', client.url);
            client.postMessage({
              type: 'FORCE_RELOAD',
              version: CACHE_VERSION
            });
          });
        });
      })
    ])
  );
});

// استراتيجية: Network First مع Fallback للـ Cache
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // تجاهل طلبات Chrome Extensions
  if (url.protocol === 'chrome-extension:') {
    return;
  }

  event.respondWith(
    // محاولة جلب من الشبكة أولاً
    fetch(event.request, {
      cache: 'no-cache', // عدم استخدام cache المتصفح
    })
      .then((response) => {
        // حفظ نسخة في الـ cache للاستخدام offline
        if (response.ok && event.request.method === 'GET') {
          const responseClone = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseClone);
          });
        }
        return response;
      })
      .catch(() => {
        // في حالة فشل الشبكة، استخدم الـ cache
        return caches.match(event.request).then((cachedResponse) => {
          if (cachedResponse) {
            console.log('📦 Serving from cache:', event.request.url);
            return cachedResponse;
          }
          // إذا لم يكن في الـ cache، أرجع offline page
          return new Response('Offline - Please check your connection', {
            status: 503,
            statusText: 'Service Unavailable'
          });
        });
      })
  );
});

// استماع لرسائل من الصفحة
self.addEventListener('message', (event) => {
  console.log('📨 SW received message:', event.data);

  if (event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }

  if (event.data.type === 'CLEAR_CACHE') {
    event.waitUntil(
      caches.keys().then((cacheNames) => {
        return Promise.all(
          cacheNames.map((name) => caches.delete(name))
        );
      })
    );
  }
});

console.log('✅ Service Worker loaded successfully:', CACHE_VERSION);
