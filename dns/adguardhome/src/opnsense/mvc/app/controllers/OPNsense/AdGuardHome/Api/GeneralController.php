<?php

/*
 * Copyright (C) 2025 Joe Roback <joe.roback@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

namespace OPNsense\AdGuardHome\Api;

use OPNsense\Base\ApiMutableModelControllerBase;

class GeneralController extends ApiMutableModelControllerBase
{
    protected static $internalModelName = 'adguardhome';
    protected static $internalModelClass = 'OPNsense\AdGuardHome\AdGuardHome';

    private static $apikeyPath = '/usr/local/etc/adguardhome.apikey';

    public function setAction()
    {
        if ($this->request->isPost()) {
            $postData = $this->request->getPost();
            $plainPassword = null;
            $username = null;

            if (
                isset($postData['adguardhome']['general']['password'])
                && !empty(trim($postData['adguardhome']['general']['password']))
            ) {
                $plainPassword = $postData['adguardhome']['general']['password'];
                if (!preg_match('/^\$2[ayb]\$/', $plainPassword)) {
                    $hashedPassword = password_hash($plainPassword, PASSWORD_BCRYPT);
                    $_POST['adguardhome']['general']['password'] = $hashedPassword;
                } else {
                    $plainPassword = null;
                }
            }

            if (isset($postData['adguardhome']['general']['username'])) {
                $username = $postData['adguardhome']['general']['username'];
            }

            $result = parent::setAction();

            if ($plainPassword !== null && $username !== null) {
                @file_put_contents(
                    self::$apikeyPath,
                    $username . "\n" . $plainPassword . "\n",
                    LOCK_EX
                );
                @chmod(self::$apikeyPath, 0600);
            } elseif ($username !== null && file_exists(self::$apikeyPath)) {
                $lines = @file(self::$apikeyPath, FILE_IGNORE_NEW_LINES);
                if ($lines !== false && count($lines) >= 2) {
                    @file_put_contents(
                        self::$apikeyPath,
                        $username . "\n" . $lines[1] . "\n",
                        LOCK_EX
                    );
                }
            }

            return $result;
        }
        return parent::setAction();
    }
}
