@extends('admin.layouts.app')

@section('title', 'طلبات الشحن البنكي')
@section('page-title', 'طلبات الشحن البنكي')

@section('breadcrumb')
    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">الرئيسية</a></li>
    <li class="breadcrumb-item active">الشحن البنكي</li>
@endsection

@section('content')
    <div class="card">
        <div class="card-header bg-white">
            <div class="row align-items-center">
                <div class="col">
                    <h5 class="mb-0">قائمة طلبات الشحن ({{ $transfers->total() }})</h5>
                </div>
                <div class="col-auto">
                    <div class="btn-group" role="group">
                        <a href="?status=" class="btn btn-sm btn-outline-secondary {{ !request('status') ? 'active' : '' }}">الكل</a>
                        <a href="?status=pending" class="btn btn-sm btn-outline-warning {{ request('status') === 'pending' ? 'active' : '' }}">معلقة</a>
                        <a href="?status=approved" class="btn btn-sm btn-outline-success {{ request('status') === 'approved' ? 'active' : '' }}">مقبولة</a>
                        <a href="?status=rejected" class="btn btn-sm btn-outline-danger {{ request('status') === 'rejected' ? 'active' : '' }}">مرفوضة</a>
                    </div>
                </div>
            </div>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th>ID</th>
                            <th>المستخدم</th>
                            <th>المبلغ</th>
                            <th>البنك</th>
                            <th>تاريخ التحويل</th>
                            <th>الإيصال</th>
                            <th>الحالة</th>
                            <th>الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($transfers as $transfer)
                            <tr>
                                <td>{{ $transfer->id }}</td>
                                <td>
                                    <strong>{{ $transfer->user->name }}</strong><br>
                                    <small class="text-muted">{{ $transfer->user->email }}</small>
                                </td>
                                <td>
                                    <strong>{{ number_format($transfer->amount, 2) }} {{ $transfer->currency }}</strong>
                                </td>
                                <td>
                                    {{ $transfer->sender_bank }}<br>
                                    <small class="text-muted">{{ $transfer->sender_name }}</small>
                                </td>
                                <td>{{ $transfer->transfer_date->format('Y-m-d') }}</td>
                                <td>
                                    @if($transfer->receipt_image)
                                        <a href="{{ $transfer->receipt_url }}" target="_blank" class="btn btn-sm btn-info">
                                            <i class="fas fa-image"></i> عرض
                                        </a>
                                    @else
                                        <span class="text-muted">-</span>
                                    @endif
                                </td>
                                <td>
                                    @if($transfer->status === 'pending')
                                        <span class="badge badge-status bg-warning">قيد الانتظار</span>
                                    @elseif($transfer->status === 'reviewing')
                                        <span class="badge badge-status bg-info">قيد المراجعة</span>
                                    @elseif($transfer->status === 'approved')
                                        <span class="badge badge-status bg-success">مقبول</span>
                                    @else
                                        <span class="badge badge-status bg-danger">مرفوض</span>
                                    @endif
                                </td>
                                <td>
                                    <div class="table-actions">
                                        <button class="btn btn-sm btn-info" data-bs-toggle="modal" data-bs-target="#detailsModal{{ $transfer->id }}">
                                            <i class="fas fa-eye"></i> عرض
                                        </button>

                                        @if(!in_array($transfer->status, ['approved', 'rejected']))
                                            <button class="btn btn-sm btn-success" data-bs-toggle="modal" data-bs-target="#approveModal{{ $transfer->id }}">
                                                <i class="fas fa-check"></i> موافقة
                                            </button>
                                            <button class="btn btn-sm btn-danger" data-bs-toggle="modal" data-bs-target="#rejectModal{{ $transfer->id }}">
                                                <i class="fas fa-times"></i> رفض
                                            </button>
                                        @endif
                                    </div>

                                    <!-- Details Modal -->
                                    <div class="modal fade" id="detailsModal{{ $transfer->id }}" tabindex="-1">
                                        <div class="modal-dialog modal-lg">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">تفاصيل طلب الشحن #{{ $transfer->id }}</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <p><strong>المستخدم:</strong> {{ $transfer->user->name }}</p>
                                                            <p><strong>البريد:</strong> {{ $transfer->user->email }}</p>
                                                            <p><strong>المبلغ:</strong> {{ number_format($transfer->amount, 2) }} {{ $transfer->currency }}</p>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <p><strong>اسم المُرسل:</strong> {{ $transfer->sender_name }}</p>
                                                            <p><strong>البنك:</strong> {{ $transfer->sender_bank }}</p>
                                                            <p><strong>رقم الحساب:</strong> {{ $transfer->sender_account_number ?? '-' }}</p>
                                                            <p><strong>المرجع:</strong> {{ $transfer->transfer_reference ?? '-' }}</p>
                                                            <p><strong>تاريخ التحويل:</strong> {{ $transfer->transfer_date->format('Y-m-d') }}</p>
                                                        </div>
                                                    </div>
                                                    @if($transfer->transfer_notes)
                                                        <hr>
                                                        <p><strong>ملاحظات:</strong></p>
                                                        <p>{{ $transfer->transfer_notes }}</p>
                                                    @endif
                                                    @if($transfer->receipt_image)
                                                        <hr>
                                                        <p><strong>صورة الإيصال:</strong></p>
                                                        <img src="{{ $transfer->receipt_url }}" class="img-fluid rounded" alt="إيصال التحويل">
                                                    @endif
                                                    @if($transfer->admin_notes)
                                                        <hr>
                                                        <p><strong>ملاحظات الإدارة:</strong></p>
                                                        <p>{{ $transfer->admin_notes }}</p>
                                                    @endif
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    @if(!in_array($transfer->status, ['approved', 'rejected']))
                                        <!-- Approve Modal -->
                                        <div class="modal fade" id="approveModal{{ $transfer->id }}" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <form method="POST" action="{{ route('admin.requests.bank-transfers.update', $transfer->id) }}">
                                                        @csrf
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">الموافقة على طلب الشحن</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <input type="hidden" name="status" value="approved">
                                                            <div class="mb-3">
                                                                <label class="form-label">ملاحظات (اختياري)</label>
                                                                <textarea name="admin_notes" class="form-control" rows="3"></textarea>
                                                            </div>
                                                            <div class="alert alert-info">
                                                                <i class="fas fa-info-circle"></i> سيتم شحن مبلغ <strong>{{ number_format($transfer->amount, 2) }} {{ $transfer->currency }}</strong> إلى محفظة المستخدم تلقائياً.
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                                                            <button type="submit" class="btn btn-success">
                                                                <i class="fas fa-check"></i> تأكيد الموافقة
                                                            </button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Reject Modal -->
                                        <div class="modal fade" id="rejectModal{{ $transfer->id }}" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <form method="POST" action="{{ route('admin.requests.bank-transfers.update', $transfer->id) }}">
                                                        @csrf
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">رفض طلب الشحن</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <input type="hidden" name="status" value="rejected">
                                                            <div class="mb-3">
                                                                <label class="form-label">سبب الرفض *</label>
                                                                <textarea name="admin_notes" class="form-control" rows="3" required></textarea>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                                                            <button type="submit" class="btn btn-danger">
                                                                <i class="fas fa-times"></i> تأكيد الرفض
                                                            </button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    @endif
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="8" class="text-center py-4 text-muted">
                                    <i class="fas fa-money-bill-transfer fa-3x mb-3 d-block"></i>
                                    لا توجد طلبات شحن بنكي
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
        @if($transfers->hasPages())
            <div class="card-footer bg-white">
                {{ $transfers->links() }}
            </div>
        @endif
    </div>
@endsection
