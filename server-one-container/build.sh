MYSQL_ROOT_PASSWORD='P4r4d0x!'
MYSQL_SUPERUSER_NAME='redd4ford'

echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
sudo apt-get install -y -q

# install mysql
echo debconf mysql-server/root_password password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections
echo debconf mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections
sudo apt-get -qq install mysql-server > /dev/null
# install expect
sudo apt-get -qq install expect > /dev/null

# build script to run mysql_secure_installation
sudo tee ~/run_mysql_secure.sh > /dev/null << EOF
spawn $(which mysql_secure_installation)
expect "Enter password for user root:"
send "${MYSQL_ROOT_PASSWORD}\r"
expect "Press y|Y for Yes, any other key for No:"
send "y\r"
expect "Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:"
send "0\r"
expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
send "n\r"
expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
send "y\r"
expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
send "y\r"
expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "y\r"
expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
send "y\r"
EOF

#run expect script
sudo expect ~/run_mysql_secure.sh

/etc/init.d/mysql start --skip-grant-tables --user=root

# create a superuser and an empty database
sudo /usr/bin/mysql -u root --password=$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE new_db;"
sudo /usr/bin/mysql -u root --password=$MYSQL_ROOT_PASSWORD -e "CREATE USER '${MYSQL_SUPERUSER_NAME}'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
sudo /usr/bin/mysql -u root --password=$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_SUPERUSER_NAME}'@'localhost' WITH GRANT OPTION;"
sudo /usr/bin/mysql -u root --password=$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

# trunk lab 6 from git repository
cd
git clone -b os-midterm https://github.com/redd4ford/iot-laboratory-works-databases-2020.git
cd iot-laboratory-works-databases-2020/lab-6-spring-boot/

# import .sql to an empty database
sudo /usr/bin/mysql -u root --password=$MYSQL_ROOT_PASSWORD new_db < ~/iot-laboratory-works-databases-2020/lab-6-spring-boot/src/main/resources/steam-db.sql

/etc/init.d/mysql restart

# replace application.properties
echo "spring.datasource.url=jdbc:mysql://localhost:3306/steam?useSSL=false&allowPublicKeyRetrieval=true
spring.datasource.username=$MYSQL_SUPERUSER_NAME
spring.datasource.password=$MYSQL_ROOT_PASSWORD
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
management.endpoints.web.exposure.include=*
management.endpoint.health.show-details=always
management.metrics.tags.application=Application
spring.jpa.show_sql=true
spring.jpa.hibernate.ddl-auto=update
server.port = 8080" > ~/iot-laboratory-works-databases-2020/lab-6-spring-boot/src/main/resources/application.properties

# run the application
mvn install
mvn clean package
mvn spring-boot:run
