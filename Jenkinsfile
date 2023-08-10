pipeline {
    agent any
    tools {
       terraform 'terraform'
    }
	
      
    stages {
        stage('dev infrastructure') {
            when {
                branch 'dev'
            }
            steps {
                script {
							withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins	', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
    // Your pipeline steps that require AWS credentials
}	
                    sh 'terraform init'
                    sh 'terraform plan -var-file="dev-terraform.tfvars"'
                }
            }
        }
    
        stage('Staging infrastructure') {
            when {
                branch 'stage'
            }
            steps {
                script {
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins	', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
    // Your pipeline steps that require AWS credentials
}
                    sh 'terraform init -reconfigure'
                    sh 'terraform plan -var-file="stage-terraform.tfvars"'
                    sh 'terraform apply -var-file="stage-terraform.tfvars" --auto-approve'
		    

                }
            }
        }
    
        stage('Production infrastructure') {
            when {
                branch 'master'
            }
            steps {
                script {
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins	', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
    // Your pipeline steps that require AWS credentials
}
                    sh 'terraform init'
                    sh 'terraform plan -var-file="prod-terraform.tfvars"'
                    sh 'terraform apply -var-file="prod-terraform.tfvars" --auto-approve'
		    

                }
            }
        }
    }
}
