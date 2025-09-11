pipeline {
    agent none
    environment {
        SNYK_CREDENTIALS = credentials('SnykToken')
    }

    stages {
        stage('Checkout Source') {
            agent any
            steps {
                checkout scm
            }
        }

        stage('SCA - Snyk Test (Python)') {
            agent {
                docker {
                    image 'snyk/snyk:python'
                    args '--user root --network host --env SNYK_TOKEN=$SNYK_CREDENTIALS_PSW --entrypoint='
                }
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'snyk test --file=requirements.txt --json > snyk-scan-report.json'
                }
                sh 'cat snyk-scan-report.json'
                archiveArtifacts artifacts: 'snyk-scan-report.json'
            }
        }
    }

    post {
        always {
            script {
                def critical = sh(
                    script: "grep -i 'CRITICAL' snyk-scan-report.json || true",
                    returnStatus: true
                )
                if (critical == 0) {
                    echo "⚠️ CRITICAL vulnerability found in Vuln Bank pipeline build #${env.BUILD_NUMBER}"
                }
            }
        }
    }
}
