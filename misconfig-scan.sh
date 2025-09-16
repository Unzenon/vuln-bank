#!/bin/bash
echo "🔧 Memulai Misconfiguration Scanning..."

# Buat folder reports jika belum ada
mkdir -p reports

# Jalankan Trivy untuk scan semua config files
echo "📋 Scanning configuration files untuk misconfigurations..."
trivy config . --format json --output reports/misconfig-report.json --quiet

# Jalankan scan dalam format table untuk summary
trivy config . --format table > reports/misconfig-summary.txt 2>&1

# Check apakah scan berhasil
if [ $? -eq 0 ]; then
    echo "✅ Misconfiguration scan completed successfully"
else
    echo "⚠️ Misconfiguration scan completed with issues"
fi

# Check apakah ada critical atau high misconfigurations (parsing yang benar)
CRITICAL_COUNT=$(cat reports/misconfig-report.json | jq -r '.Results[]?.Misconfigurations[]? | select(.Severity == "CRITICAL") | .Severity' 2>/dev/null | wc -l)
HIGH_COUNT=$(cat reports/misconfig-report.json | jq -r '.Results[]?.Misconfigurations[]? | select(.Severity == "HIGH") | .Severity' 2>/dev/null | wc -l)

# Hitung total critical + high
TOTAL_CRITICAL_HIGH=$((CRITICAL_COUNT + HIGH_COUNT))

echo ""
echo "📊 Misconfiguration Summary:"
echo "   CRITICAL: $CRITICAL_COUNT"
echo "   HIGH: $HIGH_COUNT"
echo ""

if [ $TOTAL_CRITICAL_HIGH -gt 0 ]; then
    echo "❌ DITEMUKAN MISCONFIGURATION CRITICAL/HIGH!"
    echo "📄 Total Critical/High: $TOTAL_CRITICAL_HIGH"
    echo "📄 Detail report: reports/misconfig-report.json"
    echo "📄 Summary: reports/misconfig-summary.txt"
    echo ""
    
    # Tampilkan summary findings
    echo "📋 Critical/High Findings:"
    cat reports/misconfig-report.json | jq -r '.Results[]?.Misconfigurations[]? | select(.Severity == "CRITICAL" or .Severity == "HIGH") | "- \(.ID): \(.Title) (\(.Severity))"' 2>/dev/null || echo "Install 'jq' untuk summary yang lebih bagus"
    echo ""
    echo "🚨 Pipeline HARUS GAGAL karena ada misconfiguration critical/high!"
    exit 1
else
    echo "✅ Tidak ada misconfiguration critical/high - AMAN!"
    exit 0
fi
