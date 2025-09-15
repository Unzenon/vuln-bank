#!/bin/bash
echo "🔍 Memulai SCA Scanning (Software Composition Analysis)..."

# Buat folder reports jika belum ada
mkdir -p reports

# Jalankan Safety check (tidak perlu login)
echo "📦 Scanning dependencies untuk vulnerabilities..."
/home/zenon/.local/bin/safety check --file requirements.txt > reports/sca-report.txt 2>&1

# Check apakah scan berhasil
if [ $? -eq 0 ]; then
    echo "✅ SCA scan completed successfully"
else
    echo "⚠️ SCA scan completed with findings"
fi

# Check apakah ada vulnerabilities  
if grep -q "vulnerabilities reported" reports/sca-report.txt; then
    VULN_COUNT=$(grep -o "[0-9]\+ vulnerabilities reported" reports/sca-report.txt | head -1 | grep -o "[0-9]\+")
    
    echo ""
    echo "❌ DITEMUKAN VULNERABILITIES!"
    echo "📄 Total vulnerabilities: $VULN_COUNT"
    echo "📄 Detail report: reports/sca-report.txt"
    echo ""
    echo "🚨 Pipeline HARUS GAGAL karena ada vulnerabilities!"
    exit 1
else
    echo "✅ Tidak ada vulnerabilities di dependencies"
    exit 0
fi
