#!/bin/zsh

set -e

APP_NAME="ADFiles-objc"
BUILD_DIR="build"
PAYLOAD_DIR="${BUILD_DIR}/Payload"
APP_DIR="${PAYLOAD_DIR}/${APP_NAME}.app"
MISTAKE_LOGS="Mistake_logs"
BASIC_DIR="${BUILD_DIR}/Basic"
IPA_DIR="${BUILD_DIR}/IPA"
CURRENT_DATE=$(date "+%Y-%m-%d_%H-%M-%S")
MISTAKE_FILE="${MISTAKE_LOGS}/Mistake_${CURRENT_DATE}.log"
CURRENT_IPA_DIR="${IPA_DIR}/${CURRENT_DATE}"

build_zip() {
    echo "正在打包成 IPA..."
    cd "${BUILD_DIR}"
    zip -qr "${APP_NAME}.IPA" Payload
    
    # 創建當前日期的 IPA 目錄並移動 IPA 文件
    mkdir -p "${CURRENT_IPA_DIR}"
    mv "${APP_NAME}.IPA" "${CURRENT_IPA_DIR}/"
    
    cd ..
    printf "打包成 IPA 成功！IPA 文件位置: build/${CURRENT_IPA_DIR}/${APP_NAME}.IPA\n"
    exit 0
}

inquire() {
    printf "是否打包成 IPA 文件? (yes/no): "
    read judge
    
    case ${judge:l} in
        yes|y)
            build_zip
            ;;
        no|n)
            printf "構建完成！您只需要打包成 IPA 後安裝到設備即可體驗我們的應用程序 (${APP_NAME})\n"
            exit 0
            ;;
        *)
            printf "錯誤！請輸入 yes/Yes/YES/y/Y/no/No/n/N\n"
            inquire
            ;;
    esac
}

move_existing_ipa() {
    # 移動現有的 IPA 文件到日期文件夾
    mkdir -p "${CURRENT_IPA_DIR}"
    
    # 移動 build 目錄下的 IPA 文件
    if ls "${BUILD_DIR}"/*.IPA 1> /dev/null 2>&1; then
        mv "${BUILD_DIR}"/*.IPA "${CURRENT_IPA_DIR}/" 2>/dev/null || true
        echo "已移動現有 IPA 文件到 ${CURRENT_IPA_DIR}"
    fi
    
    # 移動 IPA 目錄下的 IPA 文件（不包括當前日期文件夾）
    if [ -d "${IPA_DIR}" ]; then
        find "${IPA_DIR}" -maxdepth 1 -name "*.IPA" -exec mv {} "${CURRENT_IPA_DIR}/" \; 2>/dev/null || true
    fi
}

main() {
    echo "正在編譯當中..."
    sleep 1

    # 移動現有的 IPA 文件
    move_existing_ipa

    # 創建必要的目錄
    mkdir -p "${APP_DIR}"
    mkdir -p "${MISTAKE_LOGS}"
    mkdir -p "${BASIC_DIR}"
    mkdir -p "${CURRENT_IPA_DIR}"

    echo "開始編譯..."
    clang -fobjc-arc \
          -isysroot /var/jb/theos/sdks/iPhoneOS.sdk \
          -target arm64-apple-ios15.0 \
          main.m AppDelegate.m FileItem.m FileListViewController.m \
          FavoritesManager.m SettingsViewController.m AboutViewController.m \
          UpdateLogViewController.m ImageViewController.m PDFViewController.m \
          FileOperations.m MediaViewController.m HexEditorViewController.m \
          FilePermissionsViewController.m TextEditorViewController.m 5.c \
          -framework UIKit -framework Foundation -framework CoreGraphics \
          -framework PDFKit -framework AVFoundation -framework AVKit \
          -o "${APP_NAME}" \
          2>"${MISTAKE_FILE}"

    mv "${APP_NAME}" "${APP_DIR}/"
    
    if [ -d "${BUILD_DIR}/bin" ]; then
        cp -R "${BUILD_DIR}/bin" "${APP_DIR}/"
    fi
    
    if [ -d "${BUILD_DIR}/dylib" ]; then
        mkdir -p "${APP_DIR}/"
        cp "${BUILD_DIR}/dylib"/*.dylib "${APP_DIR}/" 2>/dev/null || true
    fi

    if [ -f "${BASIC_DIR}/Info.plist" ]; then
        cp "${BASIC_DIR}/Info.plist" "${APP_DIR}/"
    fi
    
    if ls "${BASIC_DIR}"/*.png 1> /dev/null 2>&1; then
        cp "${BASIC_DIR}"/*.png "${APP_DIR}/"
    fi

    if [ -f "${BUILD_DIR}/entitlements.plist" ]; then
        cd "${BUILD_DIR}"
        ldid -Sentitlements.plist "Payload/${APP_NAME}.app/${APP_NAME}"
        cd ..
    else
        echo "警告：未找到 entitlements.plist，跳過簽名步驟"
    fi

    echo "構建完成！"
    inquire
}

if [ ! -x "$0" ]; then
    chmod +x "$0"
fi

main