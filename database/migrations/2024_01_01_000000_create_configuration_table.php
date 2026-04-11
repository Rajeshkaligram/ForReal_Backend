<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('configuration', function (Blueprint $table) {
            $table->id();
            $table->string('name')->nullable();
            $table->string('email')->nullable();
            $table->string('logo')->nullable();
            $table->string('logo_footer')->nullable();
            $table->text('copyright')->nullable();
            $table->string('phone_number')->nullable();
            $table->decimal('commision', 10, 2)->default(0);
            $table->text('social_media_links')->nullable();
            $table->string('paypal_client_id')->nullable();
            $table->string('paypal_client_secret')->nullable();
            $table->string('paypal_live_client_id')->nullable();
            $table->string('paypal_live_client_secret')->nullable();
            $table->enum('paypal_mode', ['sandbox', 'live'])->default('sandbox');
            $table->timestamps();
        });

        // Insert default configuration row
        DB::table('configuration')->insert([
            'name' => 'ForReal',
            'email' => 'admin@example.com',
            'copyright' => '© 2024 ForReal. All rights reserved.',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('configuration');
    }
};
