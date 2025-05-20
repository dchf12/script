#!/bin/bash

# 入力PDFファイル名（例: file.pdf）
INPUT_FILE="$1"

# 拡張子除去したベース名
BASENAME="${INPUT_FILE%.*}"

# Ghostscriptによる一時圧縮ファイル
GS_OUTPUT="${BASENAME}_compressed.pdf"

# 最終出力ファイル
FINAL_OUTPUT="${BASENAME}_optimized.pdf"

# Ghostscriptで再圧縮（品質: ebook）
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile="$GS_OUTPUT" "$INPUT_FILE"

# pdfcpuで最適化
pdfcpu optimize "$GS_OUTPUT" "$FINAL_OUTPUT"

# ファイルサイズ表示（任意）
echo "ファイルサイズ:"
ls -lh "$INPUT_FILE" "$GS_OUTPUT" "$FINAL_OUTPUT"

# 終了メッセージ
echo "圧縮済PDF: $FINAL_OUTPUT"

