<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

use App\Models\Configuration;

use View;

class Controller extends BaseController{

    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;

    public function __construct()
    {
        try {
            $this->data['configuration'] = Configuration::find(1);
        } catch (\Exception $e) {
            $this->data['configuration'] = null;
        }
        View::share($this->data);
    }

}