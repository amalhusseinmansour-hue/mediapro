@extends('admin.layouts.app')

@section('title', 'تذاكر الدعم الفني')
@section('page-title', 'تذاكر الدعم الفني')

@section('breadcrumb')
    <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">الرئيسية</a></li>
    <li class="breadcrumb-item active">تذاكر الدعم</li>
@endsection

@section('content')
    <div class="card">
        <div class="card-header bg-white">
            <div class="row align-items-center">
                <div class="col">
                    <h5 class="mb-0">قائمة تذاكر الدعم ({{ $tickets->total() }})</h5>
                </div>
                <div class="col-auto">
                    <div class="btn-group me-2" role="group">
                        <a href="?" class="btn btn-sm btn-outline-secondary {{ !request('status') ? 'active' : '' }}">الكل</a>
                        <a href="?status=open" class="btn btn-sm btn-outline-danger {{ request('status') === 'open' ? 'active' : '' }}">مفتوحة</a>
                        <a href="?status=in_progress" class="btn btn-sm btn-outline-primary {{ request('status') === 'in_progress' ? 'active' : '' }}">قيد المعالجة</a>
                        <a href="?status=resolved" class="btn btn-sm btn-outline-success {{ request('status') === 'resolved' ? 'active' : '' }}">محلولة</a>
                    </div>
                    <div class="btn-group" role="group">
                        <a href="?priority=urgent" class="btn btn-sm btn-outline-danger {{ request('priority') === 'urgent' ? 'active' : '' }}">عاجلة</a>
                        <a href="?priority=high" class="btn btn-sm btn-outline-warning {{ request('priority') === 'high' ? 'active' : '' }}">عالية</a>
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
                            <th>الموضوع</th>
                            <th>المستخدم</th>
                            <th>التصنيف</th>
                            <th>الأولوية</th>
                            <th>الحالة</th>
                            <th>المسؤول</th>
                            <th>التاريخ</th>
                            <th>الإجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($tickets as $ticket)
                            <tr>
                                <td>{{ $ticket->id }}</td>
                                <td>
                                    <strong>{{ $ticket->subject }}</strong><br>
                                    <small class="text-muted">{{ Str::limit($ticket->message, 50) }}</small>
                                </td>
                                <td>
                                    @if($ticket->user)
                                        {{ $ticket->user->name }}<br>
                                        <small class="text-muted">{{ $ticket->user->email }}</small>
                                    @else
                                        {{ $ticket->name }}<br>
                                        <small class="text-muted">{{ $ticket->email }}</small>
                                    @endif
                                </td>
                                <td>
                                    @php
                                        $categoryColors = [
                                            'technical' => 'primary',
                                            'billing' => 'success',
                                            'feature' => 'info',
                                            'bug' => 'danger',
                                            'account' => 'warning',
                                            'other' => 'secondary'
                                        ];
                                        $catColor = $categoryColors[$ticket->category] ?? 'secondary';
                                    @endphp
                                    <span class="badge bg-{{ $catColor }}">{{ $ticket->category_arabic }}</span>
                                </td>
                                <td>
                                    @php
                                        $priorityColors = [
                                            'low' => 'secondary',
                                            'medium' => 'info',
                                            'high' => 'warning',
                                            'urgent' => 'danger'
                                        ];
                                        $priColor = $priorityColors[$ticket->priority] ?? 'secondary';
                                    @endphp
                                    <span class="badge bg-{{ $priColor }}">{{ $ticket->priority_arabic }}</span>
                                </td>
                                <td>
                                    @php
                                        $statusColors = [
                                            'open' => 'danger',
                                            'in_progress' => 'primary',
                                            'resolved' => 'success',
                                            'closed' => 'secondary'
                                        ];
                                        $statusColor = $statusColors[$ticket->status] ?? 'secondary';
                                    @endphp
                                    <span class="badge badge-status bg-{{ $statusColor }}">{{ $ticket->status_arabic }}</span>
                                </td>
                                <td>
                                    @if($ticket->assignedAdmin)
                                        <small>{{ $ticket->assignedAdmin->name }}</small>
                                    @else
                                        <small class="text-muted">غير مُعين</small>
                                    @endif
                                </td>
                                <td>{{ $ticket->created_at->format('Y-m-d') }}</td>
                                <td>
                                    <button class="btn btn-sm btn-info" data-bs-toggle="modal" data-bs-target="#detailsModal{{ $ticket->id }}">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#updateModal{{ $ticket->id }}">
                                        <i class="fas fa-edit"></i>
                                    </button>

                                    <!-- Details Modal -->
                                    <div class="modal fade" id="detailsModal{{ $ticket->id }}" tabindex="-1">
                                        <div class="modal-dialog modal-lg">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">تفاصيل التذكرة #{{ $ticket->id }}</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <div class="row mb-3">
                                                        <div class="col-md-6">
                                                            <p><strong>الموضوع:</strong> {{ $ticket->subject }}</p>
                                                            <p><strong>الاسم:</strong> {{ $ticket->name }}</p>
                                                            <p><strong>البريد:</strong> {{ $ticket->email }}</p>
                                                            @if($ticket->phone)
                                                                <p><strong>الهاتف:</strong> {{ $ticket->phone }}</p>
                                                            @endif
                                                            @if($ticket->whatsapp_number)
                                                                <p><strong>واتساب:</strong> {{ $ticket->whatsapp_number }}</p>
                                                            @endif
                                                        </div>
                                                        <div class="col-md-6">
                                                            <p><strong>التصنيف:</strong> {{ $ticket->category_arabic }}</p>
                                                            <p><strong>الأولوية:</strong> {{ $ticket->priority_arabic }}</p>
                                                            <p><strong>الحالة:</strong> {{ $ticket->status_arabic }}</p>
                                                            @if($ticket->assignedAdmin)
                                                                <p><strong>المسؤول:</strong> {{ $ticket->assignedAdmin->name }}</p>
                                                            @endif
                                                            @if($ticket->resolved_at)
                                                                <p><strong>تم الحل في:</strong> {{ $ticket->resolved_at->format('Y-m-d H:i') }}</p>
                                                            @endif
                                                        </div>
                                                    </div>
                                                    <hr>
                                                    <p><strong>الرسالة:</strong></p>
                                                    <p class="bg-light p-3 rounded">{{ $ticket->message }}</p>
                                                    @if($ticket->admin_notes)
                                                        <hr>
                                                        <p><strong>ملاحظات الإدارة:</strong></p>
                                                        <p class="bg-warning bg-opacity-10 p-3 rounded">{{ $ticket->admin_notes }}</p>
                                                    @endif
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Update Modal -->
                                    <div class="modal fade" id="updateModal{{ $ticket->id }}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <form method="POST" action="{{ route('admin.requests.support.update', $ticket->id) }}">
                                                    @csrf
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">تحديث التذكرة #{{ $ticket->id }}</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="mb-3">
                                                            <label class="form-label">الحالة</label>
                                                            <select name="status" class="form-select" required>
                                                                <option value="open" {{ $ticket->status === 'open' ? 'selected' : '' }}>مفتوحة</option>
                                                                <option value="in_progress" {{ $ticket->status === 'in_progress' ? 'selected' : '' }}>قيد المعالجة</option>
                                                                <option value="resolved" {{ $ticket->status === 'resolved' ? 'selected' : '' }}>محلولة</option>
                                                                <option value="closed" {{ $ticket->status === 'closed' ? 'selected' : '' }}>مغلقة</option>
                                                            </select>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">الأولوية</label>
                                                            <select name="priority" class="form-select" required>
                                                                <option value="low" {{ $ticket->priority === 'low' ? 'selected' : '' }}>منخفضة</option>
                                                                <option value="medium" {{ $ticket->priority === 'medium' ? 'selected' : '' }}>متوسطة</option>
                                                                <option value="high" {{ $ticket->priority === 'high' ? 'selected' : '' }}>عالية</option>
                                                                <option value="urgent" {{ $ticket->priority === 'urgent' ? 'selected' : '' }}>عاجلة</option>
                                                            </select>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">تعيين إلى مشرف</label>
                                                            <select name="assigned_to" class="form-select">
                                                                <option value="">غير مُعين</option>
                                                                @php
                                                                    $admins = \App\Models\User::where('is_admin', true)->get();
                                                                @endphp
                                                                @foreach($admins as $admin)
                                                                    <option value="{{ $admin->id }}" {{ $ticket->assigned_to == $admin->id ? 'selected' : '' }}>
                                                                        {{ $admin->name }}
                                                                    </option>
                                                                @endforeach
                                                            </select>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label">ملاحظات الإدارة</label>
                                                            <textarea name="admin_notes" class="form-control" rows="3">{{ $ticket->admin_notes }}</textarea>
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
                                    <i class="fas fa-headset fa-3x mb-3 d-block"></i>
                                    لا توجد تذاكر دعم
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
        @if($tickets->hasPages())
            <div class="card-footer bg-white">
                {{ $tickets->links() }}
            </div>
        @endif
    </div>
@endsection
