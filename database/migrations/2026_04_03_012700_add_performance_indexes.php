<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    private function indexExists(string $table, string $indexName): bool
    {
        $dbName = DB::getDatabaseName();
        $result = DB::select(
            'SELECT 1 FROM information_schema.statistics WHERE table_schema = ? AND table_name = ? AND index_name = ? LIMIT 1',
            [$dbName, $table, $indexName]
        );

        return !empty($result);
    }

    private function createIndexIfMissing(string $table, string $indexName, string $createSql): void
    {
        if (!$this->indexExists($table, $indexName)) {
            DB::statement($createSql);
        }
    }

    private function dropIndexIfExists(string $table, string $indexName): void
    {
        if ($this->indexExists($table, $indexName)) {
            DB::statement("DROP INDEX {$indexName} ON {$table}");
        }
    }

    public function up(): void
    {
        if (DB::getDriverName() !== 'mysql') {
            return;
        }

        if (Schema::hasTable('users')) {
            // email is TEXT in legacy schema, so use a prefix index.
            $this->createIndexIfMissing('users', 'idx_users_email', 'CREATE INDEX idx_users_email ON users (email(191))');
            $this->createIndexIfMissing('users', 'idx_users_status', 'CREATE INDEX idx_users_status ON users (status)');
            $this->createIndexIfMissing('users', 'idx_users_privilege', 'CREATE INDEX idx_users_privilege ON users (privilege)');
            $this->createIndexIfMissing('users', 'idx_users_is_deleted', 'CREATE INDEX idx_users_is_deleted ON users (is_deleted)');
        }

        if (Schema::hasTable('products')) {
            $this->createIndexIfMissing('products', 'idx_products_user_id', 'CREATE INDEX idx_products_user_id ON products (user_id)');
            $this->createIndexIfMissing('products', 'idx_products_is_deleted', 'CREATE INDEX idx_products_is_deleted ON products (is_deleted)');
            $this->createIndexIfMissing('products', 'idx_products_created_at', 'CREATE INDEX idx_products_created_at ON products (created_at)');
        }

        if (Schema::hasTable('rent_details')) {
            $this->createIndexIfMissing('rent_details', 'idx_rent_details_user_id', 'CREATE INDEX idx_rent_details_user_id ON rent_details (user_id)');
            $this->createIndexIfMissing('rent_details', 'idx_rent_details_product_id', 'CREATE INDEX idx_rent_details_product_id ON rent_details (product_id)');
            // status is TEXT in legacy schema
            $this->createIndexIfMissing('rent_details', 'idx_rent_details_status', 'CREATE INDEX idx_rent_details_status ON rent_details (status(191))');
            $this->createIndexIfMissing('rent_details', 'idx_rent_details_created_at', 'CREATE INDEX idx_rent_details_created_at ON rent_details (created_at)');
        }

        if (Schema::hasTable('wishlist')) {
            $this->createIndexIfMissing('wishlist', 'idx_wishlist_user_id', 'CREATE INDEX idx_wishlist_user_id ON wishlist (user_id)');
            $this->createIndexIfMissing('wishlist', 'idx_wishlist_product_id', 'CREATE INDEX idx_wishlist_product_id ON wishlist (product_id)');
        }

        if (Schema::hasTable('user_device_token')) {
            $this->createIndexIfMissing('user_device_token', 'idx_user_device_token_user_id', 'CREATE INDEX idx_user_device_token_user_id ON user_device_token (user_id)');
            $this->createIndexIfMissing('user_device_token', 'idx_user_device_token_device_type', 'CREATE INDEX idx_user_device_token_device_type ON user_device_token (device_type)');
            // device_token is TEXT in legacy schema
            $this->createIndexIfMissing('user_device_token', 'idx_user_device_token_device_token', 'CREATE INDEX idx_user_device_token_device_token ON user_device_token (device_token(191))');
        }
    }

    public function down(): void
    {
        if (DB::getDriverName() !== 'mysql') {
            return;
        }

        if (Schema::hasTable('users')) {
            $this->dropIndexIfExists('users', 'idx_users_email');
            $this->dropIndexIfExists('users', 'idx_users_status');
            $this->dropIndexIfExists('users', 'idx_users_privilege');
            $this->dropIndexIfExists('users', 'idx_users_is_deleted');
        }

        if (Schema::hasTable('products')) {
            $this->dropIndexIfExists('products', 'idx_products_user_id');
            $this->dropIndexIfExists('products', 'idx_products_is_deleted');
            $this->dropIndexIfExists('products', 'idx_products_created_at');
        }

        if (Schema::hasTable('rent_details')) {
            $this->dropIndexIfExists('rent_details', 'idx_rent_details_user_id');
            $this->dropIndexIfExists('rent_details', 'idx_rent_details_product_id');
            $this->dropIndexIfExists('rent_details', 'idx_rent_details_status');
            $this->dropIndexIfExists('rent_details', 'idx_rent_details_created_at');
        }

        if (Schema::hasTable('wishlist')) {
            $this->dropIndexIfExists('wishlist', 'idx_wishlist_user_id');
            $this->dropIndexIfExists('wishlist', 'idx_wishlist_product_id');
        }

        if (Schema::hasTable('user_device_token')) {
            $this->dropIndexIfExists('user_device_token', 'idx_user_device_token_user_id');
            $this->dropIndexIfExists('user_device_token', 'idx_user_device_token_device_type');
            $this->dropIndexIfExists('user_device_token', 'idx_user_device_token_device_token');
        }
    }
};
