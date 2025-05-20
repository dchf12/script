#!/usr/bin/osascript
-- Usage:  osascript kindle_capture_window.applescript <ページ数> [R|L]
-- 例   :  osascript kindle_capture_window.applescript 120 R

on run argv
    -- 引数チェック
    if (count of argv) < 1 then
        display dialog "引数: <ページ数> [R|L] を指定してください" buttons {"OK"} default button 1
        return
    end if
    
    set totalPages to (item 1 of argv) as integer
    
    -- 矢印方向（既定: R →）
    set arrowDir to "R"
    if (count of argv) ≥ 2 then set arrowDir to (item 2 of argv) as text
    if arrowDir is "L" then
        set pageKeyCode to 123 -- ←
    else
        set pageKeyCode to 124 -- →
    end if
    
    
    -- 保存ディレクトリ
    set saveDir to (POSIX path of (path to pictures folder)) & "screenshot/"
    do shell script "mkdir -p " & quoted form of saveDir
    
    -- Kindle を前面に & ウィンドウ ID 取得
    tell application "Kindle" to activate
    delay 0.5 -- UI が前面に来るまで少し待つ
    
    -- ウインドウ特定 -----------------------------------------------------------
    tell application "System Events"
        -- ★ 最大 5 秒待機してウインドウを取得
        repeat 50 times
            if exists (window 1 of application process "Kindle") then exit repeat
            delay 0.1
        end repeat
        if not (exists (window 1 of application process "Kindle")) then
            display alert "Kindle のウインドウが見つかりませんでした"
            return
        end if

        set theWin to window 1 of application process "Kindle"

        -- ① id 取得を試みる
        set useID to true
        try
            set winID to id of theWin
        on error
            -- ② AXWindowID を試みる
            try
                set winID to value of attribute "AXWindowID" of theWin
            on error
                set useID to false
            end try
        end try

        -- 座標も取得しておく（フォールバックまたはサイズ合わせ用）
        set {xPos, yPos} to position of theWin
        set {winW, winH} to size of theWin
    end tell

    -- 連続キャプチャ -----------------------------------------------------------
    repeat with i from 1 to totalPages
        set fn to saveDir & (text -3 thru -1 of ("000" & i)) & ".png"

        if useID then
            do shell script "/usr/sbin/screencapture -x -l " & winID & space & quoted form of fn
        else
            do shell script "/usr/sbin/screencapture -x -R " & xPos & "," & yPos & "," & winW & "," & winH & space & quoted form of fn
        end if

        tell application "System Events" to key code pageKeyCode
        delay 1.5 -- ページ描画待ち（環境で調整）
    end repeat
end run
