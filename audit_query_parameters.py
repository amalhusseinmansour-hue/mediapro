#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
فاحص Query Parameters - يتحقق من جميع الـ services
Query Parameters Audit Script
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple

class QueryParametersAuditor:
    """فحص جميع الـ services للتأكد من تحويل parameters إلى strings"""
    
    def __init__(self, services_dir: str):
        self.services_dir = Path(services_dir)
        self.issues = []
        self.fixed = []
    
    def check_file(self, file_path: Path) -> List[Tuple[int, str, str]]:
        """فحص ملف واحد للمشاكل"""
        issues = []
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.split('\n')
            
            # ابحث عن queryParameters
            for i, line in enumerate(lines, 1):
                if 'queryParameters' in line:
                    # تحقق من السطور التالية (حتى 5 سطور)
                    context = '\n'.join(lines[i-1:min(i+4, len(lines))])
                    
                    # ابحث عن integers بدون toString()
                    # أنماط يجب أن ننتبه لها
                    patterns = [
                        (r"'page':\s*page[^.]", "page parameter is not converted to string"),
                        (r"'per_page':\s*perPage[^.]", "per_page parameter is not converted to string"),
                        (r"'limit':\s*limit[^.]", "limit parameter is not converted to string"),
                        (r"'offset':\s*offset[^.]", "offset parameter is not converted to string"),
                        (r"'page':\s*\d+[^.]", "page is hardcoded as integer"),
                        (r"'per_page':\s*\d+[^.]", "per_page is hardcoded as integer"),
                    ]
                    
                    for pattern, description in patterns:
                        if re.search(pattern, context):
                            issues.append((i, description, context[:100]))
        
        except Exception as e:
            print(f"⚠️  Error reading {file_path}: {e}")
        
        return issues
    
    def audit_all_services(self):
        """فحص جميع ملفات الـ services"""
        print("🔍 فحص جميع الـ services للتأكد من تحويل parameters إلى strings")
        print("=" * 70)
        print()
        
        service_files = list(self.services_dir.glob('*.dart'))
        
        if not service_files:
            print("❌ لم تجد أي ملفات .dart في المجلد")
            return
        
        print(f"📂 وجد {len(service_files)} ملف service")
        print()
        
        for service_file in sorted(service_files):
            issues = self.check_file(service_file)
            
            if issues:
                print(f"⚠️  {service_file.name}")
                for line_num, description, context in issues:
                    print(f"   └─ السطر {line_num}: {description}")
                    self.issues.append((service_file.name, line_num, description))
            else:
                print(f"✅ {service_file.name}")
        
        print()
        print("=" * 70)
        
        if self.issues:
            print(f"⚠️  وجد {len(self.issues)} مشكلة محتملة")
            print()
            print("المشاكل:")
            for file_name, line_num, description in self.issues:
                print(f"  - {file_name}:{line_num} - {description}")
        else:
            print("✅ جميع الملفات تبدو جيدة!")
        
        return len(self.issues) == 0


def main():
    services_dir = "lib/services"
    
    if not os.path.exists(services_dir):
        print(f"❌ المجلد {services_dir} غير موجود")
        print("تأكد أنك في مجلد المشروع الصحيح")
        return 1
    
    auditor = QueryParametersAuditor(services_dir)
    success = auditor.audit_all_services()
    
    return 0 if success else 1


if __name__ == "__main__":
    import sys
    sys.exit(main())
