web crawler
===========
[![Build Status](https://travis-ci.org/mamewotoko/crawler.svg?branch=master)](https://travis-ci.org/mamewotoko/crawler)
 
Build
-----
```
make
```

Run
---
1. modify config_level, config_init_url in crawler.ml as you like.

    ```
    let config_level = 4
    let config_init_url = "http://mamewo.ddo.jp/"
    ```
2. build
3. run

    ```
    ./crawler
    ```

TODO
----
* config initial url, depth limit by file or command line
* write spec
  * collects html, images
  * depth?
  * sleep time?
  * no gentleness?
* handle robot.txt
* create output directory separated by hostname
* usage: collect images on website
  * not supporing images fetched by JavaScript

----
Takashi Masuyama < mamewotoko@gmail.com >  
http://mamewo.ddo.jp/
