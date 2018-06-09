#!/bin/bash

#                        _                                   
#   ___ _ __ _   _ _ __ | |_ ___  _ __    ___ ___  _ __ ___  
#  / __| '__| | | | '_ \| __/ _ \| '_ \  / __/ _ \| '_ ` _ \ 
# | (__| |  | |_| | | | | || (_) | | | || (_| (_) | | | | | |
#  \___|_|   \__, |_| |_|\__\___/|_| |_(_)___\___/|_| |_| |_|
#            |___/                                           
#

# install TYPO3 if INSTALL_TYPO3 = true
if [ "${INSTALL_TYPO3}" = "true" ]; then
    echo "Check if composer.json exists..."
    if [ -f "${DOCUMENT_ROOT}/composer.json" ]; then
        echo "The file composer.json exists! Skip TYPO3 installation..."
    else
        echo "The file composer.json does not exists! Install TYPO3 ${TYPO3_VERSION}..."
        composer create-project typo3/cms-base-distribution typo3 ${TYPO3_VERSION}
        if [ $? -ne 0 ]; then
            echo "Something went wrong while installing TYPO3 :( Please check the composer output above!"
            exit 1
        fi
    fi
else
    echo "Installation of TYPO3 will be skipped because INSTALL_TYPO3 does not equal true..."
fi

# start open-ssh server if START_SSHD = true
if [ "${START_SSHD}" = "true" ]; then
    echo "Start openssh-server..."
    /usr/sbin/sshd -D
        if [ $? -ne 0 ]; then
            echo "Something went wrong while starting openssh-server..."
            exit 1
        fi
fi

# start apache2 server
echo "Start apache2..."
apache2-foreground