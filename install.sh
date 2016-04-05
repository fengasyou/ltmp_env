#!/bin/bash
# update yum 
# 
export=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
#设置时区
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#设置selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 

yum_update(){
mkdir /data/soft
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
cp yum163.repo /etc/yum.repos.d/CentOS-Base.repo
rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
yum clean all 
yum makecache
}
yum_update
check_ok(){
           if [[ $? -eq 0 ]];then
             echo -e "\033[32m $1 is ok\033[0m"
           else
             echo -e "\033[31m $1 not ok\033[0m"
             exit 1;
           fi
}

package_install(){
       yum -y install pcre pcre-devel zlib zlib-devel openssl openssl-devel gcc-c++ wget
       check_ok install_install
}
package_install 

nginx_install(){
       mkdir /data/server
       groupadd -g 1801 nginx
       useradd -u 1801 -g 1801 -s /sbin/nglogin nginx
       cd /data/soft
	   wget  http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz  && tar -zxvf ngx_cache_purge-2.3.tar.gz 
	   wget  http://tengine.taobao.org/download/tengine-2.1.1.tar.gz  && tar zxvf tengine-2.1.1.tar.gz
       cd tengine-2.1.1
       ./configure --add-module=/data/soft/ngx_cache_purge-2.3 --prefix=/data/server/nginx --with-http_stub_status_module --user=nginx --group=nginx
       check_ok nginx_configure 
       make && make install
       check_ok nginx_make
}

nginx_install

check_ok nginx_install

sleep  5

mysql_install(){
       cd /data/soft
	   yum remove -y mysql*
       yum install -y mysql55w mysql55w-server
}

mysql_install
check_ok mysql_install
sleep 5


php_install(){
       cd /data/soft
	   yum remove -y php*
       yum -y  install gd gd-devel libxml2-devel curl-devel bison bison-devel libmcrypt
	   yum -y  install php55w php55w-gd php55w-common php55w-fpm php55w-mysql 
	   yum -y  install php55w-gd libjpeg* php55w-imap php55w-ldap php55w-pear php55w-xml 
	   yum -y  install php55w-xmlrpc php55w-mbstring php55w-mcrypt php55w-bcmath php55w-mhash 
	   yum -y  install php55w-peal php55w-pear-devel php55w-devel
       yum -y  install memcached php55w-pecl-memcache php55w-pecl-memcached php55w-soap
}

php_install
check_ok php-install
sleep 5

yaf_install(){
       cd /data/soft
       wget http://pecl.php.net/get/yaf-2.3.4.tgz
	   tar zxvf yaf-2.3.4.tgz 
	   cd yaf-2.3.4
	   /usr/bin/phpize 
	   whereis php-config
	   ./configure --with-php-config=/usr/bin/php-config
       make && make install
       check_ok yaf_make
	   echo 'extension=yaf.so'>> /etc/php.ini
}

yaf_install

sleep 5


mysql_start(){
    service mysqld restart
	chkconfig  --level 012345 mysqld on
    check_ok mysql-start
}
mysql_start

php_fpm_start(){
    service php-fpm restart
	chkconfig  --level 012345 php-fpm on
	service memcached restart
	chkconfig  --level 012345 memcached on
    check_ok php-fpm-start
}
php_fpm_start

nginx_start(){
    cp nginxstart /etc/init.d/nginx
	chmod +x /etc/init.d/nginx
    service nginx restart
	chkconfig  --level 012345 nginx on
    check_ok nginx-start
}
nginx_start