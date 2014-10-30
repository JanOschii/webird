<?php
namespace Webird\Web\Controllers;

use Webird\Controllers\BaseController,
    Webird\Auth\AuthException,
    Webird\Auth\AuthMustChangePasswordException,
    Webird\Auth\AuthRememberMeException,
    Webird\Models\Users,
    Webird\Models\ResetPasswords,
    Webird\Web\Forms\SigninForm,
    Webird\Web\Forms\SignUpForm;

/**
 * Controller used handle non-authenticated session actions like signin/signout, user signup, and forgotten passwords
 */
class SessionController extends BaseController
{

    /**
     * Default action. Set the public layout (layouts/public.volt)
     */
    public function initialize()
    {
        parent::initialize();

        $this->view->setTemplateBefore('signin');
    }

    /**
     * Default action for controller
     */
    public function indexAction()
    {

    }

    /**
     * Register a new user to the system
     */
     // TODO, FIXME this needs to be evaluated for security and configuration options
    // public function signupAction()
    // {
    //     $form = new SignUpForm();
    //     $form->setDI($this->getDI());
    //     $this->view->form = $form;
    //
    //     if ($this->request->isPost()) {
    //         if ($form->isValid($this->request->getPost()) != false) {
    //             $user = new Users();
    //             $user->assign([
    //                 'name' => $this->request->getPost('name', 'striptags'),
    //                 'email' => $this->request->getPost('email'),
    //                 'password' => $this->security->hash($this->request->getPost('password')),
    //                 'rolesId' => 2
    //             ]);
    //
    //             if ($user->save()) {
    //                 return $this->dispatcher->forward([
    //                     'controller' => 'index',
    //                     'action' => 'index'
    //                 ]);
    //             }
    //
    //             $this->flash->error($user->getMessages());
    //         }
    //     }
    // }

    /**
     * Signin with a user/password combination
     */
    public function signinAction()
    {
        // If the user is already signed in then redirect
        if ($this->auth->getUser() !== false) {
          return $this->response->redirect($this->config->app->defaultPath);
        }

        $form = new SigninForm();
        $form->setDI($this->getDI());
        $this->view->form = $form;

        try {
            if ($this->request->isPost()) {
                if ($form->isValid($this->request->getPost()) !== false) {
                    $this->auth->check([
                        'email' => $this->request->getPost('email'),
                        'password' => $this->request->getPost('password'),
                        'remember' => $this->request->getPost('remember')
                    ]);

                    return $this->response->redirect($this->config->app->defaultPath);
                }
            } else {
                if ($this->auth->hasRememberMe()) {
                    $this->auth->signinWithRememberMe();
                    $this->response->redirect($this->config->app->defaultPath);
                }
            }
        } catch (AuthMustChangePasswordException $e) {
            $this->response->redirect('settings/changePassword');
        } catch (AuthRememberMeException $e) {
            $this->response->redirect('signin');
        } catch (AuthException $e) {
            $this->flash->error($e->getMessage());
        }
    }

    /**
     * Sign in with the OAuth callback redirected from the Oauth provider
     */
    public function signinOauthAction()
    {
        // $form = new SigninForm();
        // $form->setDI($this->getDI());
        // $this->view->form = $form;

        $provider = $this->dispatcher->getParam('provider');
        $code = $this->request->get('code');
        if (! is_string($code)) {
            $this->flash->error($this->translate('The OAuth provider information is invalid.'));
            return false;
        }

        try {
            $this->auth->checkOauth($provider, $code);
            return $this->response->redirect($this->config->app->defaultPath);
        } catch (AuthMustChangePasswordException $e) {
            return $this->response->redirect('settings/changePassword');
        } catch (AuthException $e) {
            $this->flash->error($e->getMessage());
        }
    }

    /**
     * Redirects to the Oauth provider url
     */
    public function signinRedirectOauthAction()
    {
        $provider = $this->dispatcher->getParam('provider');
        $nonce = $this->dispatcher->getParam('nonce');
        if ($nonce != 'nonce') {
            error_log('nonce is not set correctly');
        }

        $authUrl = $this->auth->getRedirectOauthUrl($provider);

        $this->response->redirect($authUrl, true);
        $this->response->send();
        return false;
    }

    /**
     * Closes the session
     */
    public function signoutAction()
    {
        $this->auth->remove();
        return $this->response->redirect('index');
    }

}