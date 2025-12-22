/**
 * PWA Setup and Configuration
 * يدير جميع جوانب Progressive Web App
 */

class PWAManager {
  constructor() {
    this.deferredPrompt = null;
    this.isInstalledAsApp = false;
    this.init();
  }

  /**
   * Initialize PWA Manager
   */
  async init() {
    console.log('🚀 PWA Manager initializing...');

    // Check if running as installed app
    this.checkIfInstalledAsApp();

    // Register service worker
    await this.registerServiceWorker();

    // Setup install prompt
    this.setupInstallPrompt();

    // Setup update checker
    this.setupUpdateChecker();

    // Setup offline handling
    this.setupOfflineHandling();

    // Setup notifications
    this.setupNotifications();

    // Setup shortcuts
    this.setupShortcuts();

    console.log('✅ PWA Manager initialized successfully');
  }

  /**
   * Check if app is installed
   */
  checkIfInstalledAsApp() {
    // Check if display mode is standalone (installed as app)
    if (window.matchMedia('(display-mode: standalone)').matches) {
      this.isInstalledAsApp = true;
      document.body.classList.add('is-installed-app');
      console.log('📱 App is installed (standalone mode)');
    }

    // iOS check
    if (window.navigator.standalone === true) {
      this.isInstalledAsApp = true;
      document.body.classList.add('is-installed-app');
      console.log('🍎 App is installed on iOS');
    }

    // Listen for display mode changes
    window.matchMedia('(display-mode: standalone)').addEventListener('change', (e) => {
      this.isInstalledAsApp = e.matches;
      console.log('📱 Display mode changed:', e.matches);
    });
  }

  /**
   * Register Service Worker
   */
  async registerServiceWorker() {
    if (!('serviceWorker' in navigator)) {
      console.warn('⚠️ Service Worker not supported in this browser');
      return;
    }

    try {
      const registration = await navigator.serviceWorker.register('/sw.js', {
        scope: '/',
      });

      console.log('✅ Service Worker registered:', registration.scope);

      // Listen for updates
      this.setupUpdateNotifier(registration);

      // Listen for controller change
      navigator.serviceWorker.addEventListener('controllerchange', () => {
        console.log('🔄 New Service Worker took control');
        this.showUpdateNotification();
      });

      return registration;
    } catch (error) {
      console.error('❌ Service Worker registration failed:', error);
    }
  }

  /**
   * Setup install prompt
   */
  setupInstallPrompt() {
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault();
      this.deferredPrompt = e;

      // Show install prompt after app is loaded
      this.showInstallPrompt();
    });

    window.addEventListener('appinstalled', () => {
      console.log('✅ PWA installed successfully');
      this.handleAppInstalled();
    });
  }

  /**
   * Show install prompt
   */
  showInstallPrompt() {
    const installPrompt = document.getElementById('install-prompt');
    const installBtn = document.getElementById('install-btn');
    const dismissBtn = document.getElementById('dismiss-btn');

    if (!installPrompt) return;

    // Check if already dismissed
    const dismissed = localStorage.getItem('pwa-install-dismissed');
    if (dismissed) {
      console.log('⏭️  PWA install prompt dismissed');
      return;
    }

    // Show after 5 seconds
    setTimeout(() => {
      installPrompt.style.display = 'block';
      console.log('📱 Showing PWA install prompt');
    }, 5000);

    // Install button
    installBtn?.addEventListener('click', async () => {
      if (!this.deferredPrompt) return;

      installPrompt.style.display = 'none';
      this.deferredPrompt.prompt();

      const { outcome } = await this.deferredPrompt.userChoice;
      console.log(`👤 User response: ${outcome}`);

      if (outcome === 'accepted') {
        console.log('✅ PWA installation accepted');
      }

      this.deferredPrompt = null;
    });

    // Dismiss button
    dismissBtn?.addEventListener('click', () => {
      installPrompt.style.display = 'none';
      localStorage.setItem('pwa-install-dismissed', 'true');

      // Reset after 7 days
      setTimeout(() => {
        localStorage.removeItem('pwa-install-dismissed');
      }, 7 * 24 * 60 * 60 * 1000);
    });
  }

  /**
   * Setup update notification
   */
  setupUpdateNotifier(registration) {
    // Check for updates every hour
    setInterval(() => {
      registration.update();
    }, 60 * 60 * 1000);

    registration.addEventListener('updatefound', () => {
      const newWorker = registration.installing;
      console.log('🔄 New Service Worker found');

      newWorker.addEventListener('statechange', () => {
        if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
          this.showUpdateAvailable();
        }
      });
    });
  }

  /**
   * Show update available notification
   */
  showUpdateAvailable() {
    console.log('✨ New version available');

    // Send message to Service Worker to update
    if (navigator.serviceWorker.controller) {
      const updateContainer = document.createElement('div');
      updateContainer.id = 'update-notification';
      updateContainer.innerHTML = `
        <div style="
          position: fixed;
          bottom: 80px;
          left: 50%;
          transform: translateX(-50%);
          background: linear-gradient(135deg, #00D9FF, #7928CA);
          padding: 15px 25px;
          border-radius: 50px;
          box-shadow: 0 10px 30px rgba(0, 217, 255, 0.3);
          z-index: 10000;
          animation: slideUp 0.5s ease;
          font-family: 'Cairo', sans-serif;
        ">
          <button id="update-now-btn" style="
            background: white;
            color: #7928CA;
            border: none;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: bold;
            cursor: pointer;
            margin: 0 5px;
            font-family: 'Cairo', sans-serif;
          ">تحديث الآن 🔄</button>
        </div>
      `;

      document.body.appendChild(updateContainer);

      document.getElementById('update-now-btn')?.addEventListener('click', () => {
        navigator.serviceWorker.controller.postMessage({
          type: 'SKIP_WAITING',
        });
        updateContainer.remove();
        window.location.reload();
      });
    }
  }

  /**
   * Show update notification
   */
  showUpdateNotification() {
    const notification = document.createElement('div');
    notification.innerHTML = `
      <div style="
        position: fixed;
        top: 20px;
        right: 20px;
        background: linear-gradient(135deg, #00D9FF, #7928CA);
        padding: 15px 25px;
        border-radius: 10px;
        box-shadow: 0 10px 30px rgba(0, 217, 255, 0.3);
        z-index: 10001;
        font-family: 'Cairo', sans-serif;
        color: white;
        animation: slideIn 0.5s ease;
      ">
        ✅ تم التحديث إلى أحدث نسخة
      </div>
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
      notification.remove();
    }, 3000);
  }

  /**
   * Handle app installed
   */
  handleAppInstalled() {
    this.isInstalledAsApp = true;
    document.body.classList.add('is-installed-app');

    // Track installation
    if ('gtag' in window) {
      gtag('event', 'pwa_installed', {
        'event_category': 'engagement',
      });
    }

    // Hide install prompt
    const installPrompt = document.getElementById('install-prompt');
    if (installPrompt) {
      installPrompt.style.display = 'none';
    }
  }

  /**
   * Setup offline handling
   */
  setupOfflineHandling() {
    window.addEventListener('online', () => {
      console.log('🌐 Back online');
      this.handleOnline();
    });

    window.addEventListener('offline', () => {
      console.log('📴 Offline mode activated');
      this.handleOffline();
    });

    // Check initial online status
    if (!navigator.onLine) {
      this.handleOffline();
    }
  }

  /**
   * Handle online event
   */
  handleOnline() {
    document.body.classList.remove('is-offline');

    // Sync any pending data
    if ('serviceWorker' in navigator && 'SyncManager' in window) {
      navigator.serviceWorker.ready.then((registration) => {
        registration.sync.register('sync-posts');
      });
    }
  }

  /**
   * Handle offline event
   */
  handleOffline() {
    document.body.classList.add('is-offline');

    // Show offline notification
    const notification = document.createElement('div');
    notification.innerHTML = `
      <div style="
        position: fixed;
        bottom: 20px;
        left: 50%;
        transform: translateX(-50%);
        background: #FF6B6B;
        padding: 15px 25px;
        border-radius: 50px;
        z-index: 10001;
        font-family: 'Cairo', sans-serif;
        color: white;
      ">
        📴 أنت في وضع غير متصل - البيانات المخزنة محليا فقط
      </div>
    `;

    document.body.appendChild(notification);
  }

  /**
   * Setup notifications
   */
  async setupNotifications() {
    if (!('Notification' in window)) {
      console.warn('⚠️ Notifications not supported');
      return;
    }

    // Request permission if needed
    if (Notification.permission === 'default') {
      const permission = await Notification.requestPermission();
      console.log('🔔 Notification permission:', permission);
    }

    // Request Push permission
    if ('serviceWorker' in navigator && 'PushManager' in window) {
      try {
        const registration = await navigator.serviceWorker.ready;
        const subscription = await registration.pushManager.getSubscription();

        if (!subscription) {
          console.log('🔔 Push notifications available');
        }
      } catch (error) {
        console.error('❌ Push notification setup failed:', error);
      }
    }
  }

  /**
   * Setup shortcuts
   */
  setupShortcuts() {
    if (!('shortcuts' in navigator)) {
      return;
    }

    const shortcuts = [
      {
        name: 'منشور جديد',
        description: 'إنشاء منشور جديد',
        icon: '/icons/Icon-192.png',
        url: '/?action=new_post',
      },
      {
        name: 'لوحة التحكم',
        description: 'الذهاب إلى لوحة التحكم',
        icon: '/icons/Icon-192.png',
        url: '/?action=dashboard',
      },
      {
        name: 'جدولة المنشورات',
        description: 'عرض المنشورات المجدولة',
        icon: '/icons/Icon-192.png',
        url: '/?action=schedule',
      },
      {
        name: 'التحليلات',
        description: 'عرض التحليلات والإحصائيات',
        icon: '/icons/Icon-192.png',
        url: '/?action=analytics',
      },
    ];

    // This would require manifest update and backend support
    console.log('⌨️ App shortcuts configured:', shortcuts.length);
  }

  /**
   * Request persistent storage
   */
  async requestPersistentStorage() {
    if (!navigator.storage || !navigator.storage.persist) {
      console.warn('⚠️ Persistent Storage API not supported');
      return;
    }

    try {
      const isPersisted = await navigator.storage.persist();
      console.log('💾 Persistent Storage:', isPersisted ? '✅' : '❌');
      return isPersisted;
    } catch (error) {
      console.error('❌ Persistent Storage request failed:', error);
    }
  }

  /**
   * Get storage quota
   */
  async getStorageQuota() {
    if (!navigator.storage || !navigator.storage.estimate) {
      return null;
    }

    try {
      const estimate = await navigator.storage.estimate();
      const percentUsed = Math.round((estimate.usage / estimate.quota) * 100);

      console.log(`💾 Storage: ${percentUsed}% used (${Math.round(estimate.usage / 1024 / 1024)}MB / ${Math.round(estimate.quota / 1024 / 1024)}MB)`);

      return {
        usage: estimate.usage,
        quota: estimate.quota,
        percentUsed: percentUsed,
      };
    } catch (error) {
      console.error('❌ Storage quota check failed:', error);
    }
  }

  /**
   * Get app info
   */
  getAppInfo() {
    return {
      isInstalledAsApp: this.isInstalledAsApp,
      isOnline: navigator.onLine,
      hasPushSupport: 'PushManager' in window,
      hasNotificationSupport: 'Notification' in window,
      hasServiceWorkerSupport: 'serviceWorker' in navigator,
      notificationPermission: Notification.permission,
      userAgent: navigator.userAgent,
    };
  }

  /**
   * Log app info
   */
  logAppInfo() {
    const info = this.getAppInfo();
    console.log('📱 App Info:', info);
    return info;
  }
}

// Initialize PWA Manager when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    window.pwaManager = new PWAManager();
  });
} else {
  window.pwaManager = new PWAManager();
}
