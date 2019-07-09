// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

import os
import http
import time

fn main() {
    files_txt := './files.txt'
    if os.file_exists(files_txt){
        println('finished, ok.')
        return
    }

    url := 'https://github.com/komeiji-satori/Dress'
    get_dirs(url)
    urls := get_files(url)

    mut files_txt_str := ''
    for url in urls{
        files_txt_str += '$url\n'
    }
    os.write_file(files_txt, '$files_txt_str')
    println('finished, ok..')
}

fn get_dirs(url string) string{
    dirs_txt := './dirs.txt'
    if os.file_exists(dirs_txt){
        println('get_dirs, ok.')
        return 'dirs,ok.'
    }
    
    // /komeiji-satori/Dress/tree/master/bakayui
    html := http.get(url)
    mut pos := 0
    mut dirs_txt_str := ''
    for {
        pos = html.index_after('/tree/master/', pos + 1)
        if pos == -1 {
            break
        }
        end := html.index_after('"', pos)
        text := html.substr(pos, end)
        //println(text)
        key := text.substr(13, text.len)
        dirs_txt_str += '$key---$url$text\n'
    }
    os.write_file(dirs_txt, '$dirs_txt_str')
    println('get_dirs, ok..')
    return 'dirs,ok..'
}

fn get_files(url string) []string{
    mut file_urls := []string
    dirs_txt := './dirs.txt'
    dirs_list := os.read_lines(dirs_txt)
    for dir in dirs_list {
        k := dir.split('---')[0]
        v := dir.split('---')[1]
        // /blob/master/403_Forbidden/QQ图片20190317231553.png
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
            file_urls << '$url$text'
        }
        time.sleep_ms(1000)
        println('$k is down.')
		}

    return file_urls

	/*for dir in dirs {
		println(dir)
		//println(url.str())
	}*/
	//return 'get_files, ok'
}



