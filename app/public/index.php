<?php
/**
 * This file is part of the loops framework.
 *
 * @author Lukas <lukas@m-t.com>
 * @license https://raw.githubusercontent.com/loopsframework/base/master/LICENSE
 * @link https://github.com/loopsframework/base
 */

use Loops\Misc;
use Loops\Application\WebApplication;

try {
    $root_dir = realpath(__DIR__."/../..");

    require_once("$root_dir/vendor/autoload.php");

    $app = new WebApplication("$root_dir/app/");
    $app->initialize($_GET["_url"], NULL, array_diff_key($_GET, array_flip(["_url"])));
    $app->run();
}
catch(Exception $e) {
    Misc::displayException($e);
}