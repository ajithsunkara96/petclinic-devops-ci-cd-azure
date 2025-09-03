pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
  }

  tools {
    // Use the Maven you added under Manage Jenkins → Tools (named "maven")
    maven 'maven'
  }

  environment {
    // Keep names consistent with your Terraform files
    LOCATION   = 'canadacentral'
    RG_NAME    = 'project7'                  // existing RG
    PLAN_NAME  = 'project7-service-plan'
    APP_NAME   = 'project7-web-app-ajs'      // must be globally unique; change if name-in-use error
    SKU_NAME   = 'S1'
  }

  triggers {
    // The job config is already set to "GitHub hook trigger for GITScm polling"
    // This is just for clarity; you can keep it here too.
    githubPush()
  }

  stages {

    stage('Checkout') {
      steps {
        // Since the job is "Pipeline script from SCM", this refers to the same repo/branch
        checkout scm
      }
    }

    stage('Build with Maven') {
      steps {
        sh '''
          mvn -v
          mvn -ntp clean package -DskipTests -Dcheckstyle.skip=true
        '''
      }
    }

    stage('Publish artifact') {
      steps {
        sh '''
          ls -l target
          JAR_PATH=$(ls target/*.jar | head -n1)
          cp "$JAR_PATH" target/project7springpetclinic.jar
        '''
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }

    stage('Azure Login') {
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'azure-sp', usernameVariable: 'AZ_CLIENT_ID', passwordVariable: 'AZ_CLIENT_SECRET'),
          string(credentialsId: 'azure-tenant', variable: 'AZ_TENANT_ID'),
          string(credentialsId: 'azure-subscription', variable: 'AZ_SUBSCRIPTION_ID')
        ]) {
          sh '''
            az version
            az login --service-principal -u "$AZ_CLIENT_ID" -p "$AZ_CLIENT_SECRET" --tenant "$AZ_TENANT_ID"
            az account set --subscription "$AZ_SUBSCRIPTION_ID"

            # Export for Terraform (AzureRM provider & backend)
            export ARM_CLIENT_ID="$AZ_CLIENT_ID"
            export ARM_CLIENT_SECRET="$AZ_CLIENT_SECRET"
            export ARM_TENANT_ID="$AZ_TENANT_ID"
            export ARM_SUBSCRIPTION_ID="$AZ_SUBSCRIPTION_ID"

            # Masked print for sanity
            echo "Logged into Azure. SUBSCRIPTION set."
          '''
        }
      }
    }

    stage('Terraform Init/Plan/Apply') {
      steps {
        sh '''
          cd infra

          # Optional: feed variables via tfvars (matches your main.tf defaults)
          cat > run.auto.tfvars <<EOF
          # Values here match your current configuration
          EOF

          terraform -version
          terraform init -input=false
          terraform validate
          terraform plan -out=tfplan -input=false
          terraform apply -auto-approve -input=false tfplan
        '''
      }
    }

    stage('Deploy to Azure Web App') {
      steps {
        sh '''
          cd infra
          RG=$(terraform output -raw resource_group || echo "project7")
          APP=$(terraform output -raw webapp_name || echo "${APP_NAME}")
          cd ..

          # Deploy the built JAR to the Linux Web App (Java SE)
          az webapp deploy \
            --resource-group "$RG" \
            --name "$APP" \
            --type jar \
            --src-path target/project7springpetclinic.jar

          echo "App URL: https://$APP.azurewebsites.net"
        '''
      }
    }
  }

  post {
    success {
      echo '✅ Build, infra, and deployment completed successfully.'
    }
    failure {
      echo '❌ Pipeline failed. Check the stage that errored for details.'
    }
    always {
      // keep workspace clean between runs
      cleanWs(deleteDirs: true, notFailBuild: true)
    }
  }
}