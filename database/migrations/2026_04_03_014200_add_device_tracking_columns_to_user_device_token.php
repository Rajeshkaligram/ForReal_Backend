<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('user_device_token')) {
            return;
        }

        Schema::table('user_device_token', function (Blueprint $table) {
            if (!Schema::hasColumn('user_device_token', 'last_seen_at')) {
                $table->dateTime('last_seen_at')->nullable()->after('device_token');
            }
            if (!Schema::hasColumn('user_device_token', 'last_seen_ip')) {
                $table->string('last_seen_ip', 64)->nullable()->after('last_seen_at');
            }
            if (!Schema::hasColumn('user_device_token', 'last_seen_user_agent')) {
                $table->string('last_seen_user_agent', 255)->nullable()->after('last_seen_ip');
            }
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('user_device_token')) {
            return;
        }

        Schema::table('user_device_token', function (Blueprint $table) {
            if (Schema::hasColumn('user_device_token', 'last_seen_user_agent')) {
                $table->dropColumn('last_seen_user_agent');
            }
            if (Schema::hasColumn('user_device_token', 'last_seen_ip')) {
                $table->dropColumn('last_seen_ip');
            }
            if (Schema::hasColumn('user_device_token', 'last_seen_at')) {
                $table->dropColumn('last_seen_at');
            }
        });
    }
};
