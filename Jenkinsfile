pipeline {
    agent { label 'macOS' } 

    environment {
        PATH = "$PATH:/Users/jenkins/.rbenv/shims:/opt/homebrew/bin"
        LANG = "en_US.UTF-8"
        AAB_PATH = "build/app/outputs/bundle/release/app-release.aab"
        IPA_PATH = "/Users/jenkins/agent/workspace/pnjapp/build/ios/ipa/pnjapp.ipa"
        ANDROID_HOME = "/Users/jenkins/Library/Android/sdk"
        DOCKER_PATH = '/usr/local/bin/docker'
        
        KEYSTORE_PATH = "/Users/jenkins/agent/workspace/pnjapp/android/app/mykey.jks" 
        KEYSTORE_PASSWORD = "Ali180905" 
        KEY_ALIAS = "login-key" 
        KEY_PASSWORD = "Ali180905" 

    }

    stages {
        stage('Unlock Keychain') {
            when { expression { isUnix() } }
            steps {
                sh '''
               
                security set-key-partition-list -S apple-tool:,apple: -s -k "tech2day" /Users/jenkins/Library/Keychains/login.keychain
                '''
            }
        }

        stage('GIT PULL') {
            steps {
                git branch: 'main', url: 'https://gitlab.techcliqs.com/parknjet/pnjapp.git'
            }
        }

        // stage('Update Version') {
        //     steps {
        //         sh '''
        //         chmod +x update_version.sh
        //         ./update_version.sh
        //         '''
        //     }
        // }

        // stage('Commit and Push Changes') {
        //     steps {
        //         sh '''
        //         git config user.name "Jenkins"
        //         git config user.email "jenkins@yourdomain.com"
        //         git add pubspec.yaml
        //         git commit -m "Auto-increment version number"
        //         git push
        //         '''
        //     }
        // }

        stage('Update Dependencies') {
            steps {
                sh '/opt/homebrew/bin/flutter pub upgrade'
            }
        }

        stage('Clean Xcode and iOS Pods') {
            when { expression { isUnix() } }
            steps {
                sh '''
                xcodebuild clean -workspace ios/Runner.xcworkspace -scheme Runner
                cd ios
                pod repo update
                rm -rf Pods Podfile.lock
                pod install
                cd ..
                '''
            }
        }

        stage('Flutter Clean and Get Dependencies') {
            steps {
                sh '''
                /opt/homebrew/bin/flutter clean
                /opt/homebrew/bin/flutter pub get
                '''
            }
        }

        stage('Build Android APK') {
            steps {
                sh '''
                /opt/homebrew/bin/flutter build appbundle --release
                '''
            }
        }

        stage('Build Android AAB') {
            steps {
                sh '''
                /opt/homebrew/bin/flutter build appbundle --release \
                    --dart-define=KEYSTORE_PATH=$KEYSTORE_PATH \
                    --dart-define=KEYSTORE_PASSWORD=$KEYSTORE_PASSWORD \
                    --dart-define=KEY_ALIAS=$KEY_ALIAS \
                    --dart-define=KEY_PASSWORD=$KEY_PASSWORD
                '''
            }
        }


        stage('Upload AAB to Google Play') {
            steps {
                withCredentials([file(credentialsId: 'GOOGLE_PLAY_JSON_KEY_PNJAPP', variable: 'JSON_KEY_PATH')]) {
                    sh '''
                    if [ ! -f "$JSON_KEY_PATH" ]; then
                        echo "JSON key file not found: $JSON_KEY_PATH"
                        exit 1
                    fi
                    
                    fastlane supply --aab $AAB_PATH \
                        --track internal \
                        --json_key $JSON_KEY_PATH \
                        --package_name com.parknjet.dispatch \
                        --verbose
                    '''
                }
            }
        }

    }
    options {
        disableConcurrentBuilds()
    }

    post {
        cleanup {
            deleteDir() // Clears workspace after build
        }
        always {
            echo "Pipeline completed"
        }
        success {
            echo "Build and distribution completed successfully."
        }
        failure {
            echo "Build or distribution failed."
        }
    }
}