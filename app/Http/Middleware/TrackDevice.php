<?php

namespace App\Http\Middleware;

use App\Models\DeviceToken;
use Closure;
use Illuminate\Http\Request;

class TrackDevice
{
    public function handle(Request $request, Closure $next)
    {
        try {
            $user = auth()->guard('api')->user();

            if ($user) {
                $deviceType = (string) $request->input('device_type', '');
                $deviceToken = (string) $request->input('device_token', '');

                if ($deviceType !== '' && $deviceToken !== '') {
                    $existing = DeviceToken::query()
                        ->where('user_id', $user->id)
                        ->where('device_type', $deviceType)
                        ->where('device_token', $deviceToken)
                        ->first();

                    if (!$existing) {
                        $existing = new DeviceToken();
                        $existing->user_id = $user->id;
                        $existing->device_type = $deviceType;
                        $existing->device_token = $deviceToken;
                    }

                    $existing->last_seen_at = now();
                    $existing->last_seen_ip = $request->ip();
                    $existing->last_seen_user_agent = substr((string) $request->userAgent(), 0, 255);

                    if (!$existing->exists) {
                        $existing->created_at = now();
                    }
                    $existing->updated_at = now();
                    $existing->save();
                }
            }
        } catch (\Throwable $e) {
        }

        return $next($request);
    }
}
