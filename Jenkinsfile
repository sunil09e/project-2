pipeline {
   agent any

   environment {
      IMAGE_NAME = "crazy1/trend-app"
      IMAGE_TAG = "V${BUILD_NUMBER}"
   }

   stages {
    
      stage('Clone') {
        steps {
          git branch: 'main', url: 'https://github.com/sunil09e/project-2.git'
        }
      }

      stage('Build') {
        steps {
          sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
        }
      }
 
      stage('Docker Login') {
        steps {
           withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                }
        }
      }

      stage('Push') {
         steps { 
            sh "docker push $IMAGE_NAME:$IMAGE_TAG"
         }
      }

      stage('Deploy to EKS') {
         steps {
           sh '''
           aws eks update-kubeconfig \
           --region ap-south-1 \
           --name trend-cluster
           
           sed -i "s|IMAGE_TAG|$IMAGE_TAG|g" kubernetes/deployment.yaml

           kubectl apply -f kubernetes/deployment.yaml
           '''
         }
      }
    }
}
