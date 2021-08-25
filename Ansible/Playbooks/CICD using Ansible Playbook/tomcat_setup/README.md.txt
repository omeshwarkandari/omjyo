Role Name
=========
Ansible Playbook to deploy a jenkins server.
Jenkins server will create a Tomcat Server and deploy a job into the tomcat container.
Requirements
------------
EC2 Instances
Palybook files
--------------
tasks/main.yml, handlers/main.yml &  files

Role Variables
--------------
defaults/main.yml &  vars/main.yml

Example Playbook
----------------
Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

  hosts: tomcat
  become: true
  gather_facts: yes

  roles:
    - tomcat_setup


Process Flow:
1. Create EC2 Instaances for Ansible Server, Jenins Server & Tomcat Server

2. Install Ansible, create a user ansadmin and set-up the passowrd less ssh connection between Ansible & Host

3. Create a directory "Playbook" in the home of ansadmin and a file "hosts" inside the playbook.

4. Run the playbook "jenkins_setup.yml" to craete jenkins server and setup the jenkins envioronment for java/maven/git/ssh/neceessary plugins.

5. Create a role for tomcat deployment 

$ ansible-galaxy init tomcat_setup
$ ls tomcat_setup/
defaults  files  handlers  README.md  tasks  vars (we have  " removed meta templates  test " as not using at the moment)
$ ls tomcat_setup/tasks/
main.yml  
(A role will have a built-in main.yml where we copy respective modules e.g. we copy all the modules under tasks of tomcatprodsetup2.yml into /tomcat_setup/tasks/main.yml,
handlers task inside /tomcat_setup/handlers/main.yml, content of tomcat_vars.yml isnide /tomcat_setup/vars/main.yml, files like server.xml inside /tomcat_setup/files and variables
which are of lower priority or generally do not change are kept insdie /tomcat_setup/defaults/main.yml e.g. create a user. we can also users by using /vars/main.yml and if we 
create users through both vars & default then users will be created thrtogh vars/main.yml as it has higher priority).
Create a yml file to play the playbook
$ nano tomcat_role.yml
This file will have the header part of the tomcatprodsetup2.yml as well as a taks called "roles" which calls the different files of the setup e.g "tomcat_setup".
Verify the palybook: $ ansible-playbook -i hosts tomcat_role.yml -C

6. Build artifacts: create a maven job in jenkins to build an artifact e.g. "webapp.war" 

7. Install Tomcat Server: 
  add "ansible-playbook -i hosts tomcat_role.yml" command in the maven job.
  [ Click on "Add-pre-build setup" -- select "Send files or exec command over ssh" -- copy below inside "exec Command" and build the job to deploy tomcat server inside the EC2 Instance as described in the hosts file]
  Since tomcat_role.yml is inside the path /home/ansadmin/playbook so we need to execute playbook commnd inside this path with the help of "cd" command.
  Command to copy: < cd /home/ansadmin/playbook; >
		   < ansible-playbook -i hosts tomcat_role.yml >
  
8. Copy artifact to ansible server: Jenkins will pass the build artifcat to the ansible which ansible can play with e.g. deplo to tomcat in this example, however, in production set-up ideally build is stored in the artifactory 
  and a playbook should download the artifact to the tomcat.
  [ Click on "Add-pre-build setup" -- select "Send files or exec command over ssh" -- under 'Transfer set" enter  source file path , remove prefix, Remote directory path as below and build the job again to cope artifacts into ansible ]
  Source file path: the path of the artifcat jobname inside the jenkins e.g " /var/lib/ansible/workspace/jobname/webapp/target/webapp.war or we can also get "webapp/target/webapp.war" by clicking 'Workspace" on Job itself.
  Remove prefix: webapp/target/
  Remote directory path: Location where we have the playbook in ansible e.g. /home/ansadmin/playbook and we need to prodive double slash "//home//ansadmin//playbook"
  Verify taht the artifact "webapp.war" is copied inside /home/ansadmin/playbook 

9. Deploy artifact "webapp.war": We add a copy command module under tasks/main.html to copy "webapp.war" into "webapps" directory of the tomcat and run the build again.
   
  - name: Deploy/copy artifact on the tomcat
    copy:
    src: webapp.war
    dest: /opt/apache-tomcat-8.5.70/webapps


  






 
