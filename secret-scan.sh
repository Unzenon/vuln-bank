#!/bin/bash
echo "🔍 Memulai Secret Scanning..."

# Buat folder reports jika belum ada
mkdir -p reports

# Jalankan GitLeaks
gitleaks detect --source . --report-format json --report-path reports/secrets.json --verbose

# Check apakah ada secrets yang ditemukan
if [ -s reports/secrets.json ]; then
    echo ""
    echo "❌ BAHAYA! Ditemukan secrets yang bocor!"
    echo "📄 Detail report: reports/secrets.json"
    echo ""
    echo "📋 Summary findings:"
    
    # Hitung jumlah secrets
    SECRET_COUNT=$(cat reports/secrets.json | jq length 2>/dev/null || echo "1")
    echo "   Total secrets ditemukan: $SECRET_COUNT"
    
    # Tampilkan detail (jika jq tersedia)
    if command -v jq &> /dev/null; then
        cat reports/secrets.json | jq -r '.[] | "   - File: \(.File) (Line \(.StartLine)): \(.RuleID)"'
    else
        echo "   - Install 'jq' untuk detail yang lebih bagus"
    fi
    
    echo ""
    echo "🚨 Pipeline HARUS GAGAL karena ada secrets!"
    exit 1
else
    echo "✅ Tidak ada secrets yang bocor - AMAN!"
    exit 0
fi
