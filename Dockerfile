FROM ubuntu:20.04
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y tzdata && \
    echo "America/Chicago" > /etc/timezone && \
    rm -f /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    yes | unminimize && \
    apt-get install -y software-properties-common vim curl git bash zip unzip openssh-server locales && \
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen && \
    locale-gen
RUN add-apt-repository ppa:ondrej/php && \
    apt-get install -y php7.3 php7.3-json php7.3-pdo php7.3-mysqli php7.3-zip php7.3-gd php7.3-mbstring \
        php7.3-curl php7.3-xml php7.3-bcmath php7.3-soap php7.3-intl
RUN curl -O https://getcomposer.org/download/1.10.22/composer.phar && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    curl -O https://getcomposer.org/download/2.1.8/composer.phar && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer2 && \
    curl -O https://files.magerun.net/n98-magerun2.phar && \
    chmod +x n98-magerun2.phar && mv n98-magerun2.phar /usr/local/bin/n98-magerun2
RUN mkdir /run/sshd && sed -i "s/www-data/admin/ig" /etc/passwd && \
    chsh -s /bin/bash admin && echo admin:admin123 | chpasswd && \
    usermod -d /srv/magento admin && \
    mkdir /var/log/ssh && \
    sed -i "s/#Port 22/Port 222/ig" /etc/ssh/sshd_config && \
    sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/ig" /etc/ssh/sshd_config
COPY ioncube_loader_lin_7.3.so /usr/lib/php/20180731/ioncube_loader_lin_7.3.so
COPY ixed.7.3.lin /usr/lib/php/20180731/ixed.7.3.lin
COPY 00-ioncube.ini /etc/php/7.3/cli/conf.d/00-ioncube.ini
COPY 00-aliases.sh /etc/profile.d/00-aliases.sh
RUN apt-get install -y mariadb-client redis-tools dumb-init zsh rsync && \
    cat /etc/profile.d/00-aliases.sh >> /etc/zsh/zprofile && \
    chsh -s /usr/bin/zsh admin
ENTRYPOINT ["dumb-init", "/usr/sbin/sshd", "-D", "-E", "/var/log/ssh/sshd.log", "-o", "PermitRootLogin=no"]
