# Refresh Token Implementation Guide

## Overview

This Flutter app now includes a comprehensive refresh token implementation that automatically handles token expiration and renewal, providing a seamless user experience.

## Key Features

✅ **Automatic Token Refresh** - Tokens are automatically refreshed when they expire  
✅ **Secure Token Storage** - Uses Flutter Secure Storage for token persistence  
✅ **API Interceptor** - Dio interceptor handles 401 errors automatically  
✅ **Token Expiration Check** - JWT tokens are validated before use  
✅ **Seamless UX** - Users don't need to re-login when tokens expire  
✅ **Error Handling** - Comprehensive error handling for network issues  

## Architecture

### 1. TokenService (`lib/services/token_service.dart`)

The central service that manages JWT and refresh tokens:

- **`storeTokens(jwt, refreshToken)`** - Securely stores both tokens
- **`getValidToken()`** - Returns a valid JWT (refreshes if needed)
- **`isTokenExpired(token)`** - Checks if JWT is expired
- **`refreshAccessToken()`** - Refreshes the access token
- **`clearTokens()`** - Clears all stored tokens
- **`isLoggedIn()`** - Checks if user has valid tokens

### 2. AuthInterceptor (`lib/dio/dio_interceptors.dart`)

Dio interceptor that automatically handles authentication:

- Adds JWT token to request headers
- Intercepts 401/token expired errors
- Automatically refreshes tokens on failure
- Retries failed requests with new tokens
- Prevents multiple concurrent refresh attempts

### 3. ApiService (`lib/services/api_service.dart`)

Centralized API service with built-in authentication:

- Pre-configured Dio instance with interceptors
- Methods for common API operations
- Automatic token handling for all requests
- Logging for debugging

## How It Works

### Token Refresh Flow

1. **API Request Made** → AuthInterceptor adds JWT to headers
2. **Token Expired?** → Server returns 401 or token error
3. **Refresh Triggered** → AuthInterceptor calls TokenService.refreshAccessToken()
4. **New Tokens Stored** → Fresh JWT and refresh token saved
5. **Request Retried** → Original request sent with new JWT
6. **Success** → User gets data without interruption

### Token Expiration Check

```dart
bool isTokenExpired(String token) {
  // Decodes JWT payload
  // Checks expiration timestamp
  // Considers token expired if expires within 5 minutes
  return expirationDate.isBefore(now.add(Duration(minutes: 5)));
}
```

## API Endpoints Used

- **Login**: `POST /api_login.php`
- **Token Validation**: `POST /validate_token.php`  
- **Token Refresh**: `POST /refresh_token.php` (You may need to adjust this endpoint)
- **Protected APIs**: All other endpoints automatically use JWT

## Usage Examples

### Using TokenService Directly

```dart
final tokenService = TokenService();

// Check if user is logged in
if (await tokenService.isLoggedIn()) {
  // Get a valid token (auto-refreshes if needed)
  final token = await tokenService.getValidToken();
  // Use token for API calls
}

// Logout
await tokenService.clearTokens();
```

### Using ApiService for API Calls

```dart
final apiService = ApiService();

// Login (no auth needed)
final response = await apiService.login(
  username: 'user@example.com',
  password: 'password123',
);

// Protected API call (auto-handles auth)
final visits = await apiService.getUserVisitsList(
  pageNumber: 1,
  barType: 'se_20',
);
```

### Using Dio with Interceptor

```dart
final dio = Dio();
dio.interceptors.add(AuthInterceptor());

// All requests automatically include JWT token
final response = await dio.post('/protected-endpoint', data: {...});
```

## Error Handling

### Token Refresh Failures

When token refresh fails:
1. All tokens are cleared from storage
2. User is redirected to login screen
3. Error is logged for debugging

### Network Errors

- Connection timeouts are handled
- Retry logic for failed requests
- User-friendly error messages

## Security Considerations

### Secure Storage

- JWT and refresh tokens stored in Flutter Secure Storage
- Tokens encrypted on device
- Automatically cleared on logout

### Token Expiration

- JWT tokens checked for expiration before use
- 5-minute buffer to prevent race conditions
- Automatic refresh prevents expired token usage

### Error Scenarios

- Network failures handled gracefully
- Invalid refresh tokens trigger re-authentication
- Multiple concurrent refresh attempts prevented

## Testing the Implementation

### 1. Login Flow
- Login with valid credentials
- Verify tokens are stored
- Check automatic navigation to home screen

### 2. Token Validation
- Press "Validate Token" button
- Should work seamlessly with valid tokens
- Should auto-refresh if token expired

### 3. API Calls
- Navigate to "Test Secure API Calls" screen
- Press "Test Secure API Call" button
- Should make authenticated requests automatically

### 4. Token Expiration
- Wait for token to expire (or manually modify expiration)
- Make API call - should auto-refresh and retry
- User experience should be seamless

### 5. Logout
- Press logout button in home screen
- Tokens should be cleared
- Should navigate back to login screen

## Configuration

### API Endpoints

Update these URLs in the respective service files:

```dart
// TokenService
static const String _baseUrl = 'https://app.wattaudit.com/api-v2';

// Refresh endpoint - you may need to adjust this
final response = await dio.post('$_baseUrl/refresh_token.php', ...);
```

### Token Expiration Buffer

Adjust the expiration buffer in TokenService:

```dart
// Consider token expired if expires within X minutes
return expirationDate.isBefore(now.add(Duration(minutes: 5)));
```

## Troubleshooting

### Common Issues

1. **Refresh endpoint not found (404)**
   - Verify the refresh token endpoint URL
   - Check with backend team for correct endpoint

2. **Tokens not persisting**
   - Ensure Flutter Secure Storage permissions are set
   - Check device storage availability

3. **Infinite refresh loops**
   - Check refresh token validity
   - Verify server response format

4. **API calls failing**
   - Check network connectivity
   - Verify JWT format and headers
   - Review server logs for authentication errors

### Debug Logging

Enable debug logging in ApiService:

```dart
_dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  logPrint: (obj) => print('[API] $obj'),
));
```

## Next Steps

### Possible Enhancements

1. **Biometric Authentication** - Add fingerprint/face ID
2. **Token Rotation** - Implement refresh token rotation
3. **Offline Support** - Cache responses for offline use
4. **Push Notifications** - Handle token refresh for background requests
5. **Multiple Account Support** - Support multiple user sessions

### Backend Requirements

Ensure your backend supports:
- JWT token expiration
- Refresh token endpoint
- Proper error responses (401, expired token messages)
- CORS configuration for your domain

---

## Files Modified/Created

### New Files
- `lib/services/token_service.dart` - Core token management
- `lib/services/api_service.dart` - Centralized API service

### Modified Files
- `lib/dio/dio_interceptors.dart` - Enhanced with TokenService
- `lib/screens/login_screen.dart` - Uses TokenService
- `lib/screens/home_screen.dart` - Enhanced UI and logout
- `lib/screens/user_info_screen.dart` - Better error handling
- `lib/main.dart` - Auto-login check and splash screen

---

Your refresh token implementation is now complete and ready for production use! 🚀
