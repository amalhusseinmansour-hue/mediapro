@extends('admin.layouts.app')

@section('title', 'طلبات المواقع')
@section('page-title', 'طلبات المواقع الإلكترونية')

@section('breadcrumb')
    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">الرئيسية</a></li>
    <li class="breadcrumb-item active">طلبات المواقع</li>
@endsection

@section('content')
    <div class="card">
        <div class="card-header bg-white">
            <div class="row align-items-center">
                <div class="col">
                    <h5 class="mb-0">قائمة طلبات المواقع ({{ $requests->total() }})</h5>
                </div>
                <div class="col-auto">
                    <div class="btn-group" role="group">
                        <a href="?" class="btn btn-sm btn-outline-secondary {{ !request('status') ? 'active' : '' }}">الكل</a>
                        <a href="?status=pending" class="btn btn-sm btn-outline-warning {{ request('status') === 'pending' ? 'active' : '' }}">معلقة</a>
                        <a href="?status=accepted" class="btn btn-sm btn-outline-success {{ request('status') === 'accepted' ? 'active' : '' }}">مقبولة</a>
                        <a href="?status=completed" class="btn btn-sm btn-outline-info {{ request('status') === 'completed' ? 'active' : '' }}">مكتملة</a>
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
                            <th>الاسم</th>
                            <th>البريد/الهاتف</th>
                            <th>نوع الموقع</th>
                            <th>الميزانية</th>
                            <th>الحالة</th>
                            <th>التاريخ</th>
                            <th>الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($requests as $request)
                            <tr>
                                <td>{{ $request->id }}</td>
                                <td>
                                    <strong>{{ $request->name }}</strong><br>
                                    @if($request->company_name)
                                        <small class="text-muted">{{ $request->company_name }}</small>
                                    @endif
                                </td>
                                <td>
                                    {{ $request->email }}<br>
                                    <small class="text-muted">{{ $request->phone }}</small>
                                </td>
                                <td>{{ $request->website_type_arabic }}</td>
                                <td>{{ $request->budget ? number_format($request->budget, 2) . ' ' . $request->currency : '-' }}</td>
                                <td>
                                    @php
                                        $statusColors = [
                                            'pending' => 'warning',
                                            'reviewing' => 'info',
                                            'accepted' => 'success',
                                            'rejected' => 'danger',
                                            'completed' => 'primary'
                                        ];
                                        $color = $statusColors[$request->status] ?? 'secondary';
                                    @endphp
                                    <span class="badge badge-status bg-{{ $color }}">{{ $request->status_arabic }}</span>
                                </td>
                                <td>{{ $request->created_at->format('Y-m-d') }}</td>
                                <td>
                                    <button class="btn btn-sm btn-info" data-bs-toggle="modal" data-bs-target="#detailsModal{{ $request->id }}">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#updateModal{{ $request->id }}">
                                        <i class="fas fa-edit"></i>
                                    </button>

                                    <!-- Details Modal -->
                                    <div class="modal fade" id="detailsModal{{ $request->id }}" tabindex="-1">
                                        <div class="modal-dialog modal-lg">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">تفاصيل الطلب #{{ $request->id }}</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <p><strong>الاسم:</strong> {{ $request->name }}</p>
                                                    <p><strong>الشركة:</strong> {{ $request->company_name ?? '-' }}</p>
                                                    <p><strong>البريد:</strong> {{ $request->email }}</p>
                                                    <p><strong>الهاتف:</strong> {{ $request->phone }}</p>
                                                    <p><strong>نوع الموقع:</strong> {{ $request->website_type_arabic }}</p>
                                                    <p><strong>الميزانية:</strong> {{ $request->budget ? number_format($request->budget, 2) . ' ' . $request->currency : '-' }}</p>
                                                    <p><strong>الموعد النهائي:</strong> {{ $request->deadline ? $request->deadline->format('Y-m-d') : '-' }}</p>
                                                    <hr>
                                                    <p><strong>الوصف:</strong></p>
                                                    <p>{{ $request->description }}</p>
                                                    @if($request->admin_notes)
                                                        <hr>
                                                        <p><strong>ملاحظات الإدارة:</strong></p>
                                                        <p>{{ $request->admin_notes }}</p>
                                                    @endif
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Update Modal -->
                                    <div class="modal fade" id="updateModal{{ $request->id }}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <form method="POST" action="{{ route('admin.requests.website.update', $request->id) }}">
                                                    @csrf
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">تحديث الطلب #{{ $request->id }}</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="mb-3">
                                                            <label class="form-label">الحالة</label>
                                                            <select name="status" class="form-select" required>
                                                                <option value="pending" {{ $request->status === 'pending' ? 'selected' : '' }}>قيد الانتظار</option>
                                                                <option value="reviewing" {{ $request->status === 'reviewing' ? 'selected' : '' }}>قيد المراجعة</option>
                                                                <option value="accepted" {{ $request->status === 'accepted' ? 'selected' : '' }}>مقبول</option>
                                                                <option value="rejected" {{ $request->status === 'rejected' ? 'selected' : '' }}>مرفوض</option>
                                                                <option value="completed" {{ $request->status === 'completed' ? 'selected' : '' }}>مكتمل</option>
                                                            </select>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">ملاحظات الإدارة</label>
                                                            <textarea name="admin_notes" class="form-control" rows="3">{{ $request->admin_notes }}</textarea>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                                                        <button type="submit" class="btn btn-primary">حفظ التغييرات</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="8" class="text-center py-4 text-muted">
                                    <i class="fas fa-globe fa-3x mb-3 d-block"></i>
                                    لا توجد طلبات
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
        @if($requests->hasPages())
            <div class="card-footer bg-white">
                {{ $requests->links() }}
            </div>
        @endif
    </div>
@endsection
