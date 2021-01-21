# Installing a new SSL certificate in Simple Server

## Generate the certificate

Install certbot if necessary

```bash
sudo apt-get install certbot
```

Stop haproxy and nginx

```bash
sudo service nginx stop
sudo service haproxy stop
```

Generate a standalone certificate on the server

```bash
sudo certbot certonly --standalone -d simple.moh.gov.et
```

Restart haproxy and nginx

```bash
sudo service nginx start
sudo service haproxy start
```

Grab the contents of the generated certificate

```bash
cat /etc/letsencrypt/live/simple.moh.gov.et/privkey.pem
cat /etc/letsencrypt/live/simple.moh.gov.et/fullchain.pem
```

## Check in the new certificate

Fetch the latest updates to the deployment repository.

```bash
cd ~/deployment
git checkout master
git pull --rebase origin master
```

Decrypt the `ssl-vault.yml`

```bash
cd standalone/ansible/roles/load_balancing/vars
ansible-vault decrypt --vault-id ~/.vault_password_et ssl-vault.yml
```

Add the new fullchain and private key files to the decrypted ssl-vault.yml

```yml
ssl_cert_files:
  /etc/ssl/simple.moh.gov.et.crt:
    owner: root
    group: root
    mode: "u=r,go="
    content: |
    <Contents of the new fullchain.pem>
  /etc/ssl/simple.moh.gov.et.key:
    owner: root
    group: root
    mode: "u=r,go="
    content: |
    <Contents of the new privkey.pem>
```

Re-encrypt the `ssl-vault.yml`

```bash
ansible-vault encrypt --vault-id ~/.vault_password_et ssl-vault.yml
```

Commit and push your updates. **Caution: Be sure to re-encrypt the `ssl-vault.yml` before commiting your changes!**

```bash
cd ~/deployment
git add standalone/ansible/roles/load_balancing/vars/ssl-vault.yml
git commit -m 'Update SSL certificate'
git push siraj master
```

Open a pull request in Github with your changes. The Simple team will accept your changes in a few days.

## Install/Update the SSL Certificates

In the meantime, you don't have to wait. You can immediately install the new certificate on Simple Server from the deployment repository.

```bash
make all hosts=ethiopia/demo
```
