# 2020-09-24-Calibre-5.0.1-utf8-魔改中文路径教程与懒人包

本项目地址：[snomiao/calibre-utf8-path]( https://github.com/snomiao/calibre-utf8-path )

背景：

> calibre，一站式的电子书籍管理软件，提供元信息整理、格式转换、等等，刚发现的是很是高兴，给电子书籍管理带来了方便。但是一个致命的原因——导入的中文电子书籍无法保存为中文路径和中文名，我用Everythin搜索的时候很不方便
> 
> -- 引用自 [Calibre保存中文路径和文件名的方法_delubee_新浪博客]( http://blog.sina.com.cn/s/blog_7a1f539c0102xitp.html )

## 太长不看 - Calibre 5.0.1 以上 pylib.zip 直接替换懒人包

对于 Calibre 5.0.1 以上的用户可以直接下载雪星修改打包好的 （点击传送下载对应版本：）[Releases - pylib.zip]( https://github.com/snomiao/calibre-utf8-path/releases )

然后替换掉 `C:\Program Files\Calibre2\app\pylib.zip` 即可。
或者替换掉 `C:\Program Files (x86)\Calibre2\app\pylib.zip` 即可。

## 准备环境

1. 安装最新版 Calibre，点击进入下载页面：[calibre - Download for Windows]( https://calibre-ebook.com/download_windows )
    或直接下载 [calibre-latest.msi]( https://calibre-ebook.com/dist/win32 ) 
2. 下载最新源码包 [calibre-latest.tar.xz]( https://calibre-ebook.com/dist/src )


## 解决 Calibre 中文目录名问题

### 修改源码

解压 上述源码包，找到 `src\calibre\db\backend.py`，打开。

主要做 2 件事
1. 定义自己的文件名转换函数
2. 替换掉原来的 ascii_filename

```python
# src\calibre\db\backend.py

# ...

# 定义自己的文件名转换函数
import re
def safe_filename(filename):
    return re.sub(r"[\/\\\:\*\?\"\<\>\|]", "_", filename)  # 替换为下划线

# ... 找到 construct_path_name 和 construct_file_name 把文件名转换函数换成自己的
    def construct_path_name(self, book_id, title, author):
        
        # ...

        # author = ascii_filename(author)[:l]
        # title  = ascii_filename(title.lstrip())[:l].rstrip()
        author = safe_filename(author)
        title  = safe_filename(title)

        # ...

    def construct_file_name(self, book_id, title, author, extlen):
        
        # ...
        
        # author = ascii_filename(author)[:l]
        # title  = ascii_filename(title.lstrip())[:l].rstrip() extlen)
        author = safe_filename(author)
        title  = safe_filename(title)

        # ...
```

### 使用 Python 3 编译修改后的 Calibre 源码，并替换进 pylib.zip 里

```batch
cd calibre-5.0.1
python -O -m py_compile src\calibre\db\backend.py
```

<details>
<summary>注：在 5.0 版本之前使用 Python 2.7 编译为 .pyo 文件</summary>

```batch
c:\Python27\python.exe -O -m py_compile src\calibre\db\backend.py
```

</details>

把 `src\calibre\db\__pycache__\backend.cpython-38.opt-1.pyc`
重命名为 `backend.pyc` 然后在 `C:\Program Files\Calibre2\app\pylib.zip` 里找到对应文件并替换进去

## 基于以上原理实现的自动化工作流

```bat
REM 安装基本工具（用于下载和修改压缩包）
wsl sudo apt install axel zip

REM 下载安装包并安装
wsl axel -n 8 -o calibre64.msi https://calibrkke-ebook.com/dist/win64
./calibre64.msi

REM 下载源码并解压
wsl axel -n 8 -o src.tar.xz https://calibre-ebook.com/dist/src
wsl tar -xvf src.tar.xz
del src.tar.xz

REM 进入目录；自动修改源码（有node用node，没node用py
REM move calibre-* calibre-src
cd calibre-*
node ../modify_backend.js || python ../modify_backend.py

REM 使用 python3.8 编译并把结果转到 pylib 对应目录
python -O -m py_compile src\calibre\db\backend_new.py
move /Y src\calibre\db\__pycache__\backend_new.cpython-38.opt-1.pyc src\calibre\db\backend.pyc
robocopy src\calibre\db\ pylib_patch\src\calibre\db\ backend.pyc

REM 注：以下指令需要管理员权限运行

REM 先备份，然后拷贝pylib.zip，编译好的文件替换进去，再替换回去
copy /-Y "C:\Program Files\Calibre2\app\pylib.zip" .\pylib.backup.zip
robocopy "C:\Program Files\Calibre2\app" .\ pylib.zip

REM 把编译好的东西压进包里
wsl chmod 777 pylib.zip
wsl zip -ur pylib.zip pylib_patch/

REM 替换回去
robocopy .\ "C:\Program Files\Calibre2\app" pylib.zip
```

## 参考文献：

- [Calibre教程之如何解决中文目录名的问题 - 知乎]( https://zhuanlan.zhihu.com/p/245553023 )
- [Python:替换或去除不能用于文件名的字符 - Penguin]( https://www.polarxiong.com/archives/Python-%E6%9B%BF%E6%8D%A2%E6%88%96%E5%8E%BB%E9%99%A4%E4%B8%8D%E8%83%BD%E7%94%A8%E4%BA%8E%E6%96%87%E4%BB%B6%E5%90%8D%E7%9A%84%E5%AD%97%E7%AC%A6.html )