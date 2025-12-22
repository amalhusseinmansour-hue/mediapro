@extends('admin.layouts.app')

@section('title', 'طلبات الإعلانات الممولة')
@section('page-title', 'طلبات الإعلانات الممولة')

@section('breadcrumb')
    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">الرئيسية</a></li>
    <li class="breadcrumb-item active">الإعلانات الممولة</li>
@endsection

@section('content')
    <div class="card">
        <div class="card-header bg-white">
            <div class="row align-items-center">
                <div class="col">
                    <h5 class="mb-0">قائمة طلبات الإعلانات ({{ $requests->total() }})</h5>
                </div>
                <div class="col-auto">
                    <div class="btn-group" role="group">
                        <a href="?" class="btn btn-sm btn-outline-secondary {{ !request('status') ? 'active' : '' }}">الكل</a>
                        <a href="?status=pending" class="btn btn-sm btn-outline-warning {{ request('status') === 'pending' ? 'active' : '' }}">معلقة</a>
                        <a href="?status=accepted" class="btn btn-sm btn-outline-success {{ request('status') === 'accepted' ? 'active' : '' }}">مقبولة</a>
                        <a href="?status=running" class="btn btn-sm btn-outline-primary {{ request('status') === 'running' ? 'active' : '' }}">قيد التنفيذ</a>
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
                            <th>المنصة</th>
                            <th>نوع الإعلان</th>
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
                                <td>{{ $request->ad_platform_arabic }}</td>
                                <td>{{ $request->ad_type_arabic }}</td>
                                <td>
                                    <strong>{{ number_format($request->budget, 2) }} {{ $request->currency }}</strong>
                                    @if($request->duration_days)
                                        <br><small class="text-muted">{{ $request->duration_days }} يوم</small>
                                    @endif
                                </td>
                                <td>
                                    @php
                                        $statusColors = [
                                            'pending' => 'warning',
                                            'reviewing' => 'info',
                                            'accepted' => 'success',
                                            'rejected' => 'danger',
                                            'running' => 'primary',
                                            'completed' => 'secondary'
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
                                                    <h5 class="modal-title">تفاصيل طلب الإعلان #{{ $request->id }}</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <div class="row">
                                                        <div class="col-md-6">
                                                            <p><strong>الاسم:</strong> {{ $request->name }}</p>
                                                            <p><strong>الشركة:</strong> {{ $request->company_name ?? '-' }}</p>
                                                            <p><strong>البريد:</strong> {{ $request->email }}</p>
                                                            <p><strong>الهاتف:</strong> {{ $request->phone }}</p>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <p><strong>المنصة:</strong> {{ $request->ad_platform_arabic }}</p>
                                                            <p><strong>نوع الإعلان:</strong> {{ $request->ad_type_arabic }}</p>
                                                            <p><strong>الميزانية:</strong> {{ number_format($request->budget, 2) }} {{ $request->currency }}</p>
                                                            <p><strong>المدة:</strong> {{ $request->duration_days ?? '-' }} يوم</p>
                                                            <p><strong>تاريخ البدء:</strong> {{ $request->start_date ? $request->start_date->format('Y-m-d') : '-' }}</p>
                                                        </div>
                                                    </div>
                                                    <hr>
                                                    <p><strong>الجمهور المستهدف:</strong></p>
                                                    <p>{{ $request->target_audience }}</p>
                                                    @if($request->ad_content)
                                                        <hr>
                                                        <p><strong>محتوى الإعلان:</strong></p>
                                                        <p>{{ $request->ad_content }}</p>
                                                    @endif
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
                                                <form method="POST" action="{{ route('admin.requests.ads.update', $request->id) }}">
                                                    @csrf
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">تحديث طلب الإعلان #{{ $request->id }}</h5>
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
                                                                <option value="running" {{ $request->status === 'running' ? 'selected' : '' }}>قيد التنفيذ</option>
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
                                <td colspan="9" class="text-center py-4 text-muted">
                                    <i class="fas fa-ad fa-3x mb-3 d-block"></i>
                                    لا توجد طلبات إعلانات
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
