# Wallet API Documentation

## Overview
This document provides comprehensive documentation for the Wallet Management API endpoints. The wallet system allows users to maintain a balance, perform transactions, and use their wallet for service payments.

**Base URL**: `https://mediaprosocial.io/public_html/api`

**Authentication**: All endpoints require Bearer token authentication using Laravel Sanctum.

**Currency**: All amounts are in SAR (Saudi Arabian Riyal)

---

## Table of Contents
1. [User Endpoints](#user-endpoints)
   - [Get User Wallet](#get-user-wallet)
   - [Get Wallet Transactions](#get-wallet-transactions)
   - [Debit Wallet](#debit-wallet)
2. [Admin Endpoints](#admin-endpoints)
   - [List All Wallets](#list-all-wallets)
   - [Get Wallet Statistics](#get-wallet-statistics)
   - [Credit Wallet](#credit-wallet)
   - [Toggle Wallet Status](#toggle-wallet-status)

---

## User Endpoints

### Get User Wallet

Retrieves the wallet information for a specific user. If the wallet doesn't exist, it will be created automatically.

**Endpoint**: `GET /wallets/{userId}`

**Authentication**: Required

**URL Parameters**:
- `userId` (string, required): The UUID of the user

**Response**:
```json
{
  "success": true,
  "wallet": {
    "id": 1,
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "balance": 1250.50,
    "currency": "SAR",
    "formatted_balance": "1,250.50 SAR",
    "is_active": true,
    "created_at": "2024-01-15T10:30:00.000000Z",
    "updated_at": "2024-01-20T14:22:00.000000Z"
  }
}
```

**Error Responses**:

*500 Internal Server Error*:
```json
{
  "success": false,
  "message": "Failed to get wallet",
  "error": "Error message details"
}
```

**Example Request**:
```bash
curl -X GET "https://mediaprosocial.io/public_html/api/wallets/550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

### Get Wallet Transactions

Retrieves paginated transaction history for a user's wallet with optional filtering by transaction type.

**Endpoint**: `GET /wallets/{userId}/transactions`

**Authentication**: Required

**URL Parameters**:
- `userId` (string, required): The UUID of the user

**Query Parameters**:
- `per_page` (integer, optional, default: 20): Number of transactions per page
- `type` (string, optional): Filter by transaction type (`credit` or `debit`)
- `page` (integer, optional, default: 1): Page number

**Response**:
```json
{
  "success": true,
  "transactions": [
    {
      "id": 1,
      "transaction_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "wallet_id": 1,
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "type": "credit",
      "amount": 500.00,
      "balance_after": 1250.50,
      "currency": "SAR",
      "description": "Wallet recharge via Paymob",
      "reference_id": "PAYMOB_12345",
      "status": "completed",
      "metadata": {
        "payment_method": "card",
        "card_last_4": "1234"
      },
      "formatted_amount": "+500.00 SAR",
      "formatted_balance_after": "1,250.50 SAR",
      "created_at": "2024-01-20T14:22:00.000000Z",
      "updated_at": "2024-01-20T14:22:00.000000Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 20,
    "total": 98
  }
}
```

**Error Responses**:

*404 Not Found*:
```json
{
  "success": false,
  "message": "Wallet not found"
}
```

*500 Internal Server Error*:
```json
{
  "success": false,
  "message": "Failed to get transactions",
  "error": "Error message details"
}
```

**Example Request**:
```bash
# Get all transactions
curl -X GET "https://mediaprosocial.io/public_html/api/wallets/550e8400-e29b-41d4-a716-446655440000/transactions" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"

# Get credit transactions only
curl -X GET "https://mediaprosocial.io/public_html/api/wallets/550e8400-e29b-41d4-a716-446655440000/transactions?type=credit&per_page=10" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

### Debit Wallet

Deduct an amount from a user's wallet. This endpoint validates that the wallet has sufficient balance before processing.

**Endpoint**: `POST /wallets/{userId}/debit`

**Authentication**: Required

**URL Parameters**:
- `userId` (string, required): The UUID of the user

**Request Body**:
```json
{
  "amount": 150.00,
  "description": "Service payment - Social Media Management",
  "reference_id": "ORDER_12345",
  "metadata": {
    "service_type": "social_media_management",
    "order_id": "ORDER_12345"
  }
}
```

**Validation Rules**:
- `amount` (numeric, required): Must be greater than 0.01
- `description` (string, required): Maximum 255 characters
- `reference_id` (string, optional): Maximum 255 characters
- `metadata` (array, optional): Additional data as JSON object

**Response**:
```json
{
  "success": true,
  "message": "Wallet debited successfully",
  "wallet": {
    "balance": 1100.50,
    "formatted_balance": "1,100.50 SAR"
  },
  "transaction": {
    "id": 2,
    "transaction_id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
    "wallet_id": 1,
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "type": "debit",
    "amount": 150.00,
    "balance_after": 1100.50,
    "currency": "SAR",
    "description": "Service payment - Social Media Management",
    "reference_id": "ORDER_12345",
    "status": "completed",
    "metadata": {
      "service_type": "social_media_management",
      "order_id": "ORDER_12345"
    },
    "created_at": "2024-01-20T15:00:00.000000Z",
    "updated_at": "2024-01-20T15:00:00.000000Z"
  }
}
```

**Error Responses**:

*422 Validation Error*:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "amount": ["The amount field is required."],
    "description": ["The description field is required."]
  }
}
```

*404 Not Found*:
```json
{
  "success": false,
  "message": "Wallet not found"
}
```

*400 Bad Request*:
```json
{
  "success": false,
  "message": "Insufficient balance"
}
```

*500 Internal Server Error*:
```json
{
  "success": false,
  "message": "Failed to debit wallet",
  "error": "Error message details"
}
```

**Example Request**:
```bash
curl -X POST "https://mediaprosocial.io/public_html/api/wallets/550e8400-e29b-41d4-a716-446655440000/debit" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "amount": 150.00,
    "description": "Service payment - Social Media Management",
    "reference_id": "ORDER_12345",
    "metadata": {
      "service_type": "social_media_management",
      "order_id": "ORDER_12345"
    }
  }'
```

---

## Admin Endpoints

### List All Wallets

Retrieves a paginated list of all user wallets with optional search functionality. **Admin access required**.

**Endpoint**: `GET /wallets`

**Authentication**: Required (Admin)

**Query Parameters**:
- `per_page` (integer, optional, default: 20): Number of wallets per page
- `search` (string, optional): Search by user name, email, or phone number
- `page` (integer, optional, default: 1): Page number

**Response**:
```json
{
  "success": true,
  "wallets": [
    {
      "id": 1,
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "balance": 1100.50,
      "currency": "SAR",
      "is_active": true,
      "created_at": "2024-01-15T10:30:00.000000Z",
      "updated_at": "2024-01-20T15:00:00.000000Z",
      "user": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "name": "Ahmed Mohammed",
        "email": "ahmed@example.com",
        "phone_number": "+966501234567"
      }
    }
  ],
  "pagination": {
    "current_page": 1,
    "last_page": 12,
    "per_page": 20,
    "total": 235
  }
}
```

**Error Responses**:

*500 Internal Server Error*:
```json
{
  "success": false,
  "message": "Failed to get wallets",
  "error": "Error message details"
}
```

**Example Request**:
```bash
# Get all wallets
curl -X GET "https://mediaprosocial.io/public_html/api/wallets" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -H "Accept: application/json"

# Search for specific user
curl -X GET "https://mediaprosocial.io/public_html/api/wallets?search=ahmed&per_page=10" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

### Get Wallet Statistics

Retrieves overall wallet system statistics. **Admin access required**.

**Endpoint**: `GET /wallets/statistics/all`

**Authentication**: Required (Admin)

**Response**:
```json
{
  "success": true,
  "statistics": {
    "total_wallets": 235,
    "active_wallets": 198,
    "total_balance": "485,250.75",
    "total_transactions": 1847,
    "total_credits": "625,480.00",
    "total_debits": "140,229.25"
  }
}
```

**Error Responses**:

*500 Internal Server Error*:
```json
{
  "success": false,
  "message": "Failed to get statistics",
  "error": "Error message details"
}
```

**Example Request**:
```bash
curl -X GET "https://mediaprosocial.io/public_html/api/wallets/statistics/all" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

### Credit Wallet

Add funds to a user's wallet. **Admin access required**.

**Endpoint**: `POST /wallets/{userId}/credit`

**Authentication**: Required (Admin)

**URL Parameters**:
- `userId` (string, required): The UUID of the user

**Request Body**:
```json
{
  "amount": 500.00,
  "description": "Manual credit - Customer support refund",
  "reference_id": "REFUND_12345",
  "metadata": {
    "admin_id": "admin-550e8400-e29b-41d4-a716-446655440000",
    "reason": "refund",
    "ticket_id": "TICKET_12345"
  }
}
```

**Validation Rules**:
- `amount` (numeric, required): Must be greater than 0.01
- `description` (string, required): Maximum 255 characters
- `reference_id` (string, optional): Maximum 255 characters
- `metadata` (array, optional): Additional data as JSON object

**Response**:
```json
{
  "success": true,
  "message": "Wallet credited successfully",
  "wallet": {
    "balance": 1600.50,
    "formatted_balance": "1,600.50 SAR"
  },
  "transaction": {
    "id": 3,
    "transaction_id": "c3d4e5f6-a7b8-9012-cdef-123456789012",
    "wallet_id": 1,
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "type": "credit",
    "amount": 500.00,
    "balance_after": 1600.50,
    "currency": "SAR",
    "description": "Manual credit - Customer support refund",
    "reference_id": "REFUND_12345",
    "status": "completed",
    "metadata": {
      "admin_id": "admin-550e8400-e29b-41d4-a716-446655440000",
      "reason": "refund",
      "ticket_id": "TICKET_12345"
    },
    "created_at": "2024-01-20T16:00:00.000000Z",
    "updated_at": "2024-01-20T16:00:00.000000Z"
  }
}
```

**Error Responses**:

*422 Validation Error*:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "amount": ["The amount field is required."],
    "description": ["The description field is required."]
  }
}
```

*500 Internal Server Error*:
```json
{
  "success": false,
  "message": "Failed to credit wallet",
  "error": "Error message details"
}
```

**Example Request**:
```bash
curl -X POST "https://mediaprosocial.io/public_html/api/wallets/550e8400-e29b-41d4-a716-446655440000/credit" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "amount": 500.00,
    "description": "Manual credit - Customer support refund",
    "reference_id": "REFUND_12345",
    "metadata": {
      "admin_id": "admin-550e8400-e29b-41d4-a716-446655440000",
      "reason": "refund",
      "ticket_id": "TICKET_12345"
    }
  }'
```

---

### Toggle Wallet Status

Enable or disable a user's wallet. **Admin access required**.

**Endpoint**: `POST /wallets/{userId}/toggle-status`

**Authentication**: Required (Admin)

**URL Parameters**:
- `userId` (string, required): The UUID of the user

**Request Body**: No body required

**Response**:
```json
{
  "success": true,
  "message": "Wallet status updated",
  "wallet": {
    "is_active": false
  }
}
```

**Error Responses**:

*404 Not Found*:
```json
{
  "success": false,
  "message": "Wallet not found"
}
```

*500 Internal Server Error*:
```json
{
  "success": false,
  "message": "Failed to update wallet status",
  "error": "Error message details"
}
```

**Example Request**:
```bash
curl -X POST "https://mediaprosocial.io/public_html/api/wallets/550e8400-e29b-41d4-a716-446655440000/toggle-status" \
  -H "Authorization: Bearer ADMIN_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

## Transaction Types

### Credit
Adds funds to the wallet. Sources include:
- Payment gateway recharge (Paymob)
- Manual admin credit (refunds, bonuses)
- System credits (promotions, rewards)

### Debit
Deducts funds from the wallet. Uses include:
- Service payments
- Order payments
- Subscription fees

---

## Transaction Status

- `completed`: Transaction successfully processed
- `pending`: Transaction initiated but not yet completed
- `failed`: Transaction failed to process
- `cancelled`: Transaction was cancelled

---

## Data Models

### Wallet Model
```json
{
  "id": "integer",
  "user_id": "uuid",
  "balance": "decimal(15,2)",
  "currency": "string(3)",
  "is_active": "boolean",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### WalletTransaction Model
```json
{
  "id": "integer",
  "transaction_id": "uuid",
  "wallet_id": "integer",
  "user_id": "uuid",
  "type": "enum(credit, debit)",
  "amount": "decimal(15,2)",
  "balance_after": "decimal(15,2)",
  "currency": "string(3)",
  "description": "string(255)",
  "reference_id": "string(255)|nullable",
  "status": "enum(pending, completed, failed, cancelled)",
  "metadata": "json|nullable",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

---

## Integration Example (Flutter)

### WalletService Integration

```dart
// Debit wallet for service payment
Future<bool> payWithWallet(double amount, String orderId) async {
  try {
    final userId = authService.currentUser.value?.id;
    final response = await http.post(
      Uri.parse('$baseUrl/wallets/$userId/debit'),
      headers: {
        'Authorization': 'Bearer ${authService.token}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'description': 'Service payment',
        'reference_id': orderId,
        'metadata': {
          'service_type': 'social_media_management',
          'order_id': orderId,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        // Update local wallet balance
        await fetchWallet();
        return true;
      }
    }
    return false;
  } catch (e) {
    print('Error paying with wallet: $e');
    return false;
  }
}

// Fetch wallet data
Future<void> fetchWallet() async {
  try {
    final userId = authService.currentUser.value?.id;
    final response = await http.get(
      Uri.parse('$baseUrl/wallets/$userId'),
      headers: {
        'Authorization': 'Bearer ${authService.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        currentWallet.value = Wallet.fromJson(data['wallet']);
      }
    }
  } catch (e) {
    print('Error fetching wallet: $e');
  }
}
```

---

## Error Handling

All endpoints follow a consistent error response format:

```json
{
  "success": false,
  "message": "Human-readable error message",
  "error": "Technical error details (only in development)",
  "errors": {
    "field_name": ["Validation error message"]
  }
}
```

### HTTP Status Codes

- `200 OK`: Request successful
- `400 Bad Request`: Invalid request (e.g., insufficient balance)
- `401 Unauthorized`: Authentication required or invalid token
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation errors
- `500 Internal Server Error`: Server error

---

## Security Considerations

1. **Authentication**: All endpoints require valid Sanctum token
2. **Admin Access**: Admin endpoints should have additional middleware to verify admin role
3. **Transaction Integrity**: All financial operations use database transactions (BEGIN/COMMIT/ROLLBACK)
4. **Balance Validation**: Debit operations validate sufficient balance before processing
5. **Audit Trail**: All transactions are logged with metadata for auditing
6. **Input Validation**: All user inputs are validated and sanitized

---

## Testing

### Postman Collection
Import the endpoints into Postman using the examples above.

### Test Scenarios

1. **Create Wallet**: First GET request to `/wallets/{userId}` auto-creates wallet
2. **Credit Wallet**: Admin credits 1000 SAR
3. **Check Balance**: Verify balance is 1000 SAR
4. **Debit Wallet**: Debit 200 SAR for service
5. **Verify Transaction**: Check transactions list shows both credit and debit
6. **Insufficient Balance**: Try to debit 2000 SAR (should fail)
7. **Toggle Status**: Disable wallet and try to perform operations

---

## Changelog

### Version 1.0.0 (2024-01-20)
- Initial wallet API implementation
- User endpoints: show, transactions, debit
- Admin endpoints: index, statistics, credit, toggle-status
- Support for SAR currency
- Transaction metadata support
- Pagination for transactions and wallet lists
- Search functionality for wallet list

---

## Support

For API support or bug reports, please contact the development team at:
- Email: dev@mediaprosocial.io
- Documentation: https://mediaprosocial.io/api/docs
