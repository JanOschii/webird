<?php
namespace Webird\Cli\Tasks;

use Phalcon\Mvc\View\Engine\Volt\Compiler as Compiler,
    Phalcon\Mvc\View\Engine\Volt,
    React\EventLoop\Factory as EventLoopFactory,
    React\ChildProcess\Process,
    Webird\Cli\TaskBase,
    Webird\Mvc\ViewBase,
    Webird\Web\Module as WebModule,
    Webird\Admin\Module as AdminModule;

/**
 * Task for Build
 *
 */
class BuildTask extends TaskBase
{

    public function mainAction(array $params)
    {
        $this->cleanDirectoryStructure();
        $this->buildDirectoryStructure();

        // Build Volt templates first so that the locale messages can be
        // extracted in case of an error
        $this->compileVoltTemplates();

        $this->buildPhalconDir();
        $this->makeEntryPoints();
        $this->copyFiles();
        $this->buildWebpack();

        exit(0);
    }





    private function buildPhalconDir()
    {
        $config = $this->config;
        $phalconDir = $config->path->phalconDir;
        $distDir = $config->dev->path->distDir;

        $distDirEsc = escapeshellarg($distDir);
        $phalconAppDirEsc = escapeshellarg($phalconDir);
        $phalconDistDirEsc = escapeshellarg("$distDir/phalcon");

        if (! isset($config['dev']['phpEncode'])) {
            throw new \Exception('The PHP Encoder value is not set.', 1);
        }
        $phpEncode = $config->dev->phpEncode;

        if (empty($phpEncode)) {
            `cp -R $phalconAppDirEsc $phalconDistDirEsc`;
        } else {
            if (! isset($config->dev->phpEncoders[$phpEncode])) {
                throw new \Exception("The '$phpEncode' PHP encoder setting does not exist", 1);
            }

            $encoder = $config->dev->phpEncoders[$phpEncode];
            $encCmdEsc = escapeshellcmd($encoder->path);
            switch ($phpEncode) {
                case 'ioncube':
                    $cmd = "$encCmdEsc $phalconAppDirEsc --into $distDirEsc --merge-target";
                    exec($cmd, $out, $ret);
                    break;
            }
        }
    }





    private function cleanDirectoryStructure()
    {
        $projectDir = $this->config->dev->path->projectDir;
        $distDir = $this->config->dev->path->distDir;
        $distDirEsc = escapeshellarg($distDir);

        // TODO: Add more checks for disasters against the rm -Rf command
        // Check for some disaster cases since the script will try to recursively delete the folder
        if ($distDir != "{$projectDir}dist/" || $distDir == '' || $distDir == '/') {
            throw new \Exception('Critical Error: Attempting to delete dist directory when it is not set correctly.');
        }
        if (file_exists($distDir)) {
            exec("rm -Rf $distDirEsc", $out, $ret);
            if ($ret != 0) {
                throw new \Exception('There was a problem deleting the dist directory.');
            }
        }
    }






    private function buildDirectoryStructure()
    {
        $appDir = $this->config->path->appDir;
        $projectDir = $this->config->dev->path->projectDir;
        $distDir = $this->config->dev->path->distDir;

        mkdir($distDir);
        mkdir($distDir . 'public/');
        mkdir($distDir . 'etc/');
        mkdir($distDir . 'cache-static/');
        mkdir($distDir . 'cache-static/volt/');
    }







    private function compileVoltTemplates()
    {
        $path = $this->config->path;
        $dev = $this->config->dev;

        $voltCompileDirBak = $path->voltCompileDir;
        $voltCompileDirDist = $dev->path->distDir . "cache-static/volt/";
        $path->voltCompileDir = $voltCompileDirDist;
        echo "Temporarily changing voltCompilePath to {$voltCompileDirDist}\n";

        $di = $this->getDI();

        try {
            $this->compileVoltTemplateForModule('admin');
            $this->compileVoltTemplateForModule('web');
        } catch (\Exception $e) {
            error_log($e->getMessage());
        }

        // Simple views
        $viewsDir = "{$this->config->path->viewsSimpleDir}";
        $this->compileVoltDir($viewsDir, function() use ($di) {
            return $di->get('viewSimple');
        });

        $path->voltCompileDir = $voltCompileDirBak;
        echo "Reverting voltCompileDir to original path\n";
    }







    private function compileVoltTemplateForModule($moduleName)
    {
        $di = $this->getDI();

        $moduleClass = '\\Webird\\' . ucfirst($moduleName) . '\\Module';

        $viewFunc = $moduleClass::getViewFunc($di);

        $view = $viewFunc();
        $viewsDir = $view->getViewsDir();
        $viewsLayoutsDir = $viewsDir . $view->getLayoutsDir();
        $viewsPartialsDir = $viewsDir . $view->getPartialsDir();

        $this->compileVoltDir($viewsDir, $viewFunc);
        $this->compileVoltDir($viewsPartialsDir, $viewFunc);
        $this->compileVoltDir($viewsLayoutsDir, $viewFunc);
    }







    private function compileVoltDir($path, $viewFunc)
    {
        $config = $this->config;
        $phalconDir = $config->path->phalconDir;
        $distDir = $config->dev->path->distDir;
        $voltPath = "$distDir/cache/volt";

        $dh = opendir($path);
        while (($fileName = readdir($dh)) !== false) {
            if ($fileName == '.' || $fileName == '..')
                continue;

            // $pathNext = "$path/$fileName";
            $pathNext = "{$path}{$fileName}";
            if (is_dir($pathNext)) {
                $this->compileVoltDir("$pathNext/", $viewFunc);
            } else {
                $di = $this->getDI();

                $view = $viewFunc();
                $volt = $di->get('voltService', [$view, $di]);
                $compiler = $volt->getCompiler();
                $compiler->compile($pathNext);
            }
        }

        // close the directory handle
        closedir($dh);
    }








    private function makeEntryPoints()
    {
        $distDir = $this->config->dev->path->distDir;

        $cliEntry = <<<'WEBIRD_ENTRY'
#!/usr/bin/env php
<?php
define('ENVIRONMENT', 'dist');
require(__DIR__ . '/phalcon/bootstrap_cli.php');
WEBIRD_ENTRY;
        file_put_contents("$distDir/webird.php", $cliEntry);
        chmod("$distDir/webird.php", 0775);

        $webEntry = <<<'WEBIRD_ENTRY'
<?php
define('ENVIRONMENT', 'dist');
require('../phalcon/bootstrap_webserver.php');
WEBIRD_ENTRY;
        file_put_contents("$distDir/public/index.php", $webEntry);
    }








    private function copyFiles()
    {
        // configuration directories
        $projectDir = $this->config->dev->path->projectDir;
        $appDir = $this->config->path->appDir;
        $etcDir = $this->config->dev->path->etcDir;
        $devDir = $this->config->dev->path->devDir;
        $distDir = $this->config->dev->path->distDir;
        // shell escaped configuration directories
        $appDirEsc = escapeshellarg($appDir);
        $projectDirEsc = escapeshellarg($projectDir);
        $devDirEsc = escapeshellarg($devDir);
        $distDirEsc = escapeshellarg($distDir);

        // Exclude .po files (keep .mo) since webpack reads from the source folder
        `rsync -rv --exclude=*.po $appDir/locale $distDir`;
        // Copy the Composer installed libraries
        // TODO: Consider other ways to install to remove dev dependencies
        `cp -R $devDir/vendor $distDir/vendor`;

        `cp -R $appDir/theme/assets $distDir/public/assets`;

        copy("$etcDir/schema.sql", "$distDir/etc/schema.sql");
        copy("$etcDir/templates/nginx_dist", "$distDir/etc/nginx_template");
        // Move the CLI startup program to the root dist directory
        chmod("$distDir/webird.php", 0775);

        // TODO: Check for errors here
        // Read the dist environment defaults
        $fileDefaults = file_get_contents("$etcDir/dist_defaults.json");
        $configDefaults = json_decode($fileDefaults, true);
        // Read the dist environment custom settings
        $fileCustom = file_get_contents("$etcDir/dist.json");
        $configCustom = json_decode($fileCustom, true);
        // Merge the custom settings over the defaults
        $configMerged = array_replace_recursive($configDefaults, $configCustom);
        // Write the merged settings to the dist directory
        $jsonConfigMerged = json_encode($configMerged, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        file_put_contents("$distDir/config.json", $jsonConfigMerged);

        // $acl = $this->getDI()->get('acl');
        // $acl->saveSerialized("$distDir/cache/acl.serialized.data");
    }






    private function buildWebpack()
    {
        $devDirEsc = escapeshellarg($this->config->dev->path->devDir);

        echo "Building webpack bundle.  This can take 5-30 seconds.\n";
        exec("cd $devDirEsc && npm run build", $out, $ret);
        if ($ret != 0) {
            throw new \Exception('Webpack build error.');
        }
    }

}