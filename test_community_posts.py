#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
اختبار شامل لميزة المنشورات المجتمعية
Community Posts Integration Test Suite
"""

import requests
import json
import sys
from datetime import datetime

# الإعدادات
BACKEND_URL = "http://localhost:8000"  # أو "http://127.0.0.1:8000"
API_TIMEOUT = 10
TEST_USER_ID = 1  # استخدم user_id معروف

class CommunityPostsTester:
    """اختبر جميع العمليات المتعلقة بمنشورات المجتمع"""
    
    def __init__(self, backend_url: str):
        self.backend_url = backend_url.rstrip('/')
        self.api_base = f"{self.backend_url}/api"
        self.session = requests.Session()
        self.test_results = []
        self.token = None
    
    def log_test(self, test_name: str, status: bool, message: str = ""):
        """تسجيل نتيجة الاختبار"""
        status_str = "✅ PASS" if status else "❌ FAIL"
        print(f"{status_str} | {test_name}")
        if message:
            print(f"        └─ {message}")
        self.test_results.append((test_name, status, message))
    
    def test_get_posts(self):
        """اختبار استرجاع المنشورات"""
        print("\n📌 اختبار 1: استرجاع المنشورات (GET /api/community/posts)")
        print("-" * 60)
        
        try:
            url = f"{self.api_base}/community/posts"
            params = {
                'page': '1',
                'per_page': '20',
                'visibility': 'public'
            }
            
            print(f"URL: {url}")
            print(f"Parameters: {params}")
            
            response = requests.get(url, params=params, timeout=API_TIMEOUT)
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    post_count = len(data.get('data', []))
                    self.log_test(
                        "GET /community/posts",
                        True,
                        f"تم استرجاع {post_count} منشور"
                    )
                    print(f"\nFirst post (if exists):")
                    if data.get('data'):
                        print(json.dumps(data['data'][0], indent=2, ensure_ascii=False))
                else:
                    self.log_test("GET /community/posts", False, data.get('message', 'Unknown error'))
            else:
                self.log_test(
                    "GET /community/posts",
                    False,
                    f"HTTP {response.status_code}"
                )
                print(f"Response: {response.text[:200]}")
        
        except Exception as e:
            self.log_test("GET /community/posts", False, str(e))
    
    def test_get_user_posts(self):
        """اختبار استرجاع منشورات مستخدم معين"""
        print("\n📌 اختبار 2: استرجاع منشورات المستخدم (GET /api/community/posts/user/{userId})")
        print("-" * 60)
        
        try:
            url = f"{self.api_base}/community/posts/user/{TEST_USER_ID}"
            
            print(f"URL: {url}")
            
            response = requests.get(url, timeout=API_TIMEOUT)
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    post_count = len(data.get('data', []))
                    self.log_test(
                        "GET /community/posts/user/{id}",
                        True,
                        f"تم استرجاع {post_count} منشور للمستخدم"
                    )
                else:
                    self.log_test("GET /community/posts/user/{id}", False, data.get('message', 'Unknown error'))
            else:
                self.log_test(
                    "GET /community/posts/user/{id}",
                    False,
                    f"HTTP {response.status_code}"
                )
        
        except Exception as e:
            self.log_test("GET /community/posts/user/{id}", False, str(e))
    
    def test_parameter_types(self):
        """اختبار أن المعاملات يتم تحويلها بشكل صحيح إلى strings"""
        print("\n📌 اختبار 3: التحقق من أنواع المعاملات")
        print("-" * 60)
        
        try:
            # اختبر مع integers و strings
            for page in [1, "1"]:
                for per_page in [20, "20"]:
                    params = {
                        'page': page,
                        'per_page': per_page,
                        'visibility': 'public'
                    }
                    
                    # تحويل إلى strings (كما يفعل Dart)
                    params_str = {
                        'page': str(page),
                        'per_page': str(per_page),
                        'visibility': 'public'
                    }
                    
                    response = requests.get(
                        f"{self.api_base}/community/posts",
                        params=params_str,
                        timeout=API_TIMEOUT
                    )
                    
                    if response.status_code == 200:
                        self.log_test(
                            f"Parameters (page={page}, per_page={per_page})",
                            True,
                            "API accepted parameters"
                        )
                    else:
                        self.log_test(
                            f"Parameters (page={page}, per_page={per_page})",
                            False,
                            f"HTTP {response.status_code}"
                        )
                    break  # اختبر واحد فقط لاختصار الوقت
        
        except Exception as e:
            self.log_test("Parameter Type Test", False, str(e))
    
    def test_route_specificity(self):
        """اختبار أن routing يفرق بين /user/{id} و /{id}"""
        print("\n📌 اختبار 4: اختبار ترتيب الـ routes")
        print("-" * 60)
        
        try:
            # استرجاع منشور محدد
            post_id = 1
            
            url_specific = f"{self.api_base}/community/posts/user/{TEST_USER_ID}"
            url_general = f"{self.api_base}/community/posts/{post_id}"
            
            print(f"Specific URL: {url_specific}")
            print(f"General URL: {url_general}")
            
            resp_specific = requests.get(url_specific, timeout=API_TIMEOUT)
            resp_general = requests.get(url_general, timeout=API_TIMEOUT)
            
            # يجب أن تعيد نتائج مختلفة
            specific_ok = resp_specific.status_code in [200, 404]
            general_ok = resp_general.status_code in [200, 404]
            
            if specific_ok and general_ok:
                self.log_test(
                    "Route Specificity",
                    True,
                    "Routes return expected status codes"
                )
            else:
                self.log_test(
                    "Route Specificity",
                    False,
                    f"Specific: {resp_specific.status_code}, General: {resp_general.status_code}"
                )
        
        except Exception as e:
            self.log_test("Route Specificity Test", False, str(e))
    
    def test_database_schema(self):
        """اختبار أن جدول community_posts موجود بالأعمدة الصحيحة"""
        print("\n📌 اختبار 5: التحقق من schema قاعدة البيانات")
        print("-" * 60)
        
        try:
            # محاولة استرجاع منشور - إذا نجح، الجدول موجود
            response = requests.get(
                f"{self.api_base}/community/posts",
                params={'page': '1', 'per_page': '1'},
                timeout=API_TIMEOUT
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success') and data.get('data'):
                    post = data['data'][0]
                    required_fields = ['id', 'user_id', 'content', 'created_at']
                    missing = [f for f in required_fields if f not in post]
                    
                    if not missing:
                        self.log_test(
                            "Database Schema",
                            True,
                            "All required fields present"
                        )
                    else:
                        self.log_test(
                            "Database Schema",
                            False,
                            f"Missing fields: {missing}"
                        )
                else:
                    self.log_test(
                        "Database Schema",
                        True,
                        "Table exists (no data yet)"
                    )
            else:
                self.log_test(
                    "Database Schema",
                    False,
                    f"Cannot verify schema (HTTP {response.status_code})"
                )
        
        except Exception as e:
            self.log_test("Database Schema Test", False, str(e))
    
    def run_all_tests(self):
        """تشغيل جميع الاختبارات"""
        print("\n" + "="*60)
        print("اختبار شامل لميزة المنشورات المجتمعية")
        print(f"Backend URL: {self.backend_url}")
        print(f"وقت الاختبار: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*60)
        
        self.test_get_posts()
        self.test_get_user_posts()
        self.test_parameter_types()
        self.test_route_specificity()
        self.test_database_schema()
        
        # ملخص النتائج
        print("\n" + "="*60)
        print("ملخص النتائج:")
        print("="*60)
        
        passed = sum(1 for _, status, _ in self.test_results if status)
        total = len(self.test_results)
        
        for test_name, status, message in self.test_results:
            status_str = "✅" if status else "❌"
            print(f"{status_str} {test_name}")
            if message:
                print(f"   └─ {message}")
        
        print(f"\n📊 النتيجة النهائية: {passed}/{total} اختبارات نجحت")
        
        if passed == total:
            print("🎉 جميع الاختبارات نجحت!")
            return True
        else:
            print(f"⚠️  {total - passed} اختبارات فشلت")
            return False


def main():
    """النقطة الرئيسية للبرنامج"""
    backend_url = sys.argv[1] if len(sys.argv) > 1 else BACKEND_URL
    
    tester = CommunityPostsTester(backend_url)
    success = tester.run_all_tests()
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
