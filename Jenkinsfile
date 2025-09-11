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

        stage('Dependency Scanning - Snyk') {
            agent {
                docker { image 'snyk/snyk:node'; args "--entrypoint=" }
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh 'snyk test --json --token=$SNYK_CREDENTIALS_PSW > snyk-sca-report.json'
                }
                archiveArtifacts artifacts: 'snyk-sca-report.json'
            }
        }
    }

    post {
        always {
            script {
                def critical = sh(script: "grep -i 'CRITICAL' snyk-sca-report.json || true", returnStatus: true)
                if (critical == 0) {
                    echo "⚠️ CRITICAL vulnerability found in Vuln Bank pipeline build #${env.BUILD_NUMBER}"
                }
            }
        }
    }
}
