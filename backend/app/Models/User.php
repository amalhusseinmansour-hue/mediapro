<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Filament\Models\Contracts\FilamentUser;
use Filament\Models\Contracts\HasAvatar;
use Filament\Panel;

class User extends Authenticatable implements FilamentUser, HasAvatar
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'user_type',
        'phone_number',
        'is_phone_verified',
        'is_admin',
        'role_id',
        'type_of_audience',
        'audience_demographics',
        'content_preferences',
        'profile_picture',
        'bio',
        'company_name',
        'business_type',
        'facebook_url',
        'instagram_url',
        'twitter_url',
        'linkedin_url',
        'is_active',
        'last_login_at',
        'fcm_tokens',
        'two_factor_enabled',
        'two_factor_secret',
        'two_factor_recovery_codes',
        'two_factor_confirmed_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'is_admin', // نفضل إخفاء هذه القيمة والاعتماد على الأدوار
        'two_factor_secret',
        'two_factor_recovery_codes',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'is_phone_verified' => 'boolean',
        'is_active' => 'boolean',
        'last_login_at' => 'datetime',
        'audience_demographics' => 'array',
        'content_preferences' => 'array',
        'fcm_tokens' => 'array',
        'two_factor_enabled' => 'boolean',
        'two_factor_confirmed_at' => 'datetime',
    ];

    /**
     * Determine if the user can access the Filament panel.
     */
    public function canAccessPanel(Panel $panel): bool
    {
        // السماح للمستخدمين النشطين الذين لديهم دور 'admin' أو 'super_admin' بالدخول
        // أو إذا كانوا is_admin = true أو user_type = 'admin'
        if (!$this->is_active) {
            return false;
        }

        // التحقق من is_admin أولاً (للتوافقية مع الكود القديم)
        if ($this->is_admin === true) {
            return true;
        }

        // التحقق من user_type
        if ($this->user_type === 'admin' || $this->user_type === 'super_admin') {
            return true;
        }

        // التحقق من الأدوار (إذا كان جدول role_user موجود)
        try {
            return $this->hasAnyRole(['admin', 'super_admin']);
        } catch (\Exception $e) {
            // إذا حدث خطأ (مثلاً الجدول غير موجود)، نرجع false
            return false;
        }
    }

    public function getFilamentAvatarUrl(): ?string
    {
        return $this->profile_picture;
    }

    /**
     * العلاقة مع الاشتراكات
     */
    public function subscriptions()
    {
        return $this->hasMany(\App\Models\Subscription::class);
    }

    /**
     * العلاقة مع المدفوعات
     */
    public function payments()
    {
        return $this->hasMany(\App\Models\Payment::class);
    }

    /**
     * العلاقة مع حسابات التواصل الاجتماعي المتصلة
     */
    public function connectedAccounts(): HasMany
    {
        return $this->hasMany(ConnectedAccount::class);
    }

    /**
     * العلاقة مع المحفظة
     */
    public function wallet()
    {
        return $this->hasOne(Wallet::class);
    }

    /**
     * العلاقة مع منشورات السوشال ميديا
     */
    public function socialMediaPosts(): HasMany
    {
        return $this->hasMany(SocialMediaPost::class);
    }

    /**
     * العلاقة مع توليدات AI
     */
    public function aiGenerations(): HasMany
    {
        return $this->hasMany(AiGeneration::class);
    }

    /**
     * العلاقة مع توليدات الفيديو
     */
    public function videoGenerations(): HasMany
    {
        return $this->hasMany(VideoGeneration::class);
    }

    /**
     * العلاقة مع المنشورات
     */
    public function posts()
    {
        return $this->hasMany(\App\Models\Post::class);
    }

    /**
     * العلاقة مع مفاتيح API
     */
    public function apiKeys()
    {
        return $this->hasMany(\App\Models\Notification::class);
    }

    /**
     * الحصول على الاشتراك النشط
     */
    public function activeSubscription()
    {
        return $this->hasOne(\App\Models\Subscription::class)
            ->where('status', 'active')
            ->latest();
    }

    /**
     * العلاقة مع Brand Kits
     */
    public function brandKits()
    {
        return $this->hasMany(\App\Models\BrandKit::class);
    }

    /**
     * العلاقة مع Telegram Connections
     */
    public function telegramConnections()
    {
        return $this->hasMany(\App\Models\TelegramConnection::class);
    }

    /**
     * الحصول على اتصال Telegram النشط
     */
    public function activeTelegramConnection()
    {
        return $this->hasOne(\App\Models\TelegramConnection::class)
            ->where('is_active', true)
            ->latest();
    }

    /**
     * الحصول على Brand Kit الافتراضي
     */
    public function defaultBrandKit()
    {
        return $this->hasOne(\App\Models\BrandKit::class)
            ->where('is_default', true);
    }

    /**
     * العلاقة مع حسابات السوشال ميديا
     */
    public function socialAccounts()
    {
        return $this->hasMany(\App\Models\SocialAccount::class);
    }

    /**
     * الحصول على حسابات السوشال ميديا النشطة
     */
    public function activeSocialAccounts()
    {
        return $this->hasMany(\App\Models\SocialAccount::class)
            ->where('is_active', true);
    }

    /**
     * العلاقة مع الدور الافتراضي
     */
    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    /**
     * العلاقة مع الأدوار (many-to-many)
     */
    public function roles()
    {
        return $this->belongsToMany(Role::class, 'role_user')
            ->withTimestamps();
    }

    /**
     * منح دور للمستخدم
     */
    public function assignRole($role): void
    {
        if (is_string($role)) {
            $role = Role::where('name', $role)->firstOrFail();
        }

        $this->roles()->syncWithoutDetaching($role);
    }

    /**
     * إزالة دور من المستخدم
     */
    public function removeRole($role): void
    {
        if (is_string($role)) {
            $role = Role::where('name', $role)->first();
        }

        if ($role) {
            $this->roles()->detach($role);
        }
    }

    /**
     * التحقق من وجود دور
     */
    public function hasRole($role): bool
    {
        if (is_string($role)) {
            return $this->roles()->where('name', $role)->exists();
        }

        return $this->roles()->where('id', $role->id)->exists();
    }

    /**
     * التحقق من وجود أي دور من المصفوفة
     */
    public function hasAnyRole(array $roles): bool
    {
        foreach ($roles as $role) {
            if ($this->hasRole($role)) {
                return true;
            }
        }

        return false;
    }

    /**
     * التحقق من وجود صلاحية
     */
    public function hasPermission(string $permission): bool
    {
        // التحقق من الصلاحيات عبر الأدوار
        foreach ($this->roles as $role) {
            if ($role->hasPermission($permission)) {
                return true;
            }
        }

        // التحقق من الدور الافتراضي
        if ($this->role && $this->role->hasPermission($permission)) {
            return true;
        }

        return false;
    }

    /**
     * التحقق من وجود أي صلاحية من المصفوفة
     */
    public function hasAnyPermission(array $permissions): bool
    {
        foreach ($permissions as $permission) {
            if ($this->hasPermission($permission)) {
                return true;
            }
        }

        return false;
    }

    /**
     * التحقق من وجود جميع الصلاحيات
     */
    public function hasAllPermissions(array $permissions): bool
    {
        foreach ($permissions as $permission) {
            if (!$this->hasPermission($permission)) {
                return false;
            }
        }

        return true;
    }

    /**
     * الحصول على جميع الصلاحيات للمستخدم
     */
    public function getAllPermissions(): array
    {
        $permissions = collect();

        // الصلاحيات من الأدوار
        foreach ($this->roles as $role) {
            $permissions = $permissions->merge($role->permissions);
        }

        // الصلاحيات من الدور الافتراضي
        if ($this->role) {
            $permissions = $permissions->merge($this->role->permissions);
        }

        return $permissions->pluck('name')->unique()->toArray();
    }
}
