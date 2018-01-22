# authr

`authr` makes user management for APIs built with [`handlr`](https://github.com/alexvpickering/handlr) a breeze.

#### Features

* Uses MongoDB
* Passwords and reset tokens are hashed for storage
* `login_user` return [JWTs](https://jwt.io/) to authenticate user-only endpoints
* `forgot_password` generates reset token valid for 24 hours
* `forgot_password` and `register_user` send customizable emails using Amazon SES


# Getting Started

Assumes Ubuntu 16.04

See `handlr` [setup](https://github.com/alexvpickering/handlr) and [wiki](https://github.com/alexvpickering/handlr/wiki).

Install system dependencies and MongoDB:

```
sudo apt install libsodium-dev
sudo apt install libsasl2-dev

# install mongodb (used by authr as a user database)
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sudo apt-get update
sudo apt-get install -y mongodb-org

```

Install `authr`:

```R
sudo R
.libPaths('/usr/local/lib/R/site-library')
devtools::install_github('alexvpickering/authr')
```

Create configuration files/emails for `authr` and fill in using templates opened by `authr::open_templates()`: 


```R
sudo touch /var/www/R/.Renviron
sudo mkdir /var/www/R/email
sudo touch /var/www/R/email/vars.R
sudo touch /var/www/R/email/forgot_pw.txt
sudo touch /var/www/R/email/welcome.txt
```

Note: To use HTML email templates, files should end with `.html` instead of `.txt`.

See [Setting up Amazon SES](https://github.com/alexvpickering/authr/wiki/Setting-up-Amazon-SES).

Update `/var/www/R/entry.R` to source the `.Renviron` and specify `authr` endpoints as open (accessible by non logged-in users):

```R
setHeader(header = "X-Powered-By", value = "rApache")

# read R environmental variables 
readRenviron('/var/www/R/.Renviron')

# functions exported by 'packages' can be used as endpoints
packages <- c('authr', 'your_package')

# 'open' functions can be accessed without authentication
open <- list(authr = c('add_user',
                       'login_user',
                       'forgot_password',
                       'reset_password'))

handlr::handle(SERVER, GET, packages, open),

DONE
```


