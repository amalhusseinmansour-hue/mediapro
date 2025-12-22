@extends('admin.layouts.app')

@section('title', 'لوحة التحكم')
@section('page-title', 'لوحة التحكم')

@section('breadcrumb')
    <li class="breadcrumb-item active">الرئيسية</li>
@endsection

@section('content')
    <!-- Statistics Cards -->
    <div class="row g-4 mb-4">
        <!-- Users Card -->
        <div class="col-md-6 col-lg-3">
            <div class="card stats-card">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <p class="text-muted mb-1">إجمالي المستخدمين</p>
                            <h3 class="mb-0">{{ number_format($stats['users']['total']) }}</h3>
                            <small class="text-success">
                                <i class="fas fa-arrow-up"></i> {{ $stats['users']['new_today'] }} اليوم
                            </small>
                        </div>
                        <div class="stats-icon bg-primary bg-opacity-10 text-primary">
                            <i class="fas fa-users"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Active Subscriptions Card -->
        <div class="col-md-6 col-lg-3">
            <div class="card stats-card">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <p class="text-muted mb-1">الاشتراكات النشطة</p>
                            <h3 class="mb-0">{{ number_format($stats['subscriptions']['active']) }}</h3>
                            <small class="text-muted">
                                من {{ number_format($stats['subscriptions']['total']) }} إجمالي
                            </small>
                        </div>
                        <div class="stats-icon bg-success bg-opacity-10 text-success">
                            <i class="fas fa-crown"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Wallet Balance Card -->
        <div class="col-md-6 col-lg-3">
            <div class="card stats-card">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <p class="text-muted mb-1">رصيد المحافظ</p>
                            <h3 class="mb-0">{{ number_format($stats['wallets']['total_balance'], 2) }}</h3>
                            <small class="text-muted">
                                {{ number_format($stats['wallets']['total_transactions']) }} معاملة
                            </small>
                        </div>
                        <div class="stats-icon bg-warning bg-opacity-10 text-warning">
                            <i class="fas fa-wallet"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Revenue Card -->
        <div class="col-md-6 col-lg-3">
            <div class="card stats-card">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <p class="text-muted mb-1">الإيرادات الشهرية</p>
                            <h3 class="mb-0">{{ number_format($stats['revenue']['this_month'], 2) }}</h3>
                            <small class="text-muted">
                                {{ number_format($stats['revenue']['total'], 2) }} إجمالي
                            </small>
                        </div>
                        <div class="stats-icon bg-info bg-opacity-10 text-info">
                            <i class="fas fa-dollar-sign"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Pending Requests -->
    <div class="row g-4 mb-4">
        <div class="col-lg-12">
            <div class="card">
                <div class="card-header bg-white">
                    <h5 class="mb-0">الطلبات المعلقة</h5>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-3">
                            <div class="d-flex align-items-center p-3 bg-light rounded">
                                <div class="me-3">
                                    <i class="fas fa-globe fa-2x text-primary"></i>
                                </div>
                                <div>
                                    <h4 class="mb-0">{{ $stats['requests']['website_pending'] }}</h4>
                                    <small class="text-muted">طلبات مواقع</small>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-3">
                            <div class="d-flex align-items-center p-3 bg-light rounded">
                                <div class="me-3">
                                    <i class="fas fa-ad fa-2x text-success"></i>
                                </div>
                                <div>
                                    <h4 class="mb-0">{{ $stats['requests']['ads_pending'] }}</h4>
                                    <small class="text-muted">إعلانات ممولة</small>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-3">
                            <div class="d-flex align-items-center p-3 bg-light rounded">
                                <div class="me-3">
                                    <i class="fas fa-headset fa-2x text-warning"></i>
                                </div>
                                <div>
                                    <h4 class="mb-0">{{ $stats['requests']['support_open'] }}</h4>
                                    <small class="text-muted">تذاكر دعم</small>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-3">
                            <div class="d-flex align-items-center p-3 bg-light rounded">
                                <div class="me-3">
                                    <i class="fas fa-money-bill-transfer fa-2x text-danger"></i>
                                </div>
                                <div>
                                    <h4 class="mb-0">{{ $stats['requests']['bank_transfers_pending'] }}</h4>
                                    <small class="text-muted">شحن بنكي</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="row g-4">
        <div class="col-lg-12">
            <div class="card">
                <div class="card-header bg-white">
                    <h5 class="mb-0">إجراءات سريعة</h5>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-3">
                            <a href="{{ route('admin.users.index') }}" class="btn btn-outline-primary w-100">
                                <i class="fas fa-users me-2"></i> إدارة المستخدمين
                            </a>
                        </div>
                        <div class="col-md-3">
                            <a href="{{ route('admin.requests.website') }}" class="btn btn-outline-success w-100">
                                <i class="fas fa-globe me-2"></i> طلبات المواقع
                            </a>
                        </div>
                        <div class="col-md-3">
                            <a href="{{ route('admin.requests.bank-transfers') }}" class="btn btn-outline-warning w-100">
                                <i class="fas fa-money-bill-transfer me-2"></i> الشحن البنكي
                            </a>
                        </div>
                        <div class="col-md-3">
                            <a href="{{ route('admin.requests.support') }}" class="btn btn-outline-danger w-100">
                                <i class="fas fa-headset me-2"></i> تذاكر الدعم
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
