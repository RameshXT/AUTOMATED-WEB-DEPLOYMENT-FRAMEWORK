# pipeline
# {
#     agent any
#     stages
#     {
#         stage("clean")
#         {
#             steps
#             {
#                 sh ' rm -rf /var/lib/jenkins/workspace* '                
#             }
#         }
#         stage("clone")
#         {
#             steps
#             {
#                 sh ' git clone https://github.com/RameshXT/automation.git -b automation '
#             }
#         }
#         stage("Build")
#         {
#             steps
#             {
#                 sh ' sudo docker build -t highway:v1 . '
#                 sh ' sudo docker run -itd --name highwaycont -p 80:80 highway:v1 '
#             }
#         }
#     }
# }







// Hosting a single-tier web application using this pipeline with full automatic deployment.

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
                    def workspaceDir = "/var/lib/jenkins/workspace"

                    if (fileExists(workspaceDir))
                    {
                        def files = fileTree(dir: workspaceDir).files

                        if (files)
                        {
                            echo "Workspace has files. Deleting everything.."
                            files.each { file ->
                                if (file.isFile())
                                {
                                    file.delete()
                                } else
                                {
                                    sh "sudo rm -rf ${file}"
                                }
                            }
                        }
                        else
                        {
                            echo "Workspace is already empty."
                        }
                    }
                    else
                    {
                        echo "Workspace directory doesn't exist."
                    }
                }
            }
        }
        stage("Deleting exiting images and container") 
        {
            steps
            {
                script
                {
                    def containers = sh(script: 'sudo docker ps -a -q', returnStdout: true).trim()
                    if (containers)
                    {
                        sh "sudo docker stop $containers"
                        sh "sudo docker rm $containers"
                        echo "Containers successfully deleted!!"
                    } else
                    {
                        echo "No containers are there to delete!!"
                    }

                    def images = sh(script: 'sudo docker images -q', returnStdout: true).trim()
                    if (images)
                    {
                        sh "sudo docker rmi $images"
                        echo "Images successfully deleted!!"
                    } else
                    {
                        echo "No images are there to delete!!"
                    }
                }
            }
        }
        stage("Clone the project")
        {
            steps
            {
                script
                {
                    def repoURL = "https://github.com/RameshXT/automation.git"
                    def branchName = "automation"
                    def workspaceDir = "/var/lib/jenkins/workspace"
                    def gitCommand = "git clone ${repoURL} -b ${branchName} ${workspaceDir}"

                    try
                    {
                        def output = sh(
                            script: gitCommand,
                            returnStdout: true
                        ).trim()

                        echo "Cloned repository to workspace: ${workspaceDir}"
                    }
                    catch (Exception e)
                    {
                        echo "Failed to clone the repository: ${e}"
                        currentBuild.result = 'FAILURE!!'
                        error(e)
                    }
                }
            }
        }
        stage("Building the image")
        {
            steps
            {
                script
                {
                    try
                    {
                        def dockerImageName = "rameshxt/docker"
                        def dockerImageTag = "${dockerImageName}:${BUILD_NUMBER}"
                        def workspaceDir = "/var/lib/jenkins/workspace/Web-Slave-1/PRACTICE-1"

                        sh "docker build -t ${dockerImageTag} ${workspaceDir}"
                        echo "Docker image ${dockerImageTag} built successfully."
                    }
                    catch (Exception e)
                    {
                        echo "Failed to build Docker image: ${e}"
                        currentBuild.result = 'FAILURE'
                        error(e)
                    }
                }
            }
        }
        stage("Running the image")
        {
            steps
            {
                script
                {
                    try
                    {
                        def dockerImageName = "rameshxt/docker"
                        def dockerImageTag = "${dockerImageName}:${BUILD_NUMBER}"

                        sh "docker run -it -d --name barista -p 80:80 ${dockerImageTag}"
                        echo "Docker container 'barista' running successfully."
                    }
                    catch (Exception e)
                    {
                        echo "Failed to run Docker container: ${e}"
                        currentBuild.result = 'FAILURE'
                        error(e)
                    }
                }
            }
        }
        stage("Docker Login")
        {
            steps
            {
                script
                {
                    try
                    {
                        withCredentials([string(credentialsId: 'Dockerid', variable: 'DockerPasswd')])
                        {
                            sh "docker login -u rameshxt -p ${DockerPasswd}"
                            echo "Docker login successful."
                        }
                    } catch (Exception e)
                    {
                        echo "Failed to login to Docker: ${e}"
                        currentBuild.result = 'FAILURE'
                        error(e)
                    }
                }
            }
        }
        stage("Pushing image to DockerHub")
        {
            steps
            {
                script
                {
                    try
                    {
                        def dockerImageName = "rameshxt/docker"
                        def dockerImageTag = "${dockerImageName}:${BUILD_NUMBER}"

                        withCredentials([string(credentialsId: 'Dockerid', variable: 'Dockerpasswd')])
                        {
                            sh "docker push ${dockerImageTag}"
                        }

                        echo "Docker image ${dockerImageTag} pushed to DockerHub successfully."
                    } 
                    catch (Exception e)
                        {
                        echo "Failed to push Docker image to DockerHub: ${e}"
                        currentBuild.result = 'FAILURE'
                        error(e)
                    }
                }
            }
        }
    }
}




















pipeline
{
    agent any
    stages
    {
        stage('Cleaning the workspace')
        {
            steps
            {
                script
                {
                    def workspaceDir = "/var/lib/jenkins/workspace/auto-jen/"

                    if (fileExists(workspaceDir))
                    {
                        sh "rm -rf ${workspaceDir}*"
                    }
                    else
                    {
                        echo "Workspace directory doesn't exist."
                    }
                }
            }
        }
        stage("clone")
        {
            steps
            {
                sh ' git clone https://RameshXT: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@github.com/RameshXT/automation.git -b automation '
            }
        }
        stage("Build")
        {
            steps
            {
                sh ' sudo docker build -t highway:v1 /var/lib/jenkins/workspace/auto-jen/automation '
                sh ' sudo docker run -itd --name highwaycont -p 80:80 highway:v1 '
            }
        }
    }
}