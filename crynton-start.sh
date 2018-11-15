#!/bin/bash

#                        _                                   
#   ___ _ __ _   _ _ __ | |_ ___  _ __    ___ ___  _ __ ___  
#  / __| '__| | | | '_ \| __/ _ \| '_ \  / __/ _ \| '_ ` _ \ 
# | (__| |  | |_| | | | | || (_) | | | || (_| (_) | | | | | |
#  \___|_|   \__, |_| |_|\__\___/|_| |_(_)___\___/|_| |_| |_|
#            |___/                                           
#

# check if document root exists
PROJECT_ROOT="$(echo "${DOCUMENT_ROOT}" | rev | cut -d'/' -f2- | rev)"
if [ ! -d "${PROJECT_ROOT}" ]; then
    echo "Create project root..."
    if ! mkdir -p "${PROJECT_ROOT}"
    then
        echo "Could not create project root ${PROJECT_ROOT}!"
        exit 1
    fi
fi

# set folder permissions
echo "Set permissions..."
chown -R crynton:www-data "${PROJECT_ROOT}"
chmod -R 775 "${PROJECT_ROOT}"

# install TYPO3 if INSTALL_TYPO3 = true
if [ "${INSTALL_TYPO3}" = "true" ]; then
    echo "Check if composer.json exists..."
    if [ -f "${DOCUMENT_ROOT}/../composer.json" ]; then
        echo "The file composer.json exists! Skip TYPO3 installation..."
    else
        echo "The file composer.json does not exists! Install TYPO3 ${TYPO3_VERSION}..."
        echo "Run create-project..."
        if ! su -l crynton -c "composer ${COMPOSER_ADDITIONAL_ARGUMENTS} create-project typo3/cms-base-distribution ${PROJECT_ROOT} ${TYPO3_VERSION}"
        then
            echo "Something went wrong while installing TYPO3 :( Please check the composer output above!"
            exit 1
        fi
    fi
else
    echo "Installation of TYPO3 will be skipped because INSTALL_TYPO3 does not equal true..."
fi

# enable settings for reverse proxy
if [ "${REVERSE_PROXY_SETTINGS}" = "true" ]; then
    echo "Enable settings for reverse proxy usage..."
    a2enmod remoteip
    a2enconf reverse-proxy
fi

# start open-ssh server if START_SSHD = true
if [ "${START_SSHD}" = "true" ]; then
    echo "Start openssh-server..."
    if ! /etc/init.d/ssh start
    then
        echo "Error while starting openssh-server!"
        exit 1
    fi
fi

# start apache2 server
echo "Start apache2..."
if ! apache2-foreground
then
    echo "Error while starting apache2!"
    exit 1
fi