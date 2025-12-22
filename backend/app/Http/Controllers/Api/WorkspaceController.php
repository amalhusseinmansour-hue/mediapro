<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Workspace;
use App\Models\WorkspaceInvitation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class WorkspaceController extends Controller
{
    /**
     * Get all workspaces for current user
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        // Get owned workspaces and workspaces where user is a member
        $workspaces = Workspace::where('owner_id', $user->id)
            ->orWhereHas('members', function ($query) use ($user) {
                $query->where('user_id', $user->id)->where('is_active', true);
            })
            ->with(['owner:id,name,email,profile_picture', 'activeMembers:id,name,email,profile_picture'])
            ->withCount(['activeMembers', 'socialAccounts', 'posts'])
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($workspace) use ($user) {
                return [
                    'id' => $workspace->id,
                    'name' => $workspace->name,
                    'slug' => $workspace->slug,
                    'description' => $workspace->description,
                    'logo' => $workspace->logo,
                    'owner' => $workspace->owner,
                    'is_owner' => $workspace->owner_id === $user->id,
                    'role' => $workspace->getUserRole($user),
                    'plan_type' => $workspace->plan_type,
                    'members_count' => $workspace->active_members_count,
                    'social_accounts_count' => $workspace->social_accounts_count,
                    'posts_count' => $workspace->posts_count,
                    'max_members' => $workspace->max_members,
                    'max_social_accounts' => $workspace->max_social_accounts,
                    'is_active' => $workspace->is_active,
                    'created_at' => $workspace->created_at,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $workspaces,
        ]);
    }

    /**
     * Create a new workspace
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'logo' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        // Check if user can create more workspaces (based on subscription)
        $ownedWorkspaces = Workspace::where('owner_id', $user->id)->count();
        $maxWorkspaces = $this->getMaxWorkspacesForUser($user);

        if ($ownedWorkspaces >= $maxWorkspaces) {
            return response()->json([
                'success' => false,
                'message' => 'لقد وصلت إلى الحد الأقصى من مساحات العمل المسموح بها',
            ], 403);
        }

        DB::beginTransaction();
        try {
            $workspace = Workspace::create([
                'name' => $request->name,
                'description' => $request->description,
                'logo' => $request->logo,
                'owner_id' => $user->id,
                'plan_type' => $this->getPlanTypeForUser($user),
                'max_members' => $this->getMaxMembersForUser($user),
                'max_social_accounts' => $this->getMaxSocialAccountsForUser($user),
                'settings' => [
                    'notifications' => true,
                    'auto_publish' => false,
                    'approval_required' => false,
                ],
            ]);

            // Add owner as a member with owner role
            $workspace->members()->attach($user->id, [
                'role' => 'owner',
                'invited_at' => now(),
                'accepted_at' => now(),
                'is_active' => true,
            ]);

            // Log activity
            $workspace->logActivity('created');

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'تم إنشاء مساحة العمل بنجاح',
                'data' => $workspace->load('owner:id,name,email'),
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء إنشاء مساحة العمل',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get workspace details
     */
    public function show(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        $workspace = Workspace::with([
            'owner:id,name,email,profile_picture',
            'activeMembers:id,name,email,profile_picture',
            'pendingInvitations',
        ])
            ->withCount(['activeMembers', 'socialAccounts', 'posts'])
            ->findOrFail($id);

        // Check access
        if (!$workspace->hasMember($user) && !$workspace->isOwner($user)) {
            return response()->json([
                'success' => false,
                'message' => 'ليس لديك صلاحية الوصول لهذه المساحة',
            ], 403);
        }

        $data = [
            'id' => $workspace->id,
            'name' => $workspace->name,
            'slug' => $workspace->slug,
            'description' => $workspace->description,
            'logo' => $workspace->logo,
            'owner' => $workspace->owner,
            'is_owner' => $workspace->isOwner($user),
            'is_admin' => $workspace->isAdmin($user),
            'can_edit' => $workspace->canEdit($user),
            'role' => $workspace->getUserRole($user),
            'plan_type' => $workspace->plan_type,
            'members' => $workspace->activeMembers->map(function ($member) use ($workspace) {
                return [
                    'id' => $member->id,
                    'name' => $member->name,
                    'email' => $member->email,
                    'profile_picture' => $member->profile_picture,
                    'role' => $member->pivot->role,
                    'joined_at' => $member->pivot->accepted_at,
                ];
            }),
            'pending_invitations' => $workspace->isAdmin($user) ? $workspace->pendingInvitations : [],
            'members_count' => $workspace->active_members_count,
            'social_accounts_count' => $workspace->social_accounts_count,
            'posts_count' => $workspace->posts_count,
            'max_members' => $workspace->max_members,
            'max_social_accounts' => $workspace->max_social_accounts,
            'can_add_members' => $workspace->canAddMembers(),
            'can_add_social_accounts' => $workspace->canAddSocialAccounts(),
            'settings' => $workspace->settings,
            'is_active' => $workspace->is_active,
            'created_at' => $workspace->created_at,
        ];

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Update workspace
     */
    public function update(Request $request, $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string|max:1000',
            'logo' => 'nullable|string',
            'settings' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $workspace = Workspace::findOrFail($id);

        // Check admin access
        if (!$workspace->isAdmin($user)) {
            return response()->json([
                'success' => false,
                'message' => 'ليس لديك صلاحية تعديل هذه المساحة',
            ], 403);
        }

        $workspace->update($request->only(['name', 'description', 'logo', 'settings']));
        $workspace->logActivity('updated');

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث مساحة العمل بنجاح',
            'data' => $workspace->fresh(),
        ]);
    }

    /**
     * Delete workspace
     */
    public function destroy(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        $workspace = Workspace::findOrFail($id);

        // Only owner can delete
        if (!$workspace->isOwner($user)) {
            return response()->json([
                'success' => false,
                'message' => 'فقط مالك المساحة يمكنه حذفها',
            ], 403);
        }

        $workspace->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم حذف مساحة العمل بنجاح',
        ]);
    }

    /**
     * Invite a member to workspace
     */
    public function inviteMember(Request $request, $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'role' => 'required|in:admin,editor,viewer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $workspace = Workspace::findOrFail($id);

        // Check admin access
        if (!$workspace->isAdmin($user)) {
            return response()->json([
                'success' => false,
                'message' => 'ليس لديك صلاحية دعوة أعضاء',
            ], 403);
        }

        // Check if can add more members
        if (!$workspace->canAddMembers()) {
            return response()->json([
                'success' => false,
                'message' => 'لقد وصلت إلى الحد الأقصى من الأعضاء',
            ], 403);
        }

        $email = strtolower($request->email);

        // Check if user already a member
        $existingUser = User::where('email', $email)->first();
        if ($existingUser && $workspace->hasMember($existingUser)) {
            return response()->json([
                'success' => false,
                'message' => 'هذا المستخدم عضو بالفعل في المساحة',
            ], 422);
        }

        // Check if invitation already exists
        $existingInvitation = WorkspaceInvitation::where('workspace_id', $id)
            ->where('email', $email)
            ->pending()
            ->first();

        if ($existingInvitation) {
            return response()->json([
                'success' => false,
                'message' => 'تم إرسال دعوة لهذا البريد مسبقاً',
            ], 422);
        }

        // Create invitation
        $invitation = WorkspaceInvitation::create([
            'workspace_id' => $id,
            'email' => $email,
            'role' => $request->role,
            'invited_by' => $user->id,
        ]);

        // Log activity
        $workspace->logActivity('invitation_sent', $invitation, [
            'email' => $email,
            'role' => $request->role,
        ]);

        // TODO: Send invitation email
        // Mail::to($email)->send(new WorkspaceInvitationMail($invitation));

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال الدعوة بنجاح',
            'data' => [
                'invitation_token' => $invitation->token,
                'expires_at' => $invitation->expires_at,
            ],
        ]);
    }

    /**
     * Accept workspace invitation
     */
    public function acceptInvitation(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $invitation = WorkspaceInvitation::byToken($request->token)
            ->with('workspace')
            ->first();

        if (!$invitation) {
            return response()->json([
                'success' => false,
                'message' => 'الدعوة غير موجودة',
            ], 404);
        }

        if ($invitation->isExpired()) {
            return response()->json([
                'success' => false,
                'message' => 'انتهت صلاحية الدعوة',
            ], 422);
        }

        if (!$invitation->isPending()) {
            return response()->json([
                'success' => false,
                'message' => 'تم استخدام هذه الدعوة مسبقاً',
            ], 422);
        }

        // Check if email matches
        if (strtolower($user->email) !== strtolower($invitation->email)) {
            return response()->json([
                'success' => false,
                'message' => 'هذه الدعوة مخصصة لبريد إلكتروني آخر',
            ], 403);
        }

        if ($invitation->accept($user)) {
            $invitation->workspace->logActivity('invitation_accepted', $user);

            return response()->json([
                'success' => true,
                'message' => 'تم قبول الدعوة بنجاح',
                'data' => [
                    'workspace' => $invitation->workspace,
                ],
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'حدث خطأ أثناء قبول الدعوة',
        ], 500);
    }

    /**
     * Cancel/revoke invitation
     */
    public function cancelInvitation(Request $request, $id, $invitationId): JsonResponse
    {
        $user = $request->user();
        $workspace = Workspace::findOrFail($id);

        if (!$workspace->isAdmin($user)) {
            return response()->json([
                'success' => false,
                'message' => 'ليس لديك صلاحية إلغاء الدعوات',
            ], 403);
        }

        $invitation = WorkspaceInvitation::where('workspace_id', $id)
            ->where('id', $invitationId)
            ->pending()
            ->first();

        if (!$invitation) {
            return response()->json([
                'success' => false,
                'message' => 'الدعوة غير موجودة',
            ], 404);
        }

        $invitation->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم إلغاء الدعوة بنجاح',
        ]);
    }

    /**
     * Remove member from workspace
     */
    public function removeMember(Request $request, $id, $memberId): JsonResponse
    {
        $user = $request->user();
        $workspace = Workspace::findOrFail($id);

        if (!$workspace->isAdmin($user)) {
            return response()->json([
                'success' => false,
                'message' => 'ليس لديك صلاحية إزالة الأعضاء',
            ], 403);
        }

        // Can't remove owner
        if ($workspace->owner_id == $memberId) {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن إزالة مالك المساحة',
            ], 422);
        }

        $member = User::findOrFail($memberId);

        if (!$workspace->hasMember($member)) {
            return response()->json([
                'success' => false,
                'message' => 'هذا المستخدم ليس عضواً في المساحة',
            ], 404);
        }

        $workspace->removeMember($member);

        return response()->json([
            'success' => true,
            'message' => 'تم إزالة العضو بنجاح',
        ]);
    }

    /**
     * Update member role
     */
    public function updateMemberRole(Request $request, $id, $memberId): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'role' => 'required|in:admin,editor,viewer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $workspace = Workspace::findOrFail($id);

        // Only owner can change roles
        if (!$workspace->isOwner($user)) {
            return response()->json([
                'success' => false,
                'message' => 'فقط مالك المساحة يمكنه تغيير الأدوار',
            ], 403);
        }

        // Can't change owner's role
        if ($workspace->owner_id == $memberId) {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن تغيير دور مالك المساحة',
            ], 422);
        }

        $member = User::findOrFail($memberId);

        if (!$workspace->hasMember($member)) {
            return response()->json([
                'success' => false,
                'message' => 'هذا المستخدم ليس عضواً في المساحة',
            ], 404);
        }

        $workspace->updateMemberRole($member, $request->role);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث دور العضو بنجاح',
        ]);
    }

    /**
     * Leave workspace (for non-owners)
     */
    public function leave(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        $workspace = Workspace::findOrFail($id);

        if ($workspace->isOwner($user)) {
            return response()->json([
                'success' => false,
                'message' => 'لا يمكن للمالك مغادرة المساحة، يمكنك نقل الملكية أو حذف المساحة',
            ], 422);
        }

        if (!$workspace->hasMember($user)) {
            return response()->json([
                'success' => false,
                'message' => 'أنت لست عضواً في هذه المساحة',
            ], 404);
        }

        $workspace->removeMember($user);

        return response()->json([
            'success' => true,
            'message' => 'تم مغادرة المساحة بنجاح',
        ]);
    }

    /**
     * Transfer ownership
     */
    public function transferOwnership(Request $request, $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $workspace = Workspace::findOrFail($id);

        if (!$workspace->isOwner($user)) {
            return response()->json([
                'success' => false,
                'message' => 'فقط مالك المساحة يمكنه نقل الملكية',
            ], 403);
        }

        $newOwner = User::findOrFail($request->user_id);

        if (!$workspace->hasMember($newOwner)) {
            return response()->json([
                'success' => false,
                'message' => 'يجب أن يكون المستخدم الجديد عضواً في المساحة',
            ], 422);
        }

        DB::beginTransaction();
        try {
            // Update old owner to admin
            $workspace->updateMemberRole($user, 'admin');

            // Update new owner
            $workspace->updateMemberRole($newOwner, 'owner');
            $workspace->update(['owner_id' => $newOwner->id]);

            $workspace->logActivity('ownership_transferred', $newOwner, [
                'old_owner' => $user->name,
                'new_owner' => $newOwner->name,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'تم نقل الملكية بنجاح',
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ أثناء نقل الملكية',
            ], 500);
        }
    }

    /**
     * Get workspace activity log
     */
    public function getActivities(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        $workspace = Workspace::findOrFail($id);

        if (!$workspace->hasMember($user)) {
            return response()->json([
                'success' => false,
                'message' => 'ليس لديك صلاحية الوصول لهذه المساحة',
            ], 403);
        }

        $activities = $workspace->activities()
            ->with('user:id,name,profile_picture')
            ->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 20));

        return response()->json([
            'success' => true,
            'data' => $activities,
        ]);
    }

    /**
     * Get user's pending invitations
     */
    public function getMyInvitations(Request $request): JsonResponse
    {
        $user = $request->user();

        $invitations = WorkspaceInvitation::where('email', strtolower($user->email))
            ->pending()
            ->with(['workspace:id,name,logo', 'inviter:id,name'])
            ->get();

        return response()->json([
            'success' => true,
            'data' => $invitations,
        ]);
    }

    // Helper methods
    private function getMaxWorkspacesForUser(User $user): int
    {
        // Based on subscription, return max workspaces
        // Default: 1 for free, more for paid plans
        $subscription = $user->activeSubscription;
        if (!$subscription) {
            return 1;
        }

        return match ($subscription->plan?->slug ?? 'free') {
            'individual' => 2,
            'business' => 5,
            'enterprise' => 20,
            default => 1,
        };
    }

    private function getPlanTypeForUser(User $user): string
    {
        $subscription = $user->activeSubscription;
        return $subscription?->plan?->slug ?? 'free';
    }

    private function getMaxMembersForUser(User $user): int
    {
        $subscription = $user->activeSubscription;
        if (!$subscription) {
            return 3;
        }

        return match ($subscription->plan?->slug ?? 'free') {
            'individual' => 3,
            'business' => 10,
            'enterprise' => 50,
            default => 3,
        };
    }

    private function getMaxSocialAccountsForUser(User $user): int
    {
        $subscription = $user->activeSubscription;
        if (!$subscription) {
            return 3;
        }

        return match ($subscription->plan?->slug ?? 'free') {
            'individual' => 5,
            'business' => 15,
            'enterprise' => 50,
            default => 3,
        };
    }
}
