# mysqlSpringBoot
To generate POJO/Model  classes and DAO classes for mysql database shema

The Main Objective of this repository is to generate boiler plate code for Spring Boot using Mysql database.
If you are using mysql database and you have created tables in mysql database.
You can use the Stored Procedures and Functions in mysql in this repository to create boiler plate Model java files and DataAccessObjects (DAO) java files.

You can just copy and paste these files in their respective directories.

I have used windows 10 operating system.

#Step1:
Go to your mysql installation directory and add below in my.ini file.

/*set directory to read and write files from mysql this is path where the java files are created */
[mysqld]
secure-file-priv = C:\\mysql\\loadfiles

restart the mysql server
use below link if need more info
https://dev.mysql.com/doc/refman/8.0/en/restart.html

#Step2:
login lo mysql as client ( use mysql workbench or from terminal)
Compile the following functions and procedures in the same order
1) camelCase.sql
2) PascalCase.sql
3) GenJavaModelAllTabs.sql
4) GenJavaDAOAllTabs.sql

#Step3:
CALL GenJavaModelAllTabs('your.java.package.name','mysqlSchemaName');
CALL GenJavaDAOAllTabs('your.java.package.name','mysqlSchemaName');

#Step4:
See the files directory (C:\\mysql\\loadfiles) you can see files generated.

#Step5:
find and replace "\" with "" in all.java files

#Step6:
Copy the files to respective directories.

Enjoy!!


#opensource usage
https://dev.mysql.com/
https://spring.io/projects/spring-boot

#Credits
Inspired from this link: https://www.code4copy.com/post/generate-java-model-class-from-mysql-table/
Thank you Anupama!!
