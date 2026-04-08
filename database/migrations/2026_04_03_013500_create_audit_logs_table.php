<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedBigInteger('actor_user_id')->nullable();
            $table->string('event', 32);
            $table->string('auditable_type', 191);
            $table->unsignedBigInteger('auditable_id')->nullable();
            $table->string('url', 2048)->nullable();
            $table->string('route', 191)->nullable();
            $table->string('method', 16)->nullable();
            $table->string('ip', 64)->nullable();
            $table->string('user_agent', 1024)->nullable();
            $table->json('old_values')->nullable();
            $table->json('new_values')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['auditable_type', 'auditable_id'], 'idx_audit_logs_auditable');
            $table->index(['actor_user_id', 'created_at'], 'idx_audit_logs_actor_created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
