#!/bin/bash

# ===================================================
# 題名: Raspbian stretch 初期セットアップ自動化バッチ
# セットアップ概要: 
#   * スワップ停止
#   * RAMディスク設定
#   * aptのソースを日本サーバに設定
#   * ログ出力の抑制
#   * システム更新
#   * 日本語フォント＋日本語入力のインストール
# 実行タイミング:
#   SDカードにRaspbianをインストールし、
#   初回ブートし、
#   ダイアログに従ってセットアップ
#   した後に1度だけ実行する。
#   なお、システム更新はダイアログの時点ではスキップし、このバッチで行うほうが高速に完了するはず。
# 対象OS: Raspbian stretch 2018-06-27
# 作成日: 2018-10-12
# 作成者: ytyaru
# ===================================================

# コマンドをsudo権限で実行する
# $1: some linux command.
function run_sudo() {
    sudo sh -c "${1}"
}
# 指定したテキストを指定したファイルに追記する
# $1: text: new line text.
# $2: file: target file path.
# http://yut.hatenablog.com/entry/20111013/1318436872
# https://qiita.com/b4b4r07/items/e56a8e3471fb45df2f59
# http://wannabe-jellyfish.hatenablog.com/entry/2015/01/10/004554
# http://pooh.gr.jp/?p=6311
function write_line() {
    for i in "${1}"; do
        local command="echo '${i}'"
        sudo sh -c "${command} >> \"${2}\""
    done
}
# 指定ファイルのうち先頭が指定テキストの場合、先頭に#を付与する
# $1: file: target file path.
# $2: text: target text（ヒアドキュメントで複数行指定されることを想定）
#http://linux-bash.com/archives/3745148.html
function write_sharp() {
    #IFS_backup=IFS
    #IFS=$'\n'
    for i in ${2}; do
        # 末尾の改行を除去（しないと次のエラーが出る。"sed: -e expression #1, char 2: アドレスregexが終了していません"）
        local line=`echo ${i} | sed -e "s/[\r\n]\+//g"`
        local sed_script="/^${line}/s/^/#/"
        local sed_cmd="sed -e \"${sed_script}\" -i.bak \"${1}\""
        run_sudo "${sed_cmd}"
    done
    #IFS=IFS_backup
}

# スワップ停止（SDカード書込上限対策）
function stop_swap() {
    sudo swapoff --all
    sudo systemctl stop dphys-swapfile
    sudo systemctl disable dphys-swapfile
}

# RAMディスク作成（SDカード書込上限対策）
function write_fstab() {
    text='
tmpfs /tmp            tmpfs   defaults,size=768m,noatime,mode=1777      0       0
tmpfs /var/tmp        tmpfs   defaults,size=16m,noatime,mode=1777      0       0
tmpfs /var/log        tmpfs   defaults,size=32m,noatime,mode=0755      0       0
tmpfs /home/pi/.cache/chromium/Default/  tmpfs  defaults,size=768m,noatime,mode=1777  0  0
tmpfs /home/pi/.cache/lxsession/LXDE-pi  tmpfs  defaults,size=1m,noatime,mode=1777  0  0
'
    write_line "${text}" "/etc/fstab"
}
# システム更新の高速化（日本用）
function write_apt_sources_list() {
    text='
deb http://ftp.jaist.ac.jp/raspbian/ jessie main contrib non-free rpi
deb http://ftp.tsukuba.wide.ad.jp/Linux/raspbian/raspbian/ jessie main contrib non-free rpi
deb http://ftp.yz.yamagata-u.ac.jp/pub/linux/raspbian/raspbian/ jessie main contrib non-free rpi
deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib non-free rpi
# firmwar update
deb http://mirrors.ustc.edu.cn/archive.raspberrypi.org/debian/ jessie main ui
'
    write_line "${text}" "/etc/apt/sources.list"
}

# ログ出力を抑制する（SDカード書込上限対策）
#http://linux-bash.com/archives/3745148.html
#http://momijiame.tumblr.com/post/92049916671/%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%81%AE%E7%89%B9%E5%AE%9A%E8%A1%8C%E3%82%92-sed-%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%81%A7%E3%82%B3%E3%83%A1%E3%83%B3%E3%83%88%E3%82%A2%E3%82%A6%E3%83%88%E3%81%99%E3%82%8B
#/etc/rsyslog.conf
function comment_out_rsyslog_conf() {
    text='
auth,authpriv.*
*.*;auth,authpriv.none
cron.*
daemon.*
kern.*
lpr.*
mail.*
user.*
mail.info
mail.warn
mail.err
*.=debug;
	auth,authpriv.none;
	news.none;mail.none
*.=info;*.=notice;*.=warn;
	auth,authpriv.none;
	cron,daemon.none;
	mail,news.none
'
    write_sharp "/tmp/work/base" "${text}"
}

# システム＆ファームウェア更新
function update_system() {
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get dist-upgrade -y
}
# 日本語化
function japanese() {
    sudo apt-get install -y fonts-ipafont fonts-ipaexfont
    sudo apt-get install -y fcitx-mozc
}

# 実行する
stop_swap
write_fstab
write_apt_sources_list
comment_out_rsyslog_conf
update_system
japanese
# 再起動する
reboot
