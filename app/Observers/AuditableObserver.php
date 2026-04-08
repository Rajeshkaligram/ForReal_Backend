<?php

namespace App\Observers;

use App\Models\AuditLog;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Arr;

class AuditableObserver
{
    private array $ignoredAttributes = [
        'created_at',
        'updated_at',
        'deleted_at',
        'remember_token',
    ];

    public function created(Model $model): void
    {
        $this->writeLog('created', $model, null, $this->filterValues($model->getAttributes()));
    }

    public function updated(Model $model): void
    {
        $dirty = $model->getDirty();
        $newValues = $this->filterValues($dirty);

        if ($newValues === []) {
            return;
        }

        $original = Arr::only($model->getOriginal(), array_keys($dirty));
        $oldValues = $this->filterValues($original);

        $this->writeLog('updated', $model, $oldValues, $newValues);
    }

    public function deleted(Model $model): void
    {
        $this->writeLog('deleted', $model, $this->filterValues($model->getOriginal()), null);
    }

    private function filterValues(?array $values): ?array
    {
        if ($values === null) {
            return null;
        }

        foreach ($this->ignoredAttributes as $key) {
            unset($values[$key]);
        }

        return $values;
    }

    private function writeLog(string $event, Model $model, ?array $oldValues, ?array $newValues): void
    {
        try {
            $request = null;
            if (function_exists('request')) {
                $request = request();
            }

            $routeName = null;
            if ($request && $request->route()) {
                $routeName = $request->route()->getName();
            }

            AuditLog::query()->create([
                'actor_user_id' => function_exists('auth') ? auth()->id() : null,
                'event' => $event,
                'auditable_type' => $model::class,
                'auditable_id' => is_numeric($model->getKey()) ? (int) $model->getKey() : null,
                'url' => $request ? $request->fullUrl() : null,
                'route' => $routeName,
                'method' => $request ? $request->method() : null,
                'ip' => $request ? $request->ip() : null,
                'user_agent' => $request ? (string) $request->userAgent() : null,
                'old_values' => $oldValues,
                'new_values' => $newValues,
                'created_at' => now(),
            ]);
        } catch (\Throwable $e) {
        }
    }
}
