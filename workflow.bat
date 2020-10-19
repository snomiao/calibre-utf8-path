@echo off
chcp 65001

REM 下载本项目
REM git clone https://github.com/snomiao/calibre-utf8-path
REM cd calibre-utf8-path

REM 安装基本工具（用于下载和修改压缩包）
wsl sudo apt install -y axel zip

REM 下载calibre最新64位安装包并安装（己装可跳过）
wsl rm calibre*.msi
wsl axel -n 8 -o calibre64.msi https://calibre-ebook.com/dist/win64
.\calibre64.msi

REM 下载calibre最新源码并解压
wsl axel -n 8 -o src.tar.xz https://calibre-ebook.com/dist/src
wsl tar -xvf src.tar.xz
del src.tar.xz

REM 进入目录；自动修改源码
REM move calibre-* calibre-src
cd calibre-*
python ../modify_backend.py

REM 使用 python3.8 编译并把结果转到 pylib 对应目录
python -O -m py_compile src\calibre\db\backend_utf8.py
move /Y src\calibre\db\__pycache__\backend_utf8.cpython-38.opt-1.pyc src\calibre\db\backend.pyc
robocopy src\calibre\db\ pylib_patch\calibre\db\ backend.pyc

REM 注：以下指令需要管理员权限运行

REM 先备份，然后拷贝pylib.zip，编译好的文件替换进去，再替换回去
copy /-Y "C:\Program Files\Calibre2\app\pylib.zip" .\pylib.backup.zip
robocopy "C:\Program Files\Calibre2\app" .\pylib_patch\ pylib.zip

REM 把编译好的东西压进包里
cd pylib_patch
wsl chmod 777 pylib.zip
wsl zip -ur pylib.zip calibre/
cd ..

REM 替换回去（这步必须管理员）
robocopy .\pylib_patch\ "C:\Program Files\Calibre2\app" pylib.zip

REM 完成