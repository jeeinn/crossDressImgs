// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

import os
import sync
import net.http
import time
import crypto.md5

const (
    git_rep = 'https://github.com/komeiji-satori/Dress'
    dirs_url_path = './dirs_url.txt'
    imgs_url_path = './imgs_url.txt'
    download_dir = './download_dir/'
)

fn main() {
    if !os.is_dir(download_dir){
        os.mkdir(download_dir) or {
            println('Canot create: $download_dir')
            return
        }
    }
    if os.exists(imgs_url_path){
        println('FIle $imgs_url_path exist.')
        return
    }

    // Real Start
    println('Starting...')
    dirs := get_dirs(git_rep, dirs_url_path)
    println('Get dirs_url finished.')

    file_urls := get_file_urls(git_rep, dirs, imgs_url_path)
    println('Get file_urls finished.')

    // use WaitGroup to download
    // mut file_urls := read_lines(imgs_url_path) or { []string{} }
    download_files(file_urls, download_dir)

    println('All down.')
}

fn get_dirs(url string, save_path string) map_string_string {
    mut dirs := map[string] string {}

    if os.exists(save_path){
        dirs_list := os.read_lines(save_path) or { []string{} }
        for d in dirs_list {
            k := d.split('---')[0]
            v := d.split('---')[1]
            dirs[k] = v
        }
        return dirs
    }

    resp := http.get(url) or { exit(1) }
    
    mut pos := 0
    mut dirs_fd := os.create(save_path) or {
        println('Canot create $save_path')
        return dirs
    }
    mut target_string := '/tree/master/'
    // Bare `for` loop
    // /komeiji-satori/Dress/tree/master/bakayui
    for {
        pos = resp.text.index_after(target_string, pos + 1)
        if pos == -1 {
            break
        }
        end := resp.text.index_after('"', pos)
        dir_name := resp.text.substr(pos, end)
        key := dir_name.substr(target_string.len, dir_name.len)
        dirs[key] = '$url$dir_name'
        println('$url$dir_name')
        dirs_fd.write('$key---$url$dir_name\n')
    }
    dirs_fd.close()
    return dirs
}

// Note: sleep_ms(1000)
fn get_file_urls(url string, dirs map[string] string, save_path string) []string{
    mut file_urls := [] string {}
    for k, v in dirs {
        // /blob/master/403_Forbidden/QQ图片20190317231553.png
        // https://raw.githubusercontent.com/komeiji-satori/Dress/master/AdrianWang/princess0.jpg
        println('Dir $k get starting...')
        resp := http.get(v) or { exit(1) }
        mut pos := 0
        mut file_fd := os.open_append(save_path) or {
            println('Canot open_append $save_path')
            break
        }
        for {
            pos = resp.text.index_after('/blob/master/', pos + 1)
            if pos == -1 {
                break
            }
            end := resp.text.index_after('"', pos)
            text := resp.text.substr(pos, end)
            img_url := text.substr(5, text.len) // /master/AdrianWang/princess0.jpg
            new_url := url.replace('https://github.com', 'https://raw.githubusercontent.com')
            if img_filter(text) {
                file_fd.write('$new_url$img_url\n')
                file_urls << '$new_url$img_url'
            }
        }
        file_fd.close()
        println('Dir $k get down.')
        time.sleep_ms(1000)
    }
    return file_urls
}

fn img_filter(str string) bool{
    mut has_img := false
    for img_type in ['jpg', 'jpeg', 'png', 'bmp', 'gif']{
        if str.contains(img_type) || str.contains(img_type.to_upper()) {
            has_img = true
            println('Img type is: $img_type')
            break
        }
    }
    return has_img
}

fn download_files(file_urls []string, save_dir string){
    mut wg := sync.new_waitgroup()
    mut output_file := ''
    for url in file_urls{
        mut ext_string := '.' + url.split('.').last().to_lower()
        output_file = save_dir + md5.hexhash(url) + ext_string
        if os.exists(output_file) {
            continue
        }
        wg.add(1)
        go download_file(url, output_file, mut wg)
    }
    wg.wait()
}

fn download_file (url string, output_file string, mut wg sync.WaitGroup){
    http.download_file(url, output_file)
    println('File $url download to $output_file finished.')
    wg.done()
}