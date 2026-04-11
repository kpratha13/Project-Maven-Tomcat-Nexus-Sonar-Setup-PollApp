🚀 PollApp: Real-Time DevOps Voting Application
PollApp is a Java-based web application designed to demonstrate a complete DevOps lifecycle. It features real-time poll updates using AJAX and is integrated with SonarQube for code quality and Nexus for artifact management.

🛠 Project Stack
Java 17 (Amazon Corretto)

Apache Tomcat 10.1 (Servlet Container)

Maven (Build Tool)

SonarQube (Static Code Analysis)

Nexus Repository Manager (Artifact Storage)

Docker (Containerization for Tools)

1. Environment Setup (Amazon Linux)
Java Installation
Bash

sudo dnf update -y
sudo dnf install java-17-amazon-corretto-devel -y
Resource Optimization (Critical for 1GB RAM Servers)
Since we are running Tomcat, SonarQube, and Nexus on a single t2.micro, we must enable Swap space:

Bash

sudo dd if=/dev/zero of=/swapfile bs=128M count=16
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
2. Apache Tomcat 10 Setup
Tomcat 10 is used to host our .war file.

Installation:

Bash

sudo groupadd tomcat
sudo useradd -g tomcat -d /opt/tomcat tomcat
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.18/bin/apache-tomcat-10.1.18.tar.gz
sudo mkdir /opt/tomcat
sudo tar -xf apache-tomcat-10.1.18.tar.gz -C /opt/tomcat --strip-components=1
Configuration:

Set permissions for the tomcat user.

Configure tomcat-users.xml for Manager GUI access.

Comment out the RemoteAddrValve in context.xml to allow external access to the Manager App.

Service Management:

Bash

sudo systemctl start tomcat
sudo systemctl enable tomcat
3. SonarQube: Code Quality
SonarQube is deployed via Docker to analyze code for bugs and vulnerabilities.

Deployment:

Bash

sudo sysctl -w vm.max_map_count=262144
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
Analysis Command:
Use the following Maven command to push reports to SonarQube:

Bash

export MAVEN_OPTS="-Xmx256m"
mvn sonar:sonar \
  -Dsonar.projectKey=PollApp \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=your_generated_token
4. Nexus: Artifact Management
Nexus acts as our Artifactory to store versioned build artifacts.

Deployment:

Bash

sudo docker run -d -p 8081:8081 --name nexus sonatype/nexus3
Authentication:
Retrieve the initial admin password:

Bash

sudo docker exec -it nexus cat /nexus-data/admin.password
Maven Integration:
Add Nexus credentials to ~/.m2/settings.xml:

XML

<servers>
  <server>
    <id>nexus-snapshots</id>
    <username>admin</username>
    <password>your_password</password>
  </server>
</servers>
Deployment Command:

Bash

mvn clean deploy -DskipTests
📂 Project Structure
src/main/java: Contains PollServlet.java (Logic) and ResultsServlet.java (Data API).

src/main/webapp: Contains index.jsp with AJAX polling script.

src/test/java: Contains PollTest.java for JUnit 5 unit testing.

🚦 How to Run
Build & Test: mvn clean verify

Analyze: mvn sonar:sonar

Upload: mvn deploy

Access: Open http://<EC2-IP>:8080/PollApp in your browser.
