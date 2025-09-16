#!/bin/bash
echo "🛡️ Memulai SAST Scanning (Static Application Security Testing)..."

# Buat folder reports jika belum ada
mkdir -p reports

# Jalankan Bandit scan
echo "🔍 Scanning kode Python untuk security vulnerabilities..."
bandit -r . -f json -o reports/sast-report.json || true
bandit -r . -ll > reports/sast-summary.txt 2>&1 || true

# Check apakah ada vulnerabilities
if [ -f "reports/sast-report.json" ] && [ -s "reports/sast-report.json" ]; then
    TOTAL_ISSUES=$(cat reports/sast-report.json | jq '.results | length' 2>/dev/null || echo "unknown")
    HIGH_ISSUES=$(grep -c "Severity: High" reports/sast-summary.txt 2>/dev/null || echo "0")
    
    echo ""
    echo "❌ SAST VULNERABILITIES DETECTED!"
    echo "📄 Total issues: $TOTAL_ISSUES"
    echo "🚨 High severity issues: $HIGH_ISSUES"
    echo "📄 Detailed reports:"
    echo "   - JSON: reports/sast-report.json"
    echo "   - Summary: reports/sast-summary.txt"
    echo ""
    
    if [ "$HIGH_ISSUES" -gt 0 ]; then
        echo "🚨 CRITICAL: High severity vulnerabilities found!"
        echo "🛡️ Pipeline HARUS GAGAL untuk security issues!"
        exit 1
    else
        echo "⚠️ Medium/Low severity issues found - Review required"
        exit 0
    fi
else
    echo "✅ No SAST vulnerabilities detected"
    exit 0
fi