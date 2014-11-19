<?php
namespace Webird;

use Phalcon\DI,
    Phalcon\Mvc\ModuleDefinitionInterface,
    Webird\Mvc\ViewBase;

/**
 * Module
 *
 */
abstract class Module implements ModuleDefinitionInterface
{
    /**
     * Returns the module view directory for external operations
     *
     * @return string
     */
    public static function getViewsDir()
    {
        return self::classNameToDir(get_called_class()) . 'views/';
    }

    public static function getViewFunc($di)
    {
        $viewsDir = self::getViewsDir();
        $viewFunc =  function() use ($di, $viewsDir) {
            $view = new ViewBase();
            $view->setDI($di);
            $view->setViewsDir($viewsDir);
            $view->setPartialsDir('../../../common/views/partials/');
            $view->setLayoutsDir('../../../common/views/layouts/');
            return $view;
        };

        return $viewFunc;
    }



    public static function classNameToDir($moduleClass)
    {
        $classParts = explode('\\', $moduleClass);
        $moduleName = lcfirst($classParts[1]);
        $moduleDir = self::moduleNameToDir($moduleName);

        return $moduleDir;
    }

    public static function moduleNameToDir($moduleName)
    {
        $config = DI::getDefault()->getConfig();
        $moduleDir = $config->path->phalconDir . "modules/{$moduleName}/";

        return $moduleDir;
    }

}