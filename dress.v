// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

import os
import http
import time

fn main() {
    println('starting...')

    files_txt := './imgs_url.txt'
    if os.file_exists(files_txt){
        println('finished, ok.')
        return
    }

    url := 'https://github.com/komeiji-satori/Dress'
    dirs := get_dirs(url)
    urls := get_files(url, dirs)

    f := os.create(files_txt) or {
        return
    }
    for url in urls{
        f.write('$url\n')
    }
    f.close()

    println('finished, ok..')
}

fn get_dirs(url string) map_string {
    mut dirs := map[string] string {}

    dirs_txt := './dirs_url.txt'
    if os.file_exists(dirs_txt){
        dirs_list := os.read_lines(dirs_txt)
        for dir in dirs_list {
            k := dir.split('---')[0]
            v := dir.split('---')[1]
            dirs[k] = v
        }
        println('get_dirs, ok.')
        return dirs
    }

    html := http.get(url)
    // /komeiji-satori/Dress/tree/master/bakayui
    mut pos := 0
    dirs_fd := os.create(dirs_txt) or {
        println('canot create dirs_txt.')
        return dirs
    }
    for {
        pos = html.index_after('/tree/master/', pos + 1)
        if pos == -1 {
            break
        }
        end := html.index_after('"', pos)
        text := html.substr(pos, end)
        //println(text)

        key := text.substr(13, text.len)
        dirs[key] = '$url$text'
        println('$url$text')
        dirs_fd.write('$key---$url$text\n')
    }
    dirs_fd.close()
    println('get_dirs, ok..')
    return dirs
}

fn get_files(url string, dirs map[string] string) []string{
    mut file_urls := []string
    for dir in dirs.entries {
        k := dir.key
        v := dirs[k] //Real content must be accessed in this way
        //println('$dir.key: $k, $dir.val:$v')

        // /blob/master/403_Forbidden/QQ图片20190317231553.png
        println('$k is starting...')
        html := http.get(v)
        mut pos := 0
        for {
            pos = html.index_after('/blob/master/', pos + 1)
            if pos == -1 {
                break
            }
            end := html.index_after('"', pos)
            text := html.substr(pos, end)
            //println(text)
            if img_filter(text) {
                file_urls << '$url$text'
            }
        }
        time.sleep_ms(1000)
        println('$k is down.')
    }
    return file_urls
}

fn img_filter(str string) bool{
    mut has_img := false
    for img_type in ['jpg', 'jpeg', 'png', 'bmp', 'gif']{
        if str.contains(img_type) || str.contains(img_type.to_upper()) {
            has_img = true
            println('img type is: $img_type')
            break
        }

    }
    return has_img
}
