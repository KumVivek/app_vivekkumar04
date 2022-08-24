pipeline {
    agent any
    environment{
       scannerHome= tool name:'sonar_scanner_dotnet'    
    }
    stages {
      stage('Nuget restore') {
        when { anyOf { branch 'develop'; branch 'master' } }
        steps {
          sh 'dotnet restore nagp-devops-us.sln'
        }
      }
      stage('Start Sonarqube Analysis') {
          when { anyOf { branch 'master' } }
          steps {
               echo 'Starting the sonar analysis'
              withSonarQubeEnv('Test_Sonar'){
                sh "dotnet ${scannerHome}//SonarScanner.MSBuild.dll begin /k:\"sonar-vivek\" /d:sonar.verbose=true"
          }
        }
      }
      stage('Code Build') {
        when { anyOf { branch 'develop'; branch 'master' } }
        steps {
          sh 'dotnet build nagp-devops-us.sln --configuration Release --no-restore'         
        }
      }   
      stage('Test Case Execution') {
        when { anyOf { branch 'master' } }
        
        steps {
            dir("test-project") {
                sh 'dotnet test'  
            }
        }
        
      }
      stage('Stop Sonarqube Analysis') {
        when { anyOf { branch 'master' } }
        steps {
            echo "Stopping the sonar analysis"
        withSonarQubeEnv('Test_Sonar'){
          sh "dotnet ${scannerHome}//SonarScanner.MSBuild.dll end"
        }
        }
      }
    
      stage('Release Artifact') {
        when { anyOf { branch 'develop' } }
        steps {
          sh 'dotnet publish --configuration release'
        }
      }
      stage('Kubernetes Deployment') {
        when { anyOf { branch 'develop'; branch 'master' } }
        steps {
          script {
                if (env.BRANCH_NAME == 'master') {
                    echo 'Hello from main branch'
                    sh 'gcloud auth activate-service-account --project=nagp-cloudops --key-file=/home/ubuntu/nagp-cloudops-9cebc58d0cde.json'
                    sh 'gcloud container clusters get-credentials nagp-ops --zone us-central1-c --project nagp-cloudops'
                    sh 'kubectl apply -f MasterDeployment.yml --namespace=kubernetes-cluster-vivekkumar04'

                }  else if (env.BRANCH_NAME == 'develop') {
                    sh 'gcloud auth activate-service-account --project=nagp-cloudops --key-file=/home/ubuntu/nagp-cloudops-9cebc58d0cde.json'
                    sh 'gcloud container clusters get-credentials nagp-ops --zone us-central1-c --project nagp-cloudops'
                    sh 'kubectl apply -f DevelopDeployment.yml --namespace=kubernetes-cluster-vivekkumar04'
                }
            }
        }
      }
     
    }
    triggers {
      githubPush()
    }
  }
