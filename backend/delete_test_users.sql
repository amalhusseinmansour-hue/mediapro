-- حذف المستخدمين التجريبيين
DELETE FROM users
WHERE is_admin = 0
AND (
    phone_number LIKE '+966540224811%'
    OR email LIKE '%test%'
    OR email LIKE '%example.com%'
    OR name LIKE 'User %'
    OR name LIKE 'Test %'
);

-- عرض عدد المستخدمين المتبقيين
SELECT
    COUNT(*) as total_users,
    SUM(CASE WHEN is_admin = 1 THEN 1 ELSE 0 END) as admin_users,
    SUM(CASE WHEN is_admin = 0 THEN 1 ELSE 0 END) as regular_users
FROM users;
