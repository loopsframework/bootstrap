<?php

use Loops\Misc;
use Loops\Application\CliApplication;

use Doctrine\ORM\Tools\Console\ConsoleRunner;

require_once(__DIR__."/vendor/autoload.php");

class HelperSetCreator extends CliApplication {
    public function exec($params) {
        $entity_manager = $this->getLoops()->getService("doctrine");
        return ConsoleRunner::createHelperSet($entity_manager);
    }
}

try {
    return (new HelperSetCreator(__DIR__."/../app/"))->run();
}
catch(Exception $e) {
    Misc::displayException($e, FALSE);
}