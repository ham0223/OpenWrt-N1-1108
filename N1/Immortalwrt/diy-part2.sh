#!/bin/bash

# 修改IP
sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate
# 修改主机名
sed -i 's/ImmortalWrt/OpenWrt/g' package/base-files/files/bin/config_generate


# 备用科学插件：移除 openwrt feeds 自带的核心包
#rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
#git clone https://github.com/sbwml/openwrt_helloworld package/helloworld
# 更新 golang 1.25 版本
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang



# 官方方法：移除 openwrt feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages

# 修复 shadowsocks-libev CMAKE_OPTIONS（全路径覆盖，防止遗漏）
CMAKE_FIX='CMAKE_OPTIONS += -DWITH_STATIC=OFF -DWITH_EMBEDDED_SRC=ON -DWITH_DOC_HTML=OFF -DWITH_DOC_MAN=OFF -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DENABLE_CONNMARKTOS=OFF -DENABLE_NFTABLES=OFF'

for MK in \
    package/passwall-packages/shadowsocks-libev/Makefile \
    feeds/small/shadowsocks-libev/Makefile \
    feeds/packages/net/shadowsocks-libev/Makefile; do
    [ -f "$MK" ] || continue
    if grep -q '^CMAKE_OPTIONS +=' "$MK"; then
        sed -i "s|^CMAKE_OPTIONS +=.*|${CMAKE_FIX}|" "$MK"
        echo "[OK] 已替换: $MK"
    else
        echo "${CMAKE_FIX}" >> "$MK"
        echo "[OK] 已追加: $MK"
    fi
done

# 移除 openwrt feeds 过时的luci版本
rm -rf feeds/luci/applications/luci-app-passwall
git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci



# 删除及其拉取源码
git clone https://github.com/ophub/luci-app-amlogic --depth=1 package/amlogic
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky
rm -rf feeds/luci/applications/luci-app-mosdns
git clone https://github.com/sbwml/luci-app-openlist2 package/openlist
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns



# 修正俩处错误的翻译
sed -i 's/<%:Up%>/<%:Move up%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Down%>/<%:Move down%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
