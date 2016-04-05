#服务器LTMP环境搭建
##1.准备工作（缺一不可）
###①确保服务器可以连接外网
###②确保数据盘挂载/data（不挂载/data，请在cengos系统下手动修改install.sh脚本，将data改为您挂载的目录）
###③确保目录下nginxstart文件和yum163.repo一起上传到服务器，且为同一目录下(nginxstart切勿打开编辑)
##2、安装LTMP环境
###直接运行sh install.sh
