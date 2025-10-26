# vim: set ft=make :

# configure the NSS database and add the Spanish eID (DNIe) module
setup-dnie:
    #!/usr/bin/env bash
    
    echo "Changing to the HOME directory..."
    cd "${HOME}"

    echo "Creating the NSS database directory if it doesn’t exist..."
    mkdir -p ~/.pki/nssdb

    echo "Initializing the NSS database (you may leave the password empty)..."
    certutil -d ~/.pki/nssdb -N --empty-password

    echo "Setting secure permissions for the NSS database..."
    chmod 700 ~/.pki/nssdb

    echo "Listing current certificates in the NSS database..."
    certutil -d "sql:${HOME}/.pki/nssdb" -L ||    echo "No certificates found yet."

    echo "Adding the DNIe module..."
    modutil -add "DNIe" -dbdir "sql:${HOME}/.pki/nssdb" -libfile /usr/lib64/libpkcs11-dnie.so -force

    echo "Verifying the DNIe module installation..."
    modutil -list -dbdir "sql:${HOME}/.pki/nssdb/"

    echo "Process completed successfully."