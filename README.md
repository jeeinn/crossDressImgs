# crossDressImgs
Use Vlang to crawl image links and download of [komeiji-satori/Dress]() projects

## Just for learning Vlang
纯粹是为了练手😄，当然最简单的办法是直接克隆仓库

记得多看 [doc](https://github.com/vlang/v/blob/master/doc/docs.md)

## Usage

* Install env

    安装环境 or [官网 link](https://github.com/vlang/v)
    ```vlang
    # You can clone V anywhere
    git clone https://github.com/vlang/v
    cd v
    make
    ./v symlink
    v up
    ```

* Run 

    克隆本项目运行
    ```vlang
    git clone https://github.com/jeeinn/crossDressImgs.git
    cd crossDressImgs
    v run dress.v
    ```

    在当前目录的 `imgs_url.txt` 中就是所有的一级目录图片地址啦
    ~~，可以找个软件批量脱下来啦~~

    图片默认保存在 `download_dir` 目录中，文件名以下载地址的`md5`生成

* Current Version

    `V 0.1.28` --> `V 0.1.29` (2020-08-07)

    `V 0.1.12` --> `V 0.1.28` (2020-08-05)
    
    `Vlang` 的当前版本 `V 0.1.12`

## Show
展示

![工作中的图片](https://raw.githubusercontent.com/jeeinn/crossDressImgs/master/valng_working_craw_pic_20190709185053.png)

## TODOs
- [x] 目前 `http` 模块的 `download` 部分还没暴露出来，后续考虑加入下载图片功能
- [x] 使用 `go` 预发来并发下载

## Reference

参考
* http://vlang.io
* https://github.com/vlang/v


