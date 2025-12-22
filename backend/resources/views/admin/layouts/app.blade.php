<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'لوحة التحكم') - MediaPro Social</title>

    <!-- Bootstrap RTL -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
        }
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(180deg, #1e3c72 0%, #2a5298 100%);
            box-shadow: 2px 0 5px rgba(0,0,0,0.1);
        }
        .sidebar .nav-link {
            color: rgba(255,255,255,0.8);
            padding: 12px 20px;
            margin: 5px 10px;
            border-radius: 8px;
            transition: all 0.3s;
        }
        .sidebar .nav-link:hover,
        .sidebar .nav-link.active {
            background-color: rgba(255,255,255,0.1);
            color: #fff;
        }
        .sidebar .nav-link i {
            width: 25px;
            margin-left: 10px;
        }
        .sidebar .nav-link {
            display: flex;
            align-items: center;
        }
        .sidebar .nav-link .badge {
            margin-right: auto;
            font-size: 10px;
            padding: 3px 8px;
        }
        .sidebar .section-title {
            color: rgba(255,255,255,0.5);
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 600;
        }
        .main-content {
            padding: 30px;
        }
        .stats-card {
            border-radius: 15px;
            border: none;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            transition: transform 0.3s;
        }
        .stats-card:hover {
            transform: translateY(-5px);
        }
        .stats-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        .badge-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
        }
        .table-actions .btn {
            padding: 4px 12px;
            font-size: 13px;
        }
    </style>

    @stack('styles')
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 px-0 sidebar">
                <div class="p-4 text-center border-bottom border-white border-opacity-25">
                    <h4 class="text-white mb-0">MediaPro Social</h4>
                    <small class="text-white-50">لوحة التحكم</small>
                </div>

                <nav class="nav flex-column py-3">
                    <!-- Dashboard -->
                    <a class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}" href="{{ route('admin.dashboard') }}">
                        <i class="fas fa-home"></i> لوحة التحكم
                    </a>

                    <!-- Users Section -->
                    <div class="px-3 mt-3 mb-2">
                        <small class="text-white-50">إدارة المستخدمين</small>
                    </div>

                    <a class="nav-link {{ request()->routeIs('admin.users*') ? 'active' : '' }}" href="{{ route('admin.users.index') }}">
                        <i class="fas fa-users"></i> المستخدمين
                    </a>

                    <!-- Subscriptions & Payments Section -->
                    <div class="px-3 mt-3 mb-2">
                        <small class="text-white-50">الاشتراكات والمدفوعات</small>
                    </div>

                    <a class="nav-link {{ request()->routeIs('admin.subscriptions*') ? 'active' : '' }}" href="#">
                        <i class="fas fa-crown"></i> الاشتراكات
                    </a>

                    <a class="nav-link {{ request()->routeIs('admin.wallets*') ? 'active' : '' }}" href="#">
                        <i class="fas fa-wallet"></i> المحافظ
                    </a>

                    <a class="nav-link {{ request()->routeIs('admin.payments*') ? 'active' : '' }}" href="#">
                        <i class="fas fa-credit-card"></i> المدفوعات
                    </a>

                    <!-- Requests Section -->
                    <div class="px-3 mt-3 mb-2">
                        <small class="text-white-50">إدارة الطلبات</small>
                    </div>

                    <a class="nav-link {{ request()->routeIs('admin.requests.website*') ? 'active' : '' }}" href="{{ route('admin.requests.website') }}">
                        <i class="fas fa-globe"></i> طلبات المواقع
                        @php
                            $websitePending = \App\Models\WebsiteRequest::pending()->count();
                        @endphp
                        @if($websitePending > 0)
                            <span class="badge bg-warning text-dark ms-auto">{{ $websitePending }}</span>
                        @endif
                    </a>

                    <a class="nav-link {{ request()->routeIs('admin.requests.ads*') ? 'active' : '' }}" href="{{ route('admin.requests.ads') }}">
                        <i class="fas fa-ad"></i> الإعلانات الممولة
                        @php
                            $adsPending = \App\Models\SponsoredAdRequest::pending()->count();
                        @endphp
                        @if($adsPending > 0)
                            <span class="badge bg-warning text-dark ms-auto">{{ $adsPending }}</span>
                        @endif
                    </a>

                    <a class="nav-link {{ request()->routeIs('admin.requests.support*') ? 'active' : '' }}" href="{{ route('admin.requests.support') }}">
                        <i class="fas fa-headset"></i> تذاكر الدعم
                        @php
                            $supportOpen = \App\Models\SupportTicket::open()->count();
                        @endphp
                        @if($supportOpen > 0)
                            <span class="badge bg-danger ms-auto">{{ $supportOpen }}</span>
                        @endif
                    </a>

                    <a class="nav-link {{ request()->routeIs('admin.requests.bank-transfers*') ? 'active' : '' }}" href="{{ route('admin.requests.bank-transfers') }}">
                        <i class="fas fa-money-bill-transfer"></i> الشحن البنكي
                        @php
                            $bankPending = \App\Models\BankTransferRequest::pending()->count();
                        @endphp
                        @if($bankPending > 0)
                            <span class="badge bg-info ms-auto">{{ $bankPending }}</span>
                        @endif
                    </a>

                    <!-- Content & Features -->
                    <div class="px-3 mt-3 mb-2">
                        <small class="text-white-50">المحتوى والمميزات</small>
                    </div>

                    <a class="nav-link {{ request()->routeIs('admin.posts*') ? 'active' : '' }}" href="#">
                        <i class="fas fa-file-alt"></i> المنشورات
                    </a>

                    <a class="nav-link {{ request()->routeIs('admin.analytics*') ? 'active' : '' }}" href="#">
                        <i class="fas fa-chart-line"></i> التحليلات
                    </a>

                    <!-- System Settings -->
                    <div class="px-3 mt-3 mb-2">
                        <small class="text-white-50">إعدادات النظام</small>
                    </div>

                    <a class="nav-link {{ request()->routeIs('admin.settings*') ? 'active' : '' }}" href="#">
                        <i class="fas fa-cog"></i> الإعدادات العامة
                    </a>

                    <a class="nav-link {{ request()->routeIs('admin.api-keys*') ? 'active' : '' }}" href="#">
                        <i class="fas fa-key"></i> مفاتيح API
                    </a>

                    <a class="nav-link {{ request()->routeIs('admin.logs*') ? 'active' : '' }}" href="#">
                        <i class="fas fa-list"></i> سجلات النظام
                    </a>

                    <!-- Logout -->
                    <div class="px-3 mt-3 mb-2">
                        <small class="text-white-50">الحساب</small>
                    </div>

                    <a class="nav-link" href="#" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                        <i class="fas fa-sign-out-alt"></i> تسجيل الخروج
                    </a>

                    <form id="logout-form" action="#" method="POST" class="d-none">
                        @csrf
                    </form>
                </nav>
            </div>

            <!-- Main Content -->
            <div class="col-md-9 col-lg-10 main-content">
                <!-- Header -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h2 class="mb-1">@yield('page-title', 'لوحة التحكم')</h2>
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb mb-0">
                                @yield('breadcrumb')
                            </ol>
                        </nav>
                    </div>
                    <div>
                        <span class="text-muted">{{ date('Y-m-d H:i') }}</span>
                    </div>
                </div>

                <!-- Alerts -->
                @if(session('success'))
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i> {{ session('success') }}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                @endif

                @if(session('error'))
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i> {{ session('error') }}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                @endif

                <!-- Page Content -->
                @yield('content')
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    @stack('scripts')
</body>
</html>
