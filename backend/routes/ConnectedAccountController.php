<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class ConnectedAccountController extends Controller
{
    /**
     * Display a listing of the user's connected accounts.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(): JsonResponse
    {
        $user = Auth::user();

        // In a real application, the User model would have a 'connectedAccounts' relationship.
        // For example: public function connectedAccounts() { return $this->hasMany(ConnectedAccount::class); }
        // $accounts = $user->connectedAccounts;

        // For now, we'll simulate this data. This assumes you have a 'ConnectedAccount' model
        // with fields like 'platform', 'username', etc.
        $simulatedAccounts = collect([]); // Start with an empty collection

        return response()->json($simulatedAccounts);
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'platform' => 'required|string|in:facebook,twitter,instagram,linkedin,tiktok',
            'access_token' => 'required|string|min:20',
            'username' => 'sometimes|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Placeholder for the actual logic to store the account.
        // In a real app, you would encrypt the access token and save it to the database,
        // associating it with the authenticated user.
        //
        // $account = Auth::user()->connectedAccounts()->create([
        //     'platform' => $request->platform,
        //     'username' => $request->username,
        //     'token' => encrypt($request->access_token),
        // ]);

        return response()->json(['message' => 'Account connected successfully.'], 201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        // Placeholder: Show details of a specific connected account
        return response()->json(['message' => 'Showing details for account ' . $id]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        // Placeholder: Update a connected account (e.g., refresh token)
        return response()->json(['message' => 'Account ' . $id . ' updated successfully.']);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        // Placeholder: Disconnect a social media account
        return response()->json(['message' => 'Account ' . $id . ' disconnected successfully.'], 204);
    }
}