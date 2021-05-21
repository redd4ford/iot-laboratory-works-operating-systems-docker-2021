# install prometheus and replace config file
cd
wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz
tar -xzf prometheus-2.26.0.linux-amd64.tar.gz
cd prometheus-2.26.0.linux-amd64/
echo "
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node'
    scrape_interval: 10s
    static_configs:
      - targets: ['localhost:9100']
  - job_name: 'spring_micrometer'
    metrics_path: '/actuator/prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:8080']" > prometheus.yml
./prometheus &

# install node exporter
cd
wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
tar -xzf node_exporter-1.1.2.linux-amd64.tar.gz
cd node_exporter-1.1.2.linux-amd64/
./node_exporter &

# trunk lab 6 from git repository
cd
sudo svn checkout https://github.com/redd4ford/iot-laboratory-works-databases-2020/trunk/lab-6-spring-boot
cd lab-6-spring-boot/

# replace datasource.url's localhost with my db container name
echo "spring.datasource.url=jdbc:mysql://lab6db:3306/steam?useSSL=false&allowPublicKeyRetrieval=true
spring.datasource.username=redd4ford
spring.datasource.password=P4r4d0x!
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
management.endpoints.web.exposure.include=*
management.endpoint.health.show-details=always
management.metrics.tags.application=Application
spring.jpa.show_sql=true
spring.jpa.hibernate.ddl-auto=update
server.port = 8080" > ~/lab-6-spring-boot/src/main/resources/application.properties

# run the application
mvn install
mvn clean package
mvn spring-boot:run
