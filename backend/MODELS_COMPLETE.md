# Models الكاملة مع العلاقات

## Models البنية الكاملة

### 1. User Model

```php
<?php
// app/Models/User.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'avatar',
        'subscription_type',
        'subscription_status',
        'subscription_start_date',
        'subscription_end_date',
        'company_name',
        'company_size',
        'timezone',
        'language',
        'preferences',
        'last_login_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'subscription_start_date' => 'datetime',
        'subscription_end_date' => 'datetime',
        'last_login_at' => 'datetime',
        'preferences' => 'array',
        'password' => 'hashed',
    ];

    // Relationships
    public function subscriptions()
    {
        return $this->hasMany(Subscription::class);
    }

    public function currentSubscription()
    {
        return $this->hasOne(Subscription::class)
            ->where('status', 'active')
            ->latest();
    }

    public function socialAccounts()
    {
        return $this->hasMany(SocialAccount::class);
    }

    public function posts()
    {
        return $this->hasMany(Post::class);
    }

    public function aiRequests()
    {
        return $this->hasMany(AIRequest::class);
    }

    public function analytics()
    {
        return $this->hasMany(Analytics::class);
    }

    public function activityLogs()
    {
        return $this->hasMany(ActivityLog::class);
    }

    public function contentTemplates()
    {
        return $this->hasMany(ContentTemplate::class);
    }

    public function media()
    {
        return $this->hasMany(Media::class);
    }

    // Accessors
    public function getIsSubscriptionActiveAttribute(): bool
    {
        return $this->subscription_status === 'active' &&
               $this->subscription_end_date &&
               $this->subscription_end_date->isFuture();
    }

    public function getIsCompanyAccountAttribute(): bool
    {
        return $this->subscription_type === 'company';
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('subscription_status', 'active');
    }

    public function scopeCompany($query)
    {
        return $query->where('subscription_type', 'company');
    }

    public function scopeIndividual($query)
    {
        return $query->where('subscription_type', 'individual');
    }
}
```

### 2. Subscription Model

```php
<?php
// app/Models/Subscription.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subscription extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'plan_type',
        'plan_name',
        'price',
        'currency',
        'billing_cycle',
        'features',
        'limits',
        'status',
        'started_at',
        'expires_at',
        'auto_renew',
        'payment_method',
        'transaction_id',
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'expires_at' => 'datetime',
        'features' => 'array',
        'limits' => 'array',
        'price' => 'decimal:2',
        'auto_renew' => 'boolean',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Accessors
    public function getIsActiveAttribute(): bool
    {
        return $this->status === 'active' &&
               $this->expires_at &&
               $this->expires_at->isFuture();
    }

    public function getIsExpiredAttribute(): bool
    {
        return $this->expires_at && $this->expires_at->isPast();
    }

    public function getRemainingDaysAttribute(): int
    {
        if (!$this->expires_at) {
            return 0;
        }
        return max(0, now()->diffInDays($this->expires_at, false));
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('status', 'active')
            ->where('expires_at', '>', now());
    }

    public function scopeExpiringSoon($query, $days = 7)
    {
        return $query->where('status', 'active')
            ->whereBetween('expires_at', [now(), now()->addDays($days)]);
    }

    // Methods
    public function canUsePlatforms($count): bool
    {
        $limit = $this->limits['accounts_limit'] ?? 0;
        return $count <= $limit;
    }

    public function canCreatePosts($count): bool
    {
        $limit = $this->limits['posts_limit'] ?? 0;
        return $count <= $limit;
    }

    public function canUseAI($count): bool
    {
        $limit = $this->limits['ai_requests_limit'] ?? 0;
        return $count <= $limit;
    }
}
```

### 3. SocialAccount Model

```php
<?php
// app/Models/SocialAccount.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Crypt;

class SocialAccount extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'platform',
        'account_name',
        'account_username',
        'account_id',
        'access_token',
        'refresh_token',
        'token_expires_at',
        'profile_picture_url',
        'followers_count',
        'is_active',
        'last_sync_at',
        'settings',
        'capabilities',
    ];

    protected $casts = [
        'token_expires_at' => 'datetime',
        'last_sync_at' => 'datetime',
        'is_active' => 'boolean',
        'settings' => 'array',
        'capabilities' => 'array',
        'followers_count' => 'integer',
    ];

    protected $hidden = [
        'access_token',
        'refresh_token',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function postSchedules()
    {
        return $this->hasMany(PostSchedule::class);
    }

    public function analytics()
    {
        return $this->hasMany(Analytics::class);
    }

    // Accessors & Mutators
    public function setAccessTokenAttribute($value)
    {
        $this->attributes['access_token'] = Crypt::encryptString($value);
    }

    public function getAccessTokenAttribute($value)
    {
        return Crypt::decryptString($value);
    }

    public function setRefreshTokenAttribute($value)
    {
        if ($value) {
            $this->attributes['refresh_token'] = Crypt::encryptString($value);
        }
    }

    public function getRefreshTokenAttribute($value)
    {
        return $value ? Crypt::decryptString($value) : null;
    }

    public function getIsTokenExpiredAttribute(): bool
    {
        return $this->token_expires_at && $this->token_expires_at->isPast();
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopePlatform($query, $platform)
    {
        return $query->where('platform', $platform);
    }

    public function scopeNeedsSync($query, $hours = 24)
    {
        return $query->where('is_active', true)
            ->where(function($q) use ($hours) {
                $q->whereNull('last_sync_at')
                  ->orWhere('last_sync_at', '<', now()->subHours($hours));
            });
    }
}
```

### 4. Post Model

```php
<?php
// app/Models/Post.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Post extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'title',
        'content',
        'media_urls',
        'media_type',
        'post_type',
        'status',
        'scheduled_at',
        'published_at',
        'platforms',
        'platform_specific_content',
        'ai_generated',
        'ai_prompt',
        'ai_service',
        'hashtags',
        'mentions',
        'location',
        'engagement_metrics',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
        'published_at' => 'datetime',
        'media_urls' => 'array',
        'platforms' => 'array',
        'platform_specific_content' => 'array',
        'ai_generated' => 'boolean',
        'hashtags' => 'array',
        'mentions' => 'array',
        'engagement_metrics' => 'array',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function schedules()
    {
        return $this->hasMany(PostSchedule::class);
    }

    public function analytics()
    {
        return $this->hasMany(Analytics::class);
    }

    // Accessors
    public function getIsScheduledAttribute(): bool
    {
        return $this->status === 'scheduled' &&
               $this->scheduled_at &&
               $this->scheduled_at->isFuture();
    }

    public function getIsPublishedAttribute(): bool
    {
        return $this->status === 'published';
    }

    public function getTotalEngagementAttribute(): int
    {
        $metrics = $this->engagement_metrics ?? [];
        return ($metrics['likes'] ?? 0) +
               ($metrics['comments'] ?? 0) +
               ($metrics['shares'] ?? 0);
    }

    public function getFormattedContentAttribute(): string
    {
        $content = $this->content;

        // Add hashtags if present
        if ($this->hashtags) {
            $content .= "\n\n" . implode(' ', array_map(fn($tag) => "#{$tag}", $this->hashtags));
        }

        return $content;
    }

    // Scopes
    public function scopeDraft($query)
    {
        return $query->where('status', 'draft');
    }

    public function scopeScheduled($query)
    {
        return $query->where('status', 'scheduled')
            ->where('scheduled_at', '>', now());
    }

    public function scopePublished($query)
    {
        return $query->where('status', 'published');
    }

    public function scopeReadyToPublish($query)
    {
        return $query->where('status', 'scheduled')
            ->where('scheduled_at', '<=', now());
    }

    public function scopeAiGenerated($query)
    {
        return $query->where('ai_generated', true);
    }
}
```

### 5. PostSchedule Model

```php
<?php
// app/Models/PostSchedule.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PostSchedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'post_id',
        'social_account_id',
        'scheduled_at',
        'published_at',
        'platform_post_id',
        'platform_post_url',
        'status',
        'error_message',
        'retry_count',
        'next_retry_at',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
        'published_at' => 'datetime',
        'next_retry_at' => 'datetime',
        'retry_count' => 'integer',
    ];

    // Relationships
    public function post()
    {
        return $this->belongsTo(Post::class);
    }

    public function socialAccount()
    {
        return $this->belongsTo(SocialAccount::class);
    }

    // Accessors
    public function getIsPublishedAttribute(): bool
    {
        return $this->status === 'published';
    }

    public function getCanRetryAttribute(): bool
    {
        return $this->status === 'failed' && $this->retry_count < 3;
    }

    // Scopes
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeReadyToPublish($query)
    {
        return $query->where('status', 'pending')
            ->where('scheduled_at', '<=', now());
    }

    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    public function scopePublished($query)
    {
        return $query->where('status', 'published');
    }
}
```

### 6. AIRequest Model

```php
<?php
// app/Models/AIRequest.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AIRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'request_type',
        'ai_service',
        'prompt',
        'parameters',
        'response',
        'tokens_used',
        'cost',
        'status',
        'error_message',
        'completed_at',
    ];

    protected $casts = [
        'parameters' => 'array',
        'tokens_used' => 'integer',
        'cost' => 'decimal:4',
        'completed_at' => 'datetime',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Accessors
    public function getIsCompletedAttribute(): bool
    {
        return $this->status === 'completed';
    }

    public function getIsFailedAttribute(): bool
    {
        return $this->status === 'failed';
    }

    // Scopes
    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    public function scopeByService($query, $service)
    {
        return $query->where('ai_service', $service);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('request_type', $type);
    }
}
```

### 7. Analytics Model

```php
<?php
// app/Models/Analytics.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Analytics extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'social_account_id',
        'post_id',
        'metric_type',
        'metric_value',
        'date',
        'platform',
        'additional_data',
    ];

    protected $casts = [
        'date' => 'date',
        'metric_value' => 'integer',
        'additional_data' => 'array',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function socialAccount()
    {
        return $this->belongsTo(SocialAccount::class);
    }

    public function post()
    {
        return $this->belongsTo(Post::class);
    }

    // Scopes
    public function scopeByMetric($query, $metric)
    {
        return $query->where('metric_type', $metric);
    }

    public function scopeByPlatform($query, $platform)
    {
        return $query->where('platform', $platform);
    }

    public function scopeDateRange($query, $start, $end)
    {
        return $query->whereBetween('date', [$start, $end]);
    }

    public function scopeLatest($query, $days = 30)
    {
        return $query->where('date', '>=', now()->subDays($days));
    }
}
```

### 8. ActivityLog Model

```php
<?php
// app/Models/ActivityLog.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ActivityLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'action',
        'model_type',
        'model_id',
        'description',
        'properties',
        'ip_address',
        'user_agent',
    ];

    protected $casts = [
        'properties' => 'array',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function subject()
    {
        return $this->morphTo('model');
    }

    // Scopes
    public function scopeByAction($query, $action)
    {
        return $query->where('action', $action);
    }

    public function scopeRecent($query, $hours = 24)
    {
        return $query->where('created_at', '>=', now()->subHours($hours));
    }
}
```

### 9. ContentTemplate Model

```php
<?php
// app/Models/ContentTemplate.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ContentTemplate extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'content',
        'category',
        'tags',
        'default_platforms',
        'is_public',
        'usage_count',
    ];

    protected $casts = [
        'tags' => 'array',
        'default_platforms' => 'array',
        'is_public' => 'boolean',
        'usage_count' => 'integer',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Methods
    public function incrementUsage()
    {
        $this->increment('usage_count');
    }

    // Scopes
    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    public function scopePopular($query, $limit = 10)
    {
        return $query->orderBy('usage_count', 'desc')->limit($limit);
    }
}
```

### 10. Media Model

```php
<?php
// app/Models/Media.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Media extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'file_name',
        'mime_type',
        'path',
        'size',
        'width',
        'height',
        'duration',
        'metadata',
        'type',
        'thumbnail_path',
    ];

    protected $casts = [
        'metadata' => 'array',
        'size' => 'integer',
        'width' => 'integer',
        'height' => 'integer',
        'duration' => 'integer',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Accessors
    public function getUrlAttribute(): string
    {
        return Storage::url($this->path);
    }

    public function getThumbnailUrlAttribute(): ?string
    {
        return $this->thumbnail_path ? Storage::url($this->thumbnail_path) : null;
    }

    public function getHumanSizeAttribute(): string
    {
        $units = ['B', 'KB', 'MB', 'GB'];
        $size = $this->size;
        $unit = 0;

        while ($size >= 1024 && $unit < count($units) - 1) {
            $size /= 1024;
            $unit++;
        }

        return round($size, 2) . ' ' . $units[$unit];
    }

    // Scopes
    public function scopeImages($query)
    {
        return $query->where('type', 'image');
    }

    public function scopeVideos($query)
    {
        return $query->where('type', 'video');
    }

    // Methods
    public function delete()
    {
        // Delete physical files
        Storage::delete($this->path);
        if ($this->thumbnail_path) {
            Storage::delete($this->thumbnail_path);
        }

        return parent::delete();
    }
}
```

## استخدام Models

### مثال على استخدام العلاقات

```php
// الحصول على جميع المنشورات للمستخدم مع الحسابات المرتبطة
$user = User::with(['posts.schedules.socialAccount'])->find(1);

// الحصول على الإحصائيات للحسابات الاجتماعية
$analytics = $user->socialAccounts()
    ->with(['analytics' => function($query) {
        $query->dateRange(now()->subDays(30), now());
    }])
    ->get();

// إنشاء منشور جديد
$post = $user->posts()->create([
    'content' => 'محتوى المنشور',
    'platforms' => ['facebook', 'instagram'],
    'status' => 'draft',
]);

// جدولة المنشور
$post->schedules()->create([
    'social_account_id' => 1,
    'scheduled_at' => now()->addHours(2),
    'status' => 'pending',
]);
```

---

تم إنشاء جميع الـ Models بشكل كامل!
