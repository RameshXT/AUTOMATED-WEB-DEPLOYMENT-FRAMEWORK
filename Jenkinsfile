pipeline
{
    agent any
    stages
    {
        stage("Cleaning the workspace")
        {
            steps
            {
                script
                {
                    def workspaceDir = "/var/lib/jenkins/workspace/auto-jen/"
                    
                    // Check if the workspace directory exists
                    if (fileExists(workspaceDir))
                    {
                        // Remove all files and directories in the workspace directory
                        sh "sudo rm -rf ${workspaceDir}*"
                    }
                    else 
                    {
                        echo "Workspace directory doesn't exist."
                    }
                }
            }
        }
        stage("Cloning the repository")
        {
            steps
            {
                script
                {
                    git branch: 'automation', credentialsId: 'Automation', url: 'https://github.com/RameshXT/automation.git'
                }
            }
        }
        stage("Deleting exiting images and container") 
        {
            steps
            {
                script
                {
                    def containers = sh(script: "sudo docker ps -a -q", returnStdout: true).trim()
                    
                    if (containers)
                    {
                        sh "sudo docker stop $containers"
                        sh "sudo docker rm $containers"
                        echo "Containers successfully deleted!!"
                    }
                    else
                    {
                        echo "No containers are there to delete!!"
                    }
                    
                    def images = sh(script: "sudo docker images -q", returnStdout: true).trim()
                    
                    if (images)
                    {
                        sh "sudo docker rmi $images"
                        echo "Images successfully deleted!!"
                    }
                    else
                    {
                        echo "No images are there to delete!!"
                    }
                }
            }
        }
        stage("Building docker image")
        {
            steps
            {
                    script
                    {
                        def dockerImageTag = "rameshxt/automate-highway:${env.BUILD_NUMBER}"
                        
                        sh "sudo docker build -t ${dockerImageTag} /var/lib/jenkins/workspace/auto-jen/"
                    }
                }
        }

        stage("Running docker images")
        {
            steps
            {
                script
                {
                    def dockerImageTag = "rameshxt/automate-highway:${env.BUILD_NUMBER}"
                    
                    sh "sudo docker run -itd --name highwaycont -p 80:80 ${dockerImageTag}"
                    
                    echo "Docker container 'Highway' running successfully."
                }
            }
        }

        stage("Docker login")
        {
            steps
            {
                withCredentials([string(credentialsId: "DockerId", variable: "Docker")]) 
                {
                    sh "sudo docker login -u rameshxt -p $Docker"
                    
                    echo "Docker login successful."
                }
            }
        }
        stage("Pushing image to dockerHUB")
        {
            steps
            {
                script
                {
                    def dockerImageTag = "rameshxt/automate-highway:${env.BUILD_NUMBER}"
                    
                    sh "sudo docker push ${dockerImageTag}"
                    
                    echo "Docker image ${dockerImageTag} pushed to DockerHub successfully."
                }
            }
        }  
    }
}
