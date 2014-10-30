<?php
namespace Webird\Mvc;

use Phalcon\Mvc\View;

/**
 * Console class for all CLI applications
 */
class ViewBase extends View
{
    /**
     * Constructor
     *
     * @param \Phalcon\DI   $di
     */
    public function __construct($options = null)
    {
        parent::__construct($options);
    }


     public function render($controllerName, $actionName, $params = null)
     {
        $config = $this->getDI()->get('config');

        $this->registerEngines([
            '.volt' => 'voltService'
        ]);

        $this->setVars([
            'ENVIRONMENT' => ENVIRONMENT,
            'path'   => $this->getWebBundlePath(),
            'domain' => $config->site->domain,
            'link'   => $config->site->link
        ]);

        return parent::render($controllerName, $actionName, $params);
     }



    /**
     * Retrieve public Webpack bundle path
     *
     * Sets path for retrieving webpack files. This is retrievable from views
     */
    private function getWebBundlePath()
    {
        $config = $this->getDI()->get('config');

        switch (ENVIRONMENT) {
            case 'dist':
                $path = '';
                break;
            // For development use the node webpack-dev-server to deliver the assets
            case 'dev':
                $webpackPort = $config['dev']['webpackPort'];
                $domain = $config['site']['domain'];
                $path = "http://{$domain}:{$webpackPort}/";
                break;
            default:
                $path = '';
                break;
        }

        return $path;
    }

}