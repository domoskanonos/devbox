
<div style="display:flex;font-size:72px;">
<img src="./assets/logo-ink.svg" width="72px">&nbsp;
devbox
</div>


## description
helper box for developer.

|description|info|
|:-------------|:-------------|
|git|<nobr>![GitHub](https://img.shields.io/github/license/domoskanonos/devbox)</nobr> <nobr>[![Published on git](https://img.shields.io/github/languages/code-size/domoskanonos/devbox)](https://github.com/domoskanonos/devbox)</nobr>|
|docker|![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/domoskanonos/devbox)|
|donation|<nobr>[![donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_buttonid=SWGKEVSK2PDEE)</nobr>|



# request ssl certification from letsencrypt
## primary domain
    docker run -it --rm -v /_store/letsencrypt/certs:/etc/letsencrypt -v /_store/letsencrypt/data:/data/letsencrypt certbot/certbot certonly --webroot --webroot-path=/data/letsencrypt -d nidoca.com -d www.nidoca.com --email dominikbruhn@googlemail.com --agree-tos
## subdomain
    docker run -it --rm -v /_store/letsencrypt/certs:/etc/letsencrypt -v /_store/letsencrypt/data:/data/letsencrypt certbot/certbot certonly --webroot --webroot-path=/data/letsencrypt -d api.nidoca.com -d www.api.nidoca.com --email dominikbruhn@googlemail.com --agree-tos

    