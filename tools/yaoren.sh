#!/bin/bash

curl http://blog.sina.com.cn/u/1281912467 |\
sed -nr "/第二列start/{

}"
#	<div class="SG_connBody">
#															<div class="bloglist">
#											<div class="blog_title_h">
#							<span class="img1"></span>
#														<div id="t_10001_4c686e930102z2ft" class="blog_title">
#								<a href="http://blog.sina.com.cn/s/blog_4c686e930102z2ft.html" target="_blank">咬人画的-秋之菜饼</a>

#

sed -nr "s/.*real_src =\"(.*\/\/[^/]+\/)[^/]+(\/.*)&amp.*/\1orignal\2/p" tmp > jojo
