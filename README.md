# calibre-utf8-path


- 2022-12-17 最新修改方法見這裏 [改成bin/python-lib.bypy.frozen了 · Issue #2 · snomiao/calibre-utf8-path]( https://github.com/snomiao/calibre-utf8-path/issues/2 )
- 2023-02-05 相関倉庫 <https://github.com/kurikomoe/calibre-utf8-path/tree/poc>


以下是舊方法，現在僅供思路參考。

## 2020-09-24-Calibre-5.1.0-utf8-魔改中文路径教程与懒人包

> calibre，一站式的电子书籍管理软件，提供元信息整理、格式转换、等等，刚发现的是很是高兴，给电子书籍管理带来了方便。但是一个致命的原因——导入的中文电子书籍无法保存为中文路径和中文名，我用Everythin搜索的时候很不方便
> 
> -- 引用自 [Calibre保存中文路径和文件名的方法_delubee_新浪博客]( http://blog.sina.com.cn/s/blog_7a1f539c0102xitp.html )

本项目地址：[snomiao/calibre-utf8-path]( https://github.com/snomiao/calibre-utf8-path )

## 上手教程 - 如何将我的书库从拼音目录切换至中文命名

**警告：本补丁未经全面测试，作以下操作前替换前请先备份你的书库！**

**注意：Calibre 5.2.0 以上安装后没有 pylib.zip 故[以下方法无用]( https://github.com/snomiao/calibre-utf8-path/issues/1 )，如果你有办法，请提 issue...**

### 第一步，Calibre 5.1.0 pylib.zip 直接替换懒人包

对于 Calibre 5.1.0 的用户可以直接下载雪星修改打包好的 （点击传送下载对应版本：）[Releases - pylib.zip]( https://github.com/snomiao/calibre-utf8-path/releases )

然后替换掉 `C:\Program Files\Calibre2\app\pylib.zip` 即可。
或者替换掉 `C:\Program Files (x86)\Calibre2\app\pylib.zip` 即可。

然后重启 Calibre。

### 第二步，将书库里的批量重命名

**再确认一遍你备份过你的书库，以下操作不可逆且有损坏书库的风险。**

打开书库 按 Ctrl + A 选择你的所有书，点 Edit Metadata （或编辑元数据），切到第2个标签页批量替换。字段点title，查找内容和替换内容都填1234，最后点 Apply （应用）

然后目录和文件名就全变成中文，接下来就可以试试用 Listary 或 Everything 搜索你的书库。

### 注意事项

1. 记得备份
2. 确认你的文件系统支持 utf8 文件名
3. 目前仅在 Calibre 的 Win32位 及 Win64位 版本试过，mac 和 linux 未测试，欢迎 pr。
4. 此操作不影响书库本身的兼容性，如果想切换回拼音命名的话，重装 Calibre 再批量重命名一遍即可。
5. 遇到问题请在 issue 反馈。

## 自行编译 - 了解如何让 Calibre 使用中文目录名

### 准备环境

1. 安装最新版 Calibre，点击进入下载页面：[calibre - Download for Windows]( https://calibre-ebook.com/download_windows )
    或直接下载 [calibre-latest.msi]( https://calibre-ebook.com/dist/win32 ) 
2. 下载最新源码包 [calibre-latest.tar.xz]( https://calibre-ebook.com/dist/src )

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
cd calibre-*
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

准备环境：wsl 和 Python 3.8 然后打开命令行窗口一行行执行以下代码

```bat
REM 下载本项目
git clone https://github.com/snomiao/calibre-utf8-path
cd calibre-utf8-path

REM 安装基本工具（用于下载和修改压缩包）
wsl sudo apt install axel zip

REM 下载calibre最新64位安装包并安装（己装可跳过）
wsl axel -n 8 -o calibre64.msi https://calibre-ebook.com/dist/win64
./calibre64.msi

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

REM 替换回去
robocopy .\ "C:\Program Files\Calibre2\app" pylib.zip

REM 完成
```

## 参考文献：

- [Calibre管理电子书怎样和原来的命名规则相结合？ - 知乎]( https://www.zhihu.com/question/19835536 )
- [Calibre教程之如何解决中文目录名的问题 - 知乎]( https://zhuanlan.zhihu.com/p/245553023 )
- [Python:替换或去除不能用于文件名的字符 - Penguin]( https://www.polarxiong.com/archives/Python-%E6%9B%BF%E6%8D%A2%E6%88%96%E5%8E%BB%E9%99%A4%E4%B8%8D%E8%83%BD%E7%94%A8%E4%BA%8E%E6%96%87%E4%BB%B6%E5%90%8D%E7%9A%84%E5%AD%97%E7%AC%A6.html )
- [Calibre保存中文路径和文件名的方法_delubee_新浪博客]( http://blog.sina.com.cn/s/blog_7a1f539c0102xitp.html )
