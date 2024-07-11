#!/bin/bash
set +x
set -Euo pipefail
# here glob thing


ZS_CLOUDNAME="zscloud"
ZS_USERDOMAIN="reuter.de"
ZS_VERSION="4.2.0.282"
DIR_TEMP="/tmp/"
DIR_TEMP_ZSCALER="${DIR_TEMP}zscaler/"
FILE_LOG="${DIR_TEMP_ZSCALER}zscaler_installer.log"
FILE_TRUST_SETTINGS="${DIR_TEMP_ZSCALER}trust-settings"
FILE_APP_NAME="Zscaler-osx-${ZS_VERSION}-installer.app"
FILE_ZIP_APP="${FILE_APP_NAME}.zip"
FILE_ZIP="${DIR_TEMP_ZSCALER}${FILE_ZIP_APP}"
FILE_ZIP_DOWNLOAD="https://d32a6ru7mhaq0c.cloudfront.net/${FILE_ZIP_APP}"
ZS_ROOT_CA='MIIE0zCCA7ugAwIBAgIJANu+mC2Jt3uTMA0GCSqGSIb3DQEBCwUAMIGhMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8GA1UEBxMIU2FuIEpvc2UxFTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMMWnNjYWxlciBJbmMuMRgwFgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG9w0BCQEWE3N1cHBvcnRAenNjYWxlci5jb20wHhcNMTQxMjE5MDAyNzU1WhcNNDIwNTA2MDAyNzU1WjCBoTELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExETAPBgNVBAcTCFNhbiBKb3NlMRUwEwYDVQQKEwxac2NhbGVyIEluYy4xFTATBgNVBAsTDFpzY2FsZXIgSW5jLjEYMBYGA1UEAxMPWnNjYWxlciBSb290IENBMSIwIAYJKoZIhvcNAQkBFhNzdXBwb3J0QHpzY2FsZXIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqT7STSxZRTgEFFf6doHajSc1vk5jmzmM6BWuOo044EsaTc9eVEV/HjH/1DWzZtcrfTj+ni205apMTlKBW3UYR+lyLHQ9FoZiDXYXK8poKSV5+Tm0Vls/5Kb8mkhVVqv7LgYEmvEY7HPY+i1nEGZCa46ZXCOohJ0mBEtB9JVlpDIO+nN0hUMAYYdZ1KZWCMNf5J/aTZiShsorN2A38iSOhdd+mcRM4iNL3gsLu99XhKnRqKoHeH83lVdfu1XBeoQzz5V6gA3kbRvhDwoIlTBeMa5l4yRdJAfdpkbFzqiwSgNdhbxTHnYYorDzKfr2rEFMdsMU0DHdeAZf711+1CunuQIDAQABo4IBCjCCAQYwHQYDVR0OBBYEFLm33UrNww4Mhp1d3+wcBGnFTpjfMIHWBgNVHSMEgc4wgcuAFLm33UrNww4Mhp1d3+wcBGnFTpjfoYGnpIGkMIGhMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8GA1UEBxMIU2FuIEpvc2UxFTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMMWnNjYWxlciBJbmMuMRgwFgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG9w0BCQEWE3N1cHBvcnRAenNjYWxlci5jb22CCQDbvpgtibd7kzAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAw0NdJh8w3NsJu4KHuVZUrmZgIohnTm0j+RTmYQ9IKA/pvxAcA6K1i/LO+Bt+tCX+C0yxqB8qzuo+4vAzoY5JEBhyhBhf1uK+P/WVWFZN/+hTgpSbZgzUEnWQG2gOVd24msex+0Sr7hyr9vn6OueH+jj+vCMiAm5+ukd7lLvJsBu3AO3jGWVLyPkS3i6Gf+rwAp1OsRrv3WnbkYcFf9xjuaf4z0hRCrLN2xFNjavxrHmsH8jPHVvgc1VD0Opja0l/BRVauTrUaoW6tE+wFG5rEcPGS80jjHK4SpB5iDj2mUZH1T8lzYtuZy0ZPirxmtsk3135+CKNa2OCAhhFjE0xd'


cleanup() {
    echo "$(date '+%Y/%m/%d %H:%M:%S') - Cleanup temporary directories and files"
    rm -rf $DIR_TEMP_ZSCALER/*
}

trap cleanup EXIT


echo "$(date '+%Y/%m/%d %H:%M:%S') - Creating temporary directories"
mkdir -p $DIR_TEMP_ZSCALER
rm -rf $DIR_TEMP_ZSCALER/*
cd $DIR_TEMP_ZSCALER

echo "$(date '+%Y/%m/%d %H:%M:%S') - Checking if zScaler CA is installed"
security find-certificate -c "Zscaler Root CA" /Library/Keychains/System.keychain > /dev/null 2>&1
result_ca=$?
if [ "${result_ca}" != "0" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') - zScaler CA not found! ERROR: ${result_ca}"
    echo "$(date '+%Y/%m/%d %H:%M:%S') - Create zScaler CA"
    echo "${ZS_ROOT_CA}" | base64 --decode > zScaler_Root_CA.cer
    echo "${ZS_ROOT_CA}" | base64 --decode > zScaler_Root_CA.crt
    openssl x509 -in zScaler_Root_CA.crt -out zScaler_Root_CA.pem -outform PEM
#####
# here create .cacerts and mv the certs here
shopt -s extglob
echo "$(date '+%Y/%m/%d %H:%M:%S') - Install zScaler CA into local users cacerts"
for d in /Users/!(Shared|.localized)/
    do
        if [ -d "$d" ]; then
            mkdir -p "$d.cacerts"
            mv $DIR_TEMP_ZSCALER/zScaler_Root* "$d.cacerts"
        fi
    done
# Disable extended globbing
shopt -u extglob
####
echo "$(date '+%Y/%m/%d %H:%M:%S') - Install zScaler CA"
sudo security authorizationdb read com.apple.trust-settings.admin > ${FILE_TRUST_SETTINGS} 2>/dev/null
result_trustread=$?
if [ "${result_trustread}" != "0" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') - Failed to temporarily write trust-settings into file. ERROR: ${result_trustread}"
    exit 10;
fi
sudo security authorizationdb write com.apple.trust-settings.admin allow 2>/dev/null
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" zScaler_Root_CA.cer
result_add_ca=$?
sudo security authorizationdb write com.apple.trust-settings.admin < ${FILE_TRUST_SETTINGS} 2>/dev/null
result_trustwrite=$?
if [ "${result_trustwrite}" != "0" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') - Failed to restore trust-settings from file. ERROR: ${result_trustwrite}"
    exit 11;
elif [ "${result_add_ca}" != "0" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') - Failed to add zScaler root CA to the System keychain! ERROR: ${result_add_ca}"
    exit 12;
fi
fi

echo "$(date '+%Y/%m/%d %H:%M:%S') - Checking if zScaler is already installed"
if [ -e "/Applications/Zscaler/Zscaler.app" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') - zScaler already installed"
    exit 0;
fi

echo "$(date '+%Y/%m/%d %H:%M:%S') - Downloading zScaler App"
curl -s -f -o "${FILE_ZIP}" "${FILE_ZIP_DOWNLOAD}"
result_curl=$?
if [ "${result_curl}" != "0" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') - Download failed! ERROR: ${result_curl}"
    exit 20;
fi

echo "$(date '+%Y/%m/%d %H:%M:%S') - Unzipping zScaler App"
unzip -q $FILE_ZIP
result_unzip=$?
if [ "${result_unzip}" != "0" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') - unzip failed! ERROR: ${result_unzip}"
    exit 21;
fi

echo "$(date '+%Y/%m/%d %H:%M:%S') - Installing zScaler App"
if [ ! -d "${DIR_TEMP_ZSCALER}${FILE_APP_NAME}" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') - App not in source directory: ${DIR_TEMP_ZSCALER}${FILE_APP_NAME}"
    exit 22;
fi

/bin/sh "${DIR_TEMP_ZSCALER}${FILE_APP_NAME}/Contents/MacOS/installbuilder.sh" \
    --hideAppUIOnLaunch 1 \
    --mode unattended \
    --unattendedmodeui none \
    --cloudName ${ZS_CLOUDNAME} \
    --userDomain ${ZS_USERDOMAIN}
result_zscaler_installer=$?

if [ "${result_zscaler_installer}" != "0" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') - Installation failed! ERROR: ${result_zscaler_installer}"
    exit 23;
fi

exit 0
