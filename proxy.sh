#!/bin/sh

HTTP_PROXY_HOST=XXXXXXXXXX
HTTP_PROXY_PORT=XXXX
HTTPS_PROXY_HOST=XXXXXXXXXX
HTTPS_PROXY_PORT=XXXX

shellrc=$HOME/.bashrc

#バックアップをとり,元の設定ファイルからマッチした行を削除
backup(){
  if [ $1 = "apt" -o $1 = "all" ]; then
    sudo sed -i.bak '/ftp::proxy/Id' /etc/apt/apt.conf
    sudo sed -i.bak '/http::proxy/Id' /etc/apt/apt.conf
    sudo sed -i.bak '/https::proxy/Id' /etc/apt/apt.conf
  fi
  if [ $1 = "env" -o $1 = "all" ]; then
    sudo sed -i.bak "/ftp_proxy/Id" /etc/environment
    sudo sed -i.bak "/FTP_PROXY/Id" /etc/environment
    sudo sed -i.bak "/http_proxy/Id" /etc/environment
    sudo sed -i.bak "/HTTP_PROXY/Id" /etc/environment
    sudo sed -i.bak "/https_proxy/Id" /etc/environment
    sudo sed -i.bak "/HTTPS_PROXY/Id" /etc/environment
  fi
  if [ $1 = "bash" -o $1 = "all" ]; then
    sudo sed -i.bak '/ftp_proxy/Id' $shellrc
    sudo sed -i.bak '/FTP_PROXY/Id' $shellrc
    sudo sed -i.bak '/http_proxy/Id' $shellrc
    sudo sed -i.bak '/HTTP_PROXY/Id' $shellrc
    sudo sed -i.bak '/https_proxy/Id' $shellrc
    sudo sed -i.bak '/HTTPS_PROXY/Id' $shellrc
  fi
}

if [ $# = 0 ]; then
  echo "Error: no args"
  exit 1
else

  if [ $1 = "on" ]; then
    #アプトコマンド系に対する設定
    backup apt
    sudo tee -a /etc/apt/apt.conf <<EOF
Acquire::ftp::proxy "ftp://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/";
Acquire::http::proxy "http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/";
Acquire::https::proxy "https://$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/";
EOF

    #環境変数(?)に対する設定
    backup env
    sudo tee -a /etc/environment <<EOF
ftp_proxy="ftp://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
FTP_PROXY="ftp://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
http_proxy="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
HTTP_PROXY="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
https_proxy="https://$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/"
HTTPS_PROXY="https://$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/"
EOF

    #bashに対する設定
    backup bash
    tee -a $shellrc <<EOF
export ftp_proxy="ftp://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
export FTP_PROXY="ftp://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
export http_proxy="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
export HTTP_PROXY="http://$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
export https_proxy="https://$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/"
export HTTPS_PROXY="https://$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/"
EOF

    #gnomeに対する設定
    gsettings set org.gnome.system.proxy mode 'manual'
    gsettings set org.gnome.system.proxy.ftp host "$HTTP_PROXY_HOST"
    gsettings set org.gnome.system.proxy.ftp port "$HTTP_PROXY_PORT"
    gsettings set org.gnome.system.proxy.http host "$HTTP_PROXY_HOST"
    gsettings set org.gnome.system.proxy.http port "$HTTP_PROXY_PORT"
    gsettings set org.gnome.system.proxy.https host "$HTTPS_PROXY_HOST"
    gsettings set org.gnome.system.proxy.https port "$HTTPS_PROXY_PORT"
  else
    if [ $1 = "off" ]; then
      #apt,envに対する設定の変更
      backup all

      #bashの設定を変更
      tee -a $shellrc <<EOF
export ftp_proxy=
export http_proxy=
export https_proxy=
EOF

      #gnomeに対する設定の変更
      gsettings set org.gnome.system.proxy mode 'none'

    else
      echo "arg: 'on' or 'off'"
      exit 1
    fi
  fi
fi
#.bashrcを再読込する
#.bashrcはインタラクティブモードでないとsourceできない
#ので以下の方法で代行
exec bash
exit 0
