$baseUrl = "https://rentasuit-backend.onrender.com/api/v1.0"
$testEmail = "demo2026@gmail.com"
$testPassword = "password"

Write-Host "--- Rent A Suit FULL API v1.0 Production Test ---" -ForegroundColor Cyan

# Helper function for JSON requests
function Invoke-ApiRequest {
    param($Path, $Method = "Get", $Body = $null, $Headers = $null)
    $uri = "$baseUrl/$Path"
    
    # Simple GET params construction if it's a GET and body is provided
    if ($Method -eq "Get" -and $Body -ne $null) {
        $query = ""
        foreach($key in $Body.Keys) {
            $query += "$key=$($Body[$key])&"
        }
        $uri = "$uri?$($query.TrimEnd('&'))"
        $Body = $null # Reset body for GET
    }

    $params = @{
        Uri = $uri
        Method = $Method
        ContentType = "application/json"
        ErrorAction = "Stop"
    }
    
    if ($Body) { $params.Body = ($Body | ConvertTo-Json) }
    if ($Headers) { $params.Headers = $Headers }

    try {
        $res = Invoke-RestMethod @params
        return $res
    } catch {
        throw $_
    }
}

# 1. AUTHENTICATION (Public)
Write-Host "`n[1/4] Testing Authentication..." -ForegroundColor Yellow
try {
    $signinBody = @{ email = $testEmail; password = $testPassword; device_token = "test-token"; device_type = "Android" }
    $res = Invoke-ApiRequest -Path "signin" -Method Post -Body $signinBody
    $apiToken = $res.data.api_token
    if ($apiToken) {
        Write-Host "  OK: /signin (Token: $($apiToken.Substring(0,10))...)" -ForegroundColor Green
    } else {
        Write-Host "  FAILED: /signin (No token returned)" -ForegroundColor Red
        return
    }
} catch { 
    Write-Host "  FAILED: /signin ($($_.Exception.Message))" -ForegroundColor Red
    return 
}

$authHeaders = @{ "Authorization" = "Bearer $apiToken"; "Accept" = "application/json" }

# 2. PUBLIC DATA
Write-Host "`n[2/4] Testing Public Routes..." -ForegroundColor Yellow
$publicRoutes = @(
    @{ name = "category-list"; path = "category-list" },
    @{ name = "product-list"; path = "product-list" },
    @{ name = "product-search"; path = "product-search?keyword=suit" },
    @{ name = "new-added-product"; path = "new-added-product" },
    @{ name = "product-detail"; path = "product-detail?product_id=488" },
    @{ name = "reviews"; path = "reviews?product_id=488" },
    @{ name = "common-dropdowns"; path = "common-dropdowns" },
    @{ name = "cleaner-list"; path = "cleaner-list" },
    @{ name = "faqs-list"; path = "faqs-list" }
)

foreach ($route in $publicRoutes) {
    try {
        $res = Invoke-ApiRequest -Path $route.path
        Write-Host "  OK: /$($route.name)" -ForegroundColor Green
    } catch { Write-Host "  FAILED: /$($route.name) ($($_.Exception.Message))" -ForegroundColor Red }
}

# 3. USER PROFILE (Authenticated)
Write-Host "`n[3/4] Testing User Profile Routes..." -ForegroundColor Yellow
$userRoutes = @(
    @{ name = "profile"; path = "profile"; method = "Get" },
    @{ name = "notification-list"; path = "notification-list"; method = "Get" }
)

foreach ($route in $userRoutes) {
    try {
        $res = Invoke-ApiRequest -Path $route.path -Method $route.method -Headers $authHeaders
        Write-Host "  OK: /$($route.name)" -ForegroundColor Green
    } catch { Write-Host "  FAILED: /$($route.name) ($($_.Exception.Message))" -ForegroundColor Red }
}

# 4. SHOP OPERATIONS (Authenticated)
Write-Host "`n[4/4] Testing Shop & Business Routes..." -ForegroundColor Yellow
$shopRoutes = @(
    @{ name = "cart/list"; path = "cart/list" },
    @{ name = "wish-list"; path = "wish-list" },
    @{ name = "messages"; path = "messages" },
    @{ name = "rented-list"; path = "rented-list" },
    @{ name = "transactions"; path = "transactions" },
    @{ name = "my-added-products"; path = "my-added-products" },
    @{ name = "booking-list"; path = "booking-list" }
)

foreach ($route in $shopRoutes) {
    try {
        $res = Invoke-ApiRequest -Path $route.path -Headers $authHeaders
        Write-Host "  OK: /$($route.name)" -ForegroundColor Green
    } catch { Write-Host "  FAILED: /$($route.name) ($($_.Exception.Message))" -ForegroundColor Red }
}

Write-Host "`n--- Test Complete ---" -ForegroundColor Cyan
