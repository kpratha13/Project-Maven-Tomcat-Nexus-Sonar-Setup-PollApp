# 🗳️ PollApp — Java Web Application CI/CD Pipeline

A Java 17 web application built with Apache Tomcat 10.1, featuring integrated code quality analysis via SonarQube and artifact management via Nexus Repository Manager — all hosted on Amazon Linux.

---

## 🛠️ Project Stack

| Tool | Version | Purpose |
|---|---|---|
| Java | 17 (Amazon Corretto) | Runtime & Development |
| Apache Tomcat | 10.1 | Servlet Container |
| Maven | Latest | Build Tool |
| SonarQube | LTS Community | Static Code Analysis |
| Nexus Repository Manager | 3.x | Artifact Storage |
| Docker | Latest | Containerization for Tools |

---

## 📂 Project Structure

```
PollApp/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   ├── PollServlet.java       # Core voting logic
│   │   │   └── ResultsServlet.java    # Data API for results
│   │   └── webapp/
│   │       └── index.jsp              # Frontend with AJAX polling
│   └── test/
│       └── java/
│           └── PollTest.java          # JUnit 5 unit tests
└── pom.xml
```

---

## ⚙️ Environment Setup (Amazon Linux)

### 1. Java Installation

```bash
sudo dnf update -y
sudo dnf install java-17-amazon-corretto-devel -y
```

### 2. Resource Optimization (Critical for 1GB RAM Servers)

Running Tomcat, SonarQube, and Nexus concurrently on a `t2.micro` requires Swap space:

```bash
sudo dd if=/dev/zero of=/swapfile bs=128M count=16
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
```

---

## 🐱 Apache Tomcat 10 Setup

Tomcat 10 hosts the compiled `.war` artifact.

### Installation

```bash
sudo groupadd tomcat
sudo useradd -g tomcat -d /opt/tomcat tomcat
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.18/bin/apache-tomcat-10.1.18.tar.gz
sudo mkdir /opt/tomcat
sudo tar -xf apache-tomcat-10.1.18.tar.gz -C /opt/tomcat --strip-components=1
```

### Configuration

- Set file permissions for the `tomcat` user.
  
  ```bash
   cd /opt/tomcat
   sudo chgrp -R tomcat /opt/tomcat
   sudo chmod -R g+r conf
   sudo chmod g+x conf
   sudo chown -R tomcat webapps/ work/ temp/ logs/
  ```
- Systemd Service File for Apache Tomcat
   ```bash 
   sudo vi /etc/systemd/system/tomcat.service
   [Unit]
   Description=Apache Tomcat Web Application Container
   After=network.target

   [Service]
   Type=forking

   User=tomcat
   Group=tomcat

   Environment="JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto"
   Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
   Environment="CATALINA_HOME=/opt/tomcat"
   Environment="CATALINA_BASE=/opt/tomcat"

   ExecStart=/opt/tomcat/bin/startup.sh
   ExecStop=/opt/tomcat/bin/shutdown.sh

   [Install]
   WantedBy=multi-user.target
  ```

- Configure `tomcat-users.xml` with Manager GUI credentials.
- Comment out `RemoteAddrValve` in `context.xml` to allow external access to the Manager App.

### Service Management

```bash
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat
sudo systemctl status tomcat
```

-Set a username and password
```bash
sudo vi /opt/tomcat/conf/tomcat-users.xml

<role rolename="manager-gui"/>
<role rolename="admin-gui"/>
<user username="admin" password="your_password" roles="manager-gui,admin-gui"/>

sudo vi /opt/tomcat/webapps/manager/META-INF/context.xml
<!--  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
  allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> --> [we have to comment this]


sudo vi /opt/tomcat/webapps/host-manager/META-INF/context.xml
<!--  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
          allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> --> [we have to comment this]


cd /opt/  [to  maintain your untrack files]
git clone "your project"
cd "select your project (Project-Maven-Tomcat-Nexus-Sonar-Setup-PollApp)"
yum intsall tree maven -y

cp /opt/Project-Maven-Tomcat-Nexus-Sonar-Setup-PollApp/target/PollApp.war /opt/tomcat/webapps/
ls /opt/tomcat/webapps/

cp -r /opt/Project-Maven-Tomcat-Nexus-Sonar-Setup-PollApp/target/PollApp.war /opt/tomcat/webapps/  [when we change in code then copy it in web]

URL:-
http://100.54.148.30:8080/PollApp/index.jsp
http://100.54.148.30:8080/


---

## 🔍 SonarQube: Code Quality Analysis

SonarQube is deployed via Docker and analyzes code for bugs, vulnerabilities, and code smells.

### Deployment

```bash
sudo sysctl -w vm.max_map_count=262144
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
```

Access the dashboard at: `http://<EC2-IP>:9000`

### Running Analysis

```bash
export MAVEN_OPTS="-Xmx256m"
mvn sonar:sonar \
  -Dsonar.projectKey=PollApp \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=your_generated_token
```

> 💡 Generate your token from **SonarQube → My Account → Security**.

---

## 📦 Nexus: Artifact Management

Nexus Repository Manager stores versioned build artifacts for deployment and rollback.

### Deployment

```bash
sudo docker run -d -p 8081:8081 --name nexus sonatype/nexus3
```

Access the dashboard at: `http://<EC2-IP>:8081`

### Retrieve Initial Admin Password

```bash
sudo docker exec -it nexus cat /nexus-data/admin.password
```

### Maven Integration

Add Nexus credentials to `~/.m2/settings.xml`:

```xml
<servers>
  <server>
    <id>nexus-snapshots</id>
    <username>admin</username>
    <password>your_password</password>
  </server>
</servers>
```

### Deploy Artifact to Nexus

```bash
mvn clean deploy -DskipTests
```

---

## 🚦 How to Run

### Build & Test
```bash
mvn clean verify
```

### Analyze Code Quality
```bash
mvn sonar:sonar
```

### Upload Artifact to Nexus
```bash
mvn deploy
```

### Access the Application
```
http://<EC2-IP>:8080/PollApp
```

---

## 🔌 Port Reference

| Service | Port |
|---|---|
| Apache Tomcat | 8080 |
| SonarQube | 9000 |
| Nexus Repository | 8081 |

---

## ⚠️ Notes

- All tool containers (SonarQube, Nexus) are managed by Docker and must be running before analysis or deployment.
- The `MAVEN_OPTS="-Xmx256m"` flag is required on low-memory instances to prevent out-of-memory errors during Maven builds.
- Swap space is persistent across reboots due to the `/etc/fstab` entry.
