#!/bin/bash
#=================================================
# diy-part2.sh — 在 feeds install 之后执行
#=================================================

#-------------------------------------------------
# 1. 基础设置
#-------------------------------------------------
# 修改默认 IP
sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate
# 修改主机名
sed -i 's/ImmortalWrt/OpenWrt/g' package/base-files/files/bin/config_generate


#-------------------------------------------------
# 2. 更新语言工具链
#-------------------------------------------------
# 更新 golang 到 1.25.x
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang


#-------------------------------------------------
# 3. 科学上网插件
#-------------------------------------------------
# 移除 feeds 自带的旧版核心库，避免版本冲突
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,\
hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,\
simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}

# Helloworld (ssr-plus)
git clone --depth=1 https://github.com/sbwml/openwrt_helloworld package/helloworld

# Passwall 核心库（helloworld 也复用这里的核心包）
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages

# Passwall luci（替换 feeds 里的旧版）
rm -rf feeds/luci/applications/luci-app-passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci


#-------------------------------------------------
# 4. 额外插件
#-------------------------------------------------
# Amlogic 刷机工具（N1 必备）
git clone --depth=1 https://github.com/ophub/luci-app-amlogic package/amlogic

# Lucky（端口转发/DDNS 工具）
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/lucky

# MosDNS v5（替换 feeds 里的旧版）
rm -rf feeds/luci/applications/luci-app-mosdns
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns

# OpenList（网盘挂载）
git clone --depth=1 https://github.com/sbwml/luci-app-openlist2 package/openlist



#-------------------------------------------------
# 5. 杂项修正
#-------------------------------------------------
# 修正 luci-compat 两处错误翻译
sed -i 's/<%:Up%>/<%:Move up%>/g'   feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Down%>/<%:Move down%>/g' feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm





# 修复 rust CI LLVM 404 问题
# 同时禁用 download-ci-llvm 和 download-rustc，避免在 GitHub Actions 环境下编译失败
sed -i \
    -e 's/--set=llvm.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/g' \
    -e 's/--set=rust.download-rustc=true/--set=rust.download-rustc=false/g' \
    -e 's/--set=rust.download-rustc="if-unchanged"/--set=rust.download-rustc=false/g' \
    feeds/packages/lang/rust/Makefile || true

