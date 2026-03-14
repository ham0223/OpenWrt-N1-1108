#!/bin/bash
set -e  # 遇到错误立即退出

# ========== 辅助函数 ==========
log() { echo -e "\e[32m[+]\e[0m $1"; }
die() { echo -e "\e[31m[✗]\e[0m $1" >&2; exit 1; }
# 批量 git clone（统一使用 --depth=1 浅克隆，加速下载）
clone() { git clone --depth=1 "$1" "$2" || die "克隆失败: $1"; }

# ========== 1. 基础配置 ==========
log "修改默认 IP 和主机名..."
sed -i 's/192.168.1.1/192.168.123.2/g' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/OpenWrt/g'       package/base-files/files/bin/config_generate

# ========== 2. 更新 Golang ==========
log "更新 Golang 到 26.x（适配 25.12 APK）..."
rm -rf feeds/packages/lang/golang
clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# ========== 3. Passwall 科学上网 ==========
log "替换 Passwall 依赖包..."
# 移除 feeds 自带的旧版核心库，避免冲突
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,\
hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,\
shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,\
xray-plugin,geoview,shadow-tls}
clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages

log "替换 luci-app-passwall..."
rm -rf feeds/luci/applications/luci-app-passwall
clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci

log "替换 luci-app-passwall2..."
rm -rf feeds/luci/applications/luci-app-passwall2
clone https://github.com/Openwrt-Passwall/openwrt-passwall2 package/passwall2-luci

# ========== 4. SSR-Plus（helloworld）==========
log "拉取 luci-app-ssr-plus..."
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
clone https://github.com/fw876/helloworld package/helloworld

# ========== 5. OpenClash ==========
log "拉取 luci-app-openclash..."
rm -rf feeds/luci/applications/luci-app-openclash
clone https://github.com/vernesong/OpenClash package/openclash

# ========== 6. Nikki（mihomo）==========
log "拉取 luci-app-nikki..."
clone https://github.com/morytyann/openwrt-mihomo package/nikki

# ========== 7. 其他插件 ==========
log "拉取第三方插件..."
clone https://github.com/ophub/luci-app-amlogic  package/amlogic
clone https://github.com/gdy666/luci-app-lucky    package/lucky

log "替换 mosdns (v5)..."
rm -rf feeds/luci/applications/luci-app-mosdns
clone https://github.com/sbwml/luci-app-mosdns package/mosdns

# ========== 8. 修正翻译错误 ==========
log "修正 luci-compat 翻译..."
_TBL=feeds/luci/modules/luci-compat/luasrc/view/cbi/tblsection.htm
sed -i 's/<%:Up%>/<%:Move up%>/g'     "$_TBL"
sed -i 's/<%:Down%>/<%:Move down%>/g' "$_TBL"

log "✅ diy-part2.sh 全部执行完毕！"
